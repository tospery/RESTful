//
//  RESTURLMatcher.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "RESTURLMatcher.h"
#import <Mantle/Mantle.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, RESTURLMatcherType) {  // The integer value is related to search order
    RESTURLMatcherTypeNone   = -1,
    RESTURLMatcherTypeExact  = 0,
    RESTURLMatcherTypeNumber = 1,
    RESTURLMatcherTypeText   = 2,
    RESTURLMatcherTypeAny    = 3,
};

static NSString *_Nullable NSStringFromRESTURLMatcherType(RESTURLMatcherType type) {
    switch (type) {
        case RESTURLMatcherTypeNone:
            return @"None";
        case RESTURLMatcherTypeExact:
            return @"Exact";
        case RESTURLMatcherTypeNumber:
            return @"Number";
        case RESTURLMatcherTypeText:
            return @"Text";
        case RESTURLMatcherTypeAny:
            return @"Any";
        default:
            return nil;
    }
}

static BOOL RESTTextOnlyContainsDigits(NSString *text) {
    static dispatch_once_t onceToken;
    static NSCharacterSet *notDigits;

    dispatch_once(&onceToken, ^{
        notDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    });

	return [text rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

@interface RESTURLMatcher ()

@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, assign) RESTURLMatcherType type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) RESTURLMatcherNode *matcherNode;
@property (nonatomic, strong) NSMutableArray RESTGenerics(RESTURLMatcher *) *children;

@end

@interface RESTURLMatcherNode ()

@property (nonatomic, strong, readonly) RESTURLMatcherNodeBlock modelClassBlock;

@end

@implementation RESTURLMatcher

+ (instancetype)matcherWithBasePath:(REST_NULLABLE NSString *)basePath
                 modelClassesByPath:(REST_NULLABLE NSDictionary RESTGenerics(NSString *,id) *)modelClassesByPath {
    return [[self alloc] initWithBasePath:basePath modelClassesByPath:modelClassesByPath];
}

- (instancetype)initWithBasePath:(REST_NULLABLE NSString *)basePath
              modelClassesByPath:(REST_NULLABLE NSDictionary RESTGenerics(NSString *, id) *)modelClassesByPath {
    NSMutableDictionary<NSString *, RESTURLMatcherNode *> *matcherNodes = [[NSMutableDictionary alloc]
                                                                          initWithCapacity:modelClassesByPath.count];
    [modelClassesByPath enumerateKeysAndObjectsUsingBlock:^(NSString *path, id _ModelClass, BOOL *stop) {
        RESTURLMatcherNode *matcherNode;
        if ([_ModelClass isKindOfClass:[RESTURLMatcherNode class]]) {
            matcherNode = _ModelClass;
        } else if (REST_IS_CLASS(_ModelClass)) {
            matcherNode = [RESTURLMatcherNode matcherNodeWithModelClass:_ModelClass];
        } else if ([_ModelClass isKindOfClass:[NSDictionary class]]) {
            matcherNode = [RESTURLMatcherNode matcherNodeWithModelClasses:_ModelClass];
        } else if ([_ModelClass isKindOfClass:[NSString class]]) {
            Class __ModelClass = NSClassFromString(_ModelClass);
            if (__ModelClass) {
                matcherNode = [RESTURLMatcherNode matcherNodeWithModelClass:__ModelClass];
            }
        }
        if (matcherNode) {
            matcherNodes[path] = matcherNode;
        } else {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Got node with unknown type: %@", matcherNode];
        }
    }];
    return self = [self initWithBasePath:basePath matcherNodesByPath:matcherNodes];
}

- (instancetype)init {
    return [self initWithBasePath:nil matcherNodesByPath:nil];
}

+ (instancetype)matcherWithBasePath:(NSString *)basePath
                 matcherNodesByPath:(NSDictionary RESTGenerics(NSString *,RESTURLMatcherNode *) *)matcherNodes {
    return [[self alloc] initWithBasePath:basePath matcherNodesByPath:matcherNodes];
}

- (instancetype)initWithBasePath:(NSString *)basePath
              matcherNodesByPath:(NSDictionary RESTGenerics(NSString *, RESTURLMatcherNode *) *)matcherNodes {
    if (self = [super init]) {
        _type = RESTURLMatcherTypeNone;
        _children = [NSMutableArray array];

        _basePath = [basePath copy];

        [matcherNodes enumerateKeysAndObjectsUsingBlock:^(NSString *path, RESTURLMatcherNode *matcherNode, BOOL *stop) {
            NSAssert([matcherNode isKindOfClass:[RESTURLMatcherNode class]],
                     @"Expect %@, got %@", [RESTURLMatcherNode class], [matcherNode class]);
            [self addMatcherNode:matcherNode forPath:path sortChildren:NO];
        }];
        [self sortChildren];
    }
    return self;
}

