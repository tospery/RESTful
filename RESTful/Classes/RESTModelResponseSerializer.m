//
//  RESTModelResponseSerializer.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "RESTModelResponseSerializer.h"
#import <Mantle/Mantle.h>
#import "RESTResponse.h"
#import "RESTURLMatcher.h"
#import "NSError+RESTResponse.h"
#import <objc/runtime.h>

#pragma mark - Patch AFNetworking

/*
 * To make the URL Matcher works with request content like http method used,
 * the response serializer must be able to access its corresponding reqeust.
 *
 * Hence we patch AFNetworking to associate responses with its reqeust.
 * 
 * 1. `NSAssert`s are added in order that AFNetworking are changing its API.
 * 2. `-[AFURLSessionManagerTaskDelegate URLSession:task:didCompleteWithError:]` calls response serializer
 *    asynchronously, so the clean up action could be only called in the completion handler.
 *
 */

typedef void (^rest_AFURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);
@interface rest_dummy_AFURLSessionManagerTaskDelegate : NSObject
@property (nonatomic, copy) rest_AFURLSessionTaskCompletionHandler completionHandler;
@end

@implementation RESTModelResponseSerializer (AFNetworkingPatch)

static char REST_NSURLSessionTask_requestAssociationKey;
typedef void (*__imp_URLSession_task_didCompleteWithError_)(id, SEL, NSURLSession *, NSURLSessionTask *, NSError *);
static __imp_URLSession_task_didCompleteWithError_ __af_URLSession_task_didCompleteWithError_;
void __rest_URLSession_task_didCompleteWithError_(rest_dummy_AFURLSessionManagerTaskDelegate *self,
                                                 SEL _cmd,
                                                 NSURLSession *session,
                                                 NSURLSessionTask* task,
                                                 NSError *error) {
    NSAssert([self isKindOfClass:NSClassFromString(@"AFURLSessionManagerTaskDelegate")],
             @"Check RESTful update for this issue. "
             @"Or submit one to https://github.com/RESTful/RESTful/issues");
    NSAssert([NSStringFromSelector(_cmd) isEqualToString:@"URLSession:task:didCompleteWithError:"],
             @"Check RESTful update for this issue. "
             @"Or submit one to https://github.com/RESTful/RESTful/issues");

    // Associate the task to its response ... to make the URLMatcher able to access request
    NSURLResponse *response = task.response;
    NSURLRequest *request = task.currentRequest;
    if (response && request) {
        objc_setAssociatedObject(response,
                                 &REST_NSURLSessionTask_requestAssociationKey,
                                 request,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // Clean up associated object in completion handler
        rest_AFURLSessionTaskCompletionHandler completionHandler = self.completionHandler;
        self.completionHandler = ^(NSURLResponse *response, id responseObject, NSError *error) {
            if (response) {
                objc_setAssociatedObject(response,
                                         &REST_NSURLSessionTask_requestAssociationKey,
                                         nil,
                                         OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }

            if (completionHandler) {
                completionHandler(response, responseObject, error);
            }
        };
    }

    // Call original implementation
    __af_URLSession_task_didCompleteWithError_(self, _cmd, session, task, error);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class AFURLSessionManagerTaskDelegate = NSClassFromString(@"AFURLSessionManagerTaskDelegate");
        NSAssert(AFURLSessionManagerTaskDelegate, @"Cannot find class `AFURLSessionManagerTaskDelegate`. "
                 @"Check RESTful update for this issue. "
                 @"Or submit one to https://github.com/RESTful/RESTful/issues");
        SEL originalSelector = @selector(URLSession:task:didCompleteWithError:);
        NSAssert([AFURLSessionManagerTaskDelegate instancesRespondToSelector:originalSelector],
                 @"AFURLSessionManagerTaskDelegate doesn't responds to URLSession:task:didCompleteWithError:. "
                 @"Check RESTful update for this issue. "
                 @"Or submit one to https://github.com/RESTful/RESTful/issues");

        Method originalMethod = class_getInstanceMethod(AFURLSessionManagerTaskDelegate, originalSelector);
        IMP swizzleImp = (IMP)__rest_URLSession_task_didCompleteWithError_;
        __af_URLSession_task_didCompleteWithError_ =
            (__imp_URLSession_task_didCompleteWithError_)method_setImplementation(originalMethod, swizzleImp);
        NSAssert(__af_URLSession_task_didCompleteWithError_,
                 @"Check RESTful update for this issue. "
                 @"Or submit one to https://github.com/RESTful/RESTful/issues");
    });
}

@end

#pragma mark - Serializer Implementation

@implementation RESTModelResponseSerializer

