//
//  RESTHTTPSessionManager.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "RESTHTTPSessionManager.h"
#import "RESTResponse.h"
#import "RESTModelResponseSerializer.h"
#import "RESTURLMatcher.h"
#import "NSError+RESTResponse.h"

@implementation RESTHTTPSessionManager

#if DEBUG
+ (void)initialize {
    // TODO: Add links to releated document.
    if ([self respondsToSelector:@selector(errorModelClass)]) {
        NSLog(@"Warning: `+[RESTHTTPSessionManager errorModelClass]` is deprecated. "
              @"Override `+[RESTHTTPSessionManager errorModelClassesByResourcePath]` instead. (Class: %@)", self);
    }
    if ([self respondsToSelector:@selector(responseClass)]) {
        NSLog(@"Warning: `+[RESTHTTPSessionManager responseClass]` is deprecated. "
              @"Override `+[RESTHTTPSessionManager responseClassesByResourcePath]` instead. (Class: %@)", self);
    }
}
#endif

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
        self.responseSerializer =
        [RESTModelResponseSerializer
         serializerWithURLMatcher:[RESTURLMatcher matcherWithBasePath:self.baseURL.path
                                                  modelClassesByPath:[[self class] modelClassesByResourcePath]]
         responseClassURLMatcher:[RESTURLMatcher matcherWithBasePath:self.baseURL.path
                                                 modelClassesByPath:[[self class] responseClassesByResourcePath]]
         errorModelClassURLMatcher:[RESTURLMatcher matcherWithBasePath:self.baseURL.path
                                                   modelClassesByPath:[[self class] errorModelClassesByResourcePath]]];
    }
    return self;
}

#pragma mark - HTTP Manager Protocol

+ (NSDictionary *)modelClassesByResourcePath {
    [NSException
     raise:NSInternalInconsistencyException
     format:@"+[%@ %@] should be overridden by subclass", NSStringFromClass(self), NSStringFromSelector(_cmd)];
    return nil;  // Not reached
}

+ (NSDictionary *)responseClassesByResourcePath {
    return @{@"**": [RESTResponse class]};
}

+ (NSDictionary *)errorModelClassesByResourcePath {
    return nil;
}

#pragma mark - Making requests

- (NSURLSessionDataTask *)_dataTaskWithHTTPMethod:(NSString *)method
                                        URLString:(NSString *)URLString
                                       parameters:(id)parameters
                                   uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                 downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
                                       completion:(void (^)(RESTResponse *, NSError *))completion {
    // The implementation is copied from AFNetworking ... (Since we want to pass `responseObject`)
    // (Superclass implemenration doesn't return response object.)

    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer
                                    requestWithMethod:method
                                    URLString:[NSURL URLWithString:URLString relativeToURL:self.baseURL].absoluteString
                                    parameters:parameters
                                    error:&serializationError];
    if (serializationError) {
        if (completion) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }

    return [self dataTaskWithRequest:request
                      uploadProgress:uploadProgress
                    downloadProgress:downloadProgress
                   completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                       if (completion) {
                           if (!error) {
                               completion(responseObject, nil);
                           } else {
                               error = [error rest_errorWithUnderlyingResponse:responseObject];
                               completion(responseObject, error);
                           }
                       }
                   }];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                   completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self GET:URLString
                                parameters:parameters
                                  progress:nil
                                completion:completion];
    return task;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                   completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"GET"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:nil
                                              downloadProgress:downloadProgress
                                                    completion:completion];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString
                    parameters:(id)parameters
                    completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"HEAD"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:nil
                                              downloadProgress:nil
                                                    completion:completion];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                    completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"POST"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:nil
                                              downloadProgress:nil
                                                    completion:completion];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                    completion:(void (^)(RESTResponse *, NSError *))completion {
        NSURLSessionDataTask *task = [self POST:URLString
                                     parameters:parameters
                      constructingBodyWithBlock:block
                                       progress:nil
                                     completion:completion];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress *uploadProgress))uploadProgress
                    completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"POST"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:uploadProgress
                                              downloadProgress:nil
                                                    completion:completion];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                      progress:(void (^)(NSProgress *uploadProgress))uploadProgress
                    completion:(void (^)(RESTResponse *, NSError *))completion {
    // The implementation is copied from AFNetworking ... (Since we want to pass `responseObject`)
    // (Superclass implemenration doesn't return response object.)

    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer
                                    multipartFormRequestWithMethod:@"POST"
                                    URLString:[NSURL URLWithString:URLString relativeToURL:self.baseURL].absoluteString
                                    parameters:parameters
                                    constructingBodyWithBlock:block
                                    error:&serializationError];
    if (serializationError) {
        if (completion) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }

    // `dataTaskWithRequest:completionHandler:` creates a new NSURLSessionDataTask
    NSURLSessionDataTask *dataTask = [self uploadTaskWithStreamedRequest:request
                                                                progress:uploadProgress
                                                       completionHandler:^(NSURLResponse * __unused response,
                                                                           id responseObject,
                                                                           NSError *error) {
                                                           if (completion) {
                                                               if (!error) {
                                                                   completion(responseObject, nil);
                                                               } else {
                                                                   completion(responseObject, error);
                                                               }
                                                           }
                                                       }];

    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                   completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"PUT"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:nil
                                              downloadProgress:nil
                                                    completion:completion];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                     completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"PATCH"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:nil
                                              downloadProgress:nil
                                                    completion:completion];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                      completion:(void (^)(RESTResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [self _dataTaskWithHTTPMethod:@"DELETE"
                                                     URLString:URLString
                                                    parameters:parameters
                                                uploadProgress:nil
                                              downloadProgress:nil
                                                    completion:completion];
    [task resume];
    return task;
}

@end
