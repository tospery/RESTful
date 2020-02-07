//
//  RESTResponse.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "RESTResponse.h"
#import "NSDictionary+RESTful.h"

@interface RESTResponse RESTGenerics(ResultType) ()

@property (strong, nonatomic, readwrite, REST_NULLABLE) NSHTTPURLResponse *HTTPResponse;
@property (strong, nonatomic, readwrite) RESTGenericType(ResultType, id) result;
@property (strong, nonatomic, readwrite) Class resultClass;

@end

@implementation RESTResponse

+ (NSString *)resultKeyPathForJSONDictionary:(NSDictionary *)JSONDictionary {
    return nil;
}

+ (instancetype)responseWithHTTPResponse:(NSHTTPURLResponse *)HTTPResponse
                              JSONObject:(id)JSONObject
                             resultClass:(Class)resultClass
                                   error:(NSError *__autoreleasing *)error {
    RESTResponse *response = nil;
    id result = JSONObject;

    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        response = [MTLJSONAdapter modelOfClass:self fromJSONDictionary:JSONObject error:error];
        NSString *resultKeyPath = [[response class] resultKeyPathForJSONDictionary:JSONObject];
        if (resultKeyPath) {
            result = [(NSDictionary *)JSONObject rest_objectForKeyPath:resultKeyPath];
        } else {
            response = [[self alloc] init];
        }
    } else {
        response = [[self alloc] init];
    }

    if (response == nil) {
        return nil;
    }

    response.HTTPResponse = HTTPResponse;
    response->_rawResult = JSONObject;

    if (result != nil) {
        if (resultClass != Nil) {
            NSValueTransformer *valueTransformer = nil;

            if ([result isKindOfClass:[NSDictionary class]]) {
                valueTransformer = [MTLJSONAdapter dictionaryTransformerWithModelClass:resultClass];
            } else if ([result isKindOfClass:[NSArray class]]) {
                valueTransformer = [MTLJSONAdapter arrayTransformerWithModelClass:resultClass];
            }

            if ([valueTransformer conformsToProtocol:@protocol(MTLTransformerErrorHandling)]) {
                BOOL success = NO;
                result = [(NSValueTransformer<MTLTransformerErrorHandling> *)valueTransformer transformedValue:result
                                                                                                       success:&success
                                                                                                         error:error];
                if (!success) {
                    result = nil;
                }
            } else {
                result = [valueTransformer transformedValue:result];
            }
        }

        response.result = result;
    }

    response.resultClass = resultClass;
    return response;
}

#pragma mark - Mantle

+ (MTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey {
    if ([propertyKey isEqualToString:@"rawResult"]) {
        return MTLPropertyStorageNone;
    } else {
        return [super storageBehaviorForPropertyWithKey:propertyKey];
    }
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

#pragma mark - deprecated

+ (instancetype)responseWithHTTPResponse:(NSHTTPURLResponse *)HTTPResponse
                              JSONObject:(id)JSONObject
                             resultClass:(Class)resultClass {
    return [self responseWithHTTPResponse:HTTPResponse JSONObject:JSONObject resultClass:resultClass error:nil];
}

@end