#pragma mark - Matching

- (Class)modelClassForURLRequest:(NSURLRequest *)request andURLResponse:(NSHTTPURLResponse *)response {
    return [[self matcherNodeForPath:(response.URL ?: request.URL).path]
            modelClassForURLRequest:request andURLResponse:response];
}

- (Class)modelClassForURL:(NSURL *)url {
    return [[self matcherNodeForPath:url.path] modelClassForURLRequest:nil andURLResponse:nil];
}

- (RESTURLMatcherNode *)matcherNodeForPath:(NSString *)path {
    if (self.basePath && [path hasPrefix:self.basePath]) {
        path = [path substringFromIndex:self.basePath.length];
    }
    path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    return [self _matcherNodeForPath:path];
}

- (RESTURLMatcherNode *)_matcherNodeForPath:(NSString *)path {
    // Split path in to tokens
    NSArray RESTGenerics(NSString *) *tokens = [path componentsSeparatedByString:@"/"];
    NSArray RESTGenerics(NSString *) *subTokens = [tokens subarrayWithRange:NSMakeRange(1, tokens.count-1)];
    NSString *firstToken = tokens.firstObject;
    NSString *subPath = [subTokens componentsJoinedByString:@"/"];

    RESTURLMatcherNode *__block resultMatcherNode = nil;
    [self.children enumerateObjectsUsingBlock:^(RESTURLMatcher *childMatcher, NSUInteger idx, BOOL *REST__NONNULL stop) {
        // Find matched node in this level
        RESTURLMatcher *matchedMatcher = nil;
        switch (childMatcher.type) {
            case RESTURLMatcherTypeExact: {
                if ([childMatcher.text isEqualToString:firstToken]) {
                    matchedMatcher = childMatcher;
                }
                break;
            }
            case RESTURLMatcherTypeNumber: {
                if (RESTTextOnlyContainsDigits(firstToken)) {
                    matchedMatcher = childMatcher;
                }
                break;
            }
            case RESTURLMatcherTypeText: {
                matchedMatcher = childMatcher;
                break;
            }
            case RESTURLMatcherTypeAny: {
                // `**` means that we shouldn't check further nodes (path components), so return directly.
                // and it should be evaluated at the last.
                NSAssert(idx == self.children.count - 1,
                         @"Internal consistency error. `RESTURLMatcherTypeAny` should be tested at last.");
                resultMatcherNode = childMatcher.matcherNode;
            }
            case RESTURLMatcherTypeNone: {
                // Do nothing
                break;
            }
        }
        // Check children of this matched one
        if (!resultMatcherNode) {
            resultMatcherNode = (subTokens.count ?
                                 [matchedMatcher _matcherNodeForPath:subPath] : matchedMatcher.matcherNode);
        }
        *stop = resultMatcherNode != nil;
    }];
    return resultMatcherNode;
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, type:%@, text:%@, matcherNode:%@, children:%@>",
            self.class, self, @(self.type), self.text, self.matcherNode.description, self.children];
}

- (NSString *)debugDescription {
    @autoreleasepool {
        NSMutableString *result = [NSMutableString string];
        [result appendFormat:@"<%@>", NSStringFromRESTURLMatcherType(self.type)];
        if (self.basePath) {
            [result appendFormat:@" basePath: %@", self.basePath];
        }
        if (self.text) {
            [result appendFormat:@" text: %@", self.text];
        }

        if (self.children.count) {
            [result appendString:@"\n"];
            for (RESTURLMatcher *matcher in self.children) {
                NSArray RESTGenerics(NSString *) *lines = [matcher.debugDescription componentsSeparatedByString:@"\n"];
                [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
                    [result appendFormat:@"    %@\n", line];
                }];
            }
        }

        return [NSString stringWithString:[result
                                           stringByTrimmingCharactersInSet:[NSCharacterSet
                                                                            whitespaceAndNewlineCharacterSet]]];
    }
}

#pragma mark - Setup

- (void)addModelClass:(Class)ModelClass forPath:(NSString *)path {
    [self addMatcherNode:[RESTURLMatcherNode matcherNodeWithModelClass:ModelClass] forPath:path sortChildren:YES];
}

- (void)addMatcherNode:(RESTURLMatcherNode *)matcherNode forPath:(NSString *)path {
    return [self addMatcherNode:matcherNode forPath:path sortChildren:YES];
}