+ (instancetype)serializerWithURLMatcher:(RESTURLMatcher *)modelClassURLMatcher
                 responseClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)responseClassURLMatcher
               errorModelClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)errorModelClassURLMatcher {
    return [[self alloc] initWithURLMatcher:modelClassURLMatcher
                    responseClassURLMatcher:responseClassURLMatcher
                  errorModelClassURLMatcher:errorModelClassURLMatcher];
}

+ (instancetype)serializerWithURLMatcher:(RESTURLMatcher *)modelClassURLMatcher
                           responseClass:(Class)responseClass
                         errorModelClass:(Class)errorModelClass {
    RESTURLMatcher *responseClassURLMatcher = nil;
    if (responseClass) {
        responseClassURLMatcher = [RESTURLMatcher matcherWithBasePath:nil modelClassesByPath:@{
            @"**": responseClass,
        }];
    }
    RESTURLMatcher *errorModelClassURLMatcher = nil;
    if (errorModelClass) {
        errorModelClassURLMatcher = [RESTURLMatcher matcherWithBasePath:nil modelClassesByPath:@{
            @"**": errorModelClass,
        }];
    }
    return [[self alloc] initWithURLMatcher:modelClassURLMatcher
                    responseClassURLMatcher:responseClassURLMatcher
                  errorModelClassURLMatcher:errorModelClassURLMatcher];
}

- (instancetype)init {
    return [self initWithURLMatcher:[RESTURLMatcher matcherWithBasePath:nil modelClassesByPath:nil]
            responseClassURLMatcher:nil
          errorModelClassURLMatcher:nil];
}

- (instancetype)initWithURLMatcher:(RESTURLMatcher *)modelClassURLMatcher
           responseClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)responseClassURLMatcher
         errorModelClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)errorModelClassURLMatcher {
    if (self = [super init]) {
        _jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];

        _modelClassURLMatcher = modelClassURLMatcher;
        _responseClassURLMatcher = responseClassURLMatcher;
        _errorModelClassURLMatcher = errorModelClassURLMatcher;
    }
    return self;
}

#pragma mark - AFURLRequestSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    NSError *serializationError = nil;
    id REST__NULLABLE JSONObject = [self.jsonSerializer responseObjectForResponse:response
                                                                            data:data
                                                                           error:&serializationError];

    if (error) {
        *error = serializationError;
    }

    if (serializationError && serializationError.code != NSURLErrorBadServerResponse) {
        return nil;
    }

    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSURLRequest *request = response ? objc_getAssociatedObject(response,
                                                                &REST_NSURLSessionTask_requestAssociationKey) : nil;

    Class resultClass = nil;
    if (!serializationError) {
        resultClass = [self.modelClassURLMatcher modelClassForURLRequest:request andURLResponse:HTTPResponse];
    } else {
        resultClass = [self.errorModelClassURLMatcher modelClassForURLRequest:request andURLResponse:HTTPResponse];
    }

    Class responseClass = nil;
    if (self.responseClassURLMatcher) {
        responseClass = [self.responseClassURLMatcher modelClassForURLRequest:request andURLResponse:HTTPResponse];
    }
    if (!responseClass) {
        responseClass = [RESTResponse class];
    }

    RESTResponse *responseObject = [responseClass responseWithHTTPResponse:HTTPResponse
                                                               JSONObject:JSONObject
                                                              resultClass:resultClass
                                                                    error:&serializationError];
    if (serializationError && error) {
        *error = serializationError;
    }

    return responseObject;
}

#pragma mark - JSON Serializer

- (NSSet *)acceptableContentTypes {
    return self.jsonSerializer.acceptableContentTypes;
}

- (void)setAcceptableContentTypes:(NSSet<NSString *> *)acceptableContentTypes {
    self.jsonSerializer.acceptableContentTypes = acceptableContentTypes;
}

- (NSIndexSet *)acceptableStatusCodes {
    return self.jsonSerializer.acceptableStatusCodes;
}

- (void)setAcceptableStatusCodes:(NSIndexSet *)acceptableStatusCodes {
    self.jsonSerializer.acceptableStatusCodes = acceptableStatusCodes;
}

- (NSStringEncoding)stringEncoding {
    return self.jsonSerializer.stringEncoding;
}

- (void)setStringEncoding:(NSStringEncoding)stringEncoding {
    self.jsonSerializer.stringEncoding = stringEncoding;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *REST__NULLABLE __autoreleasing *REST__NULLABLE)error {
    return [self.jsonSerializer validateResponse:response data:data error:error];
}

@end

@implementation RESTModelResponseSerializer (Deprecated)

- (RESTURLMatcher *)URLMatcher {
    return self.modelClassURLMatcher;
}

@end