- (void)addMatcherNode:(RESTURLMatcherNode *)matcherNode forPath:(NSString *)path sortChildren:(BOOL)sortChildren {
    NSParameterAssert(path);

    NSArray *tokens = nil;

	if (path.length) {
		NSString *newPath = path;
		if ([path hasPrefix:@"/"]) {
			newPath = [path substringFromIndex:1];
		}

		tokens = [newPath componentsSeparatedByString:@"/"];
	}

    RESTURLMatcher *node = self;
    for (NSString *token in tokens) {
        NSMutableArray *children = node.children;
		RESTURLMatcher *existingChild = nil;

		for (RESTURLMatcher *child in children) {
			if ([token isEqualToString:child.text]) {
				node = child;
				existingChild = node;
				break;
			}
		}

        if (!existingChild) {
			existingChild = [[RESTURLMatcher alloc] init];

			if ([token isEqualToString:@"#"]) {
				existingChild.type = RESTURLMatcherTypeNumber;
			} else if ([token isEqualToString:@"*"]) {
				existingChild.type = RESTURLMatcherTypeText;
            } else if ([token isEqualToString:@"**"]) {
                existingChild.type = RESTURLMatcherTypeAny;
			} else {
				existingChild.type = RESTURLMatcherTypeExact;
			}

			existingChild.text = token;
			[node.children addObject:existingChild];
			node = existingChild;
		}
    }

    node.matcherNode = matcherNode;

    if (sortChildren) {
        [self sortChildren];
    }
}

- (void)sortChildren {
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
    [self.children sortUsingDescriptors:@[sd]];

    for (RESTURLMatcher *child in self.children) {
        [child sortChildren];
    }
}

@end

@implementation RESTURLMatcherNode

+ (instancetype)matcherNodeWithModelClass:(Class)ModelClass {
    NSParameterAssert([ModelClass conformsToProtocol:@protocol(MTLModel)]);
    return [self matcherNodeWithBlock:^Class(NSURLRequest *req, NSHTTPURLResponse *res) {
        return ModelClass;
    }];
}

+ (instancetype)matcherNodeWithResponseCode:(NSDictionary RESTGenerics(id, Class) *)modelClasses {
#if DEBUG
    [modelClasses enumerateKeysAndObjectsUsingBlock:^(id key, Class ModelClass, BOOL * _Nonnull stop) {
        NSParameterAssert([ModelClass conformsToProtocol:@protocol(MTLModel)]);
    }];
#endif
    return [self matcherNodeWithBlock:^Class(NSURLRequest *req, NSHTTPURLResponse *res) {
        return (res ? modelClasses[@(res.statusCode)] : nil) ?: modelClasses[@"*"];
    }];
}

+ (instancetype)matcherNodeWithRequestMethod:(NSDictionary RESTGenerics(NSString *, Class) *)modelClasses {
#if DEBUG
    [modelClasses enumerateKeysAndObjectsUsingBlock:^(NSString *key, Class ModelClass, BOOL * _Nonnull stop) {
        NSParameterAssert([ModelClass conformsToProtocol:@protocol(MTLModel)]);
    }];
#endif
    return [self matcherNodeWithBlock:^Class(NSURLRequest *req, NSHTTPURLResponse *res) {
        return (req.HTTPMethod ? modelClasses[req.HTTPMethod] : nil) ?: modelClasses[@"*"];
    }];
}

+ (instancetype)matcherNodeWithModelClasses:(NSDictionary RESTGenerics(id, Class) *)modelClasses {
#if DEBUG
    [modelClasses enumerateKeysAndObjectsUsingBlock:^(id key, Class ModelClass, BOOL * _Nonnull stop) {
        NSParameterAssert([ModelClass conformsToProtocol:@protocol(MTLModel)]);
    }];
#endif
    return [self matcherNodeWithBlock:^Class(NSURLRequest *req, NSHTTPURLResponse *res) {
        return (((req.HTTPMethod ? modelClasses[req.HTTPMethod] : nil) ?:
                 (res ? modelClasses[@(res.statusCode)] : nil)) ?:
                modelClasses[@"*"]);
    }];
}

+ (instancetype)matcherNodeWithBlock:(RESTURLMatcherNodeBlock)block {
    return [[RESTURLMatcherNode alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(RESTURLMatcherNodeBlock)block {
    if (self = [super init]) {
        _modelClassBlock = block;
    }
    return self;
}

- (REST_NULLABLE Class)modelClassForURLRequest:(NSURLRequest *)request andURLResponse:(NSHTTPURLResponse *)urlResponse {
    Class REST__NULLABLE ModelClass = self.modelClassBlock(request, urlResponse);
    NSAssert(!ModelClass || [ModelClass conformsToProtocol:@protocol(MTLModel)],
             @"%@ doesn't conform to protocol %@", ModelClass, @protocol(MTLModel));
    return ModelClass;
}

@end
