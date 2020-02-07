//
//  RESTHTTPSessionManager+ReactiveCocoa.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "RESTHTTPSessionManager+ReactiveCocoa.h"
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/RACSubscriber.h>
#import <ReactiveObjC/RACDisposable.h>

@implementation RESTHTTPSessionManager (ReactiveCocoa)

- (RACSignal *)rac_GET:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self GET:URLString
                                            parameters:parameters
                                              progress:nil
                                            completion:^(id response, NSError *error) {
                                                if (!error) {
                                                    [subscriber sendNext:response];
                                                    [subscriber sendCompleted];
                                                } else {
                                                    [subscriber sendError:error];
                                                }
                                            }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_GET: %@, parameters: %@", self.class, URLString, parameters];
}

- (RACSignal *)rac_HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self HEAD:URLString
                                             parameters:parameters
                                             completion:^(id response, NSError *error) {
                                                 if (!error) {
                                                     [subscriber sendNext:response];
                                                     [subscriber sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                 }
                                             }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_HEAD: %@, parameters: %@", self.class, URLString, parameters];
}

- (RACSignal *)rac_POST:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self POST:URLString
                                             parameters:parameters
                                               progress:nil
                                             completion:^(id response, NSError *error) {
                                                 if (!error) {
                                                     [subscriber sendNext:response];
                                                     [subscriber sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                 }
                                             }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_POST: %@, parameters: %@", self.class, URLString, parameters];
}

- (RACSignal *)rac_POST:(NSString *)URLString
             parameters:(NSDictionary *)parameters
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self POST:URLString
                                             parameters:parameters
                              constructingBodyWithBlock:block
                                               progress:nil
                                             completion:^(id response, NSError *error) {
                                                 if (!error) {
                                                     [subscriber sendNext:response];
                                                     [subscriber sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                 }
                                             }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_POST: %@, parameters: %@, constructingBodyWithBlock",
            self.class, URLString, parameters];
}

- (RACSignal *)rac_PUT:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self PUT:URLString
                                            parameters:parameters
                                            completion:^(id response, NSError *error) {
                                                if (!error) {
                                                    [subscriber sendNext:response];
                                                    [subscriber sendCompleted];
                                                } else {
                                                    [subscriber sendError:error];
                                                }
                                            }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_PUT: %@, parameters: %@", self.class, URLString, parameters];
}

- (RACSignal *)rac_PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self PATCH:URLString
                                              parameters:parameters
                                              completion:^(id response, NSError *error) {
                                                  if (!error) {
                                                      [subscriber sendNext:response];
                                                      [subscriber sendCompleted];
                                                  } else {
                                                      [subscriber sendError:error];
                                                  }
                                              }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_PATCH: %@, parameters: %@", self.class, URLString, parameters];
}

- (RACSignal *)rac_DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self DELETE:URLString
                                               parameters:parameters
                                               completion:^(id response, NSError *error) {
                                                   if (!error) {
                                                       [subscriber sendNext:response];
                                                       [subscriber sendCompleted];
                                                   } else {
                                                       [subscriber sendError:error];
                                                   }
                                               }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_DELETE: %@, parameters: %@", self.class, URLString, parameters];
}

#pragma mark -

- (RACSignal *)rac_GET:(NSString *)URLString
            parameters:(NSDictionary *)parameters
              progress:(id<RACSubscriber>)progress {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self GET:URLString
                                            parameters:parameters
                                              progress:^(NSProgress *downloadProgress) {
                                                  [progress sendNext:downloadProgress];
                                              }
                                            completion:^(id response, NSError *error) {
                                                if (!error) {
                                                    [subscriber sendNext:response];
                                                    [subscriber sendCompleted];
                                                    [progress sendCompleted];
                                                } else {
                                                    [subscriber sendError:error];
                                                    [progress sendError:error];
                                                }
                                            }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_GET: %@, parameters: %@, progress: %@",
            self.class, URLString, parameters, progress];
}


- (RACSignal *)rac_POST:(NSString *)URLString
             parameters:(NSDictionary *)parameters
               progress:(id<RACSubscriber>)progress {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self POST:URLString
                                             parameters:parameters
                                               progress:^(NSProgress *uploadProgress) {
                                                   [progress sendNext:uploadProgress];
                                               }
                                             completion:^(id response, NSError *error) {
                                                 if (!error) {
                                                     [subscriber sendNext:response];
                                                     [subscriber sendCompleted];
                                                     [progress sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                     [progress sendError:error];
                                                 }
                                             }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_POST: %@, parameters: %@, progress: %@",
            self.class, URLString, parameters, progress];
}

- (RACSignal *)rac_POST:(NSString *)URLString
             parameters:(NSDictionary *)parameters
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
               progress:(id<RACSubscriber>)progress {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSURLSessionDataTask *task = [self POST:URLString
                                             parameters:parameters
                              constructingBodyWithBlock:block
                                               progress:^(NSProgress *uploadProgress) {
                                                   [progress sendNext:uploadProgress];
                                               }
                                             completion:^(id response, NSError *error) {
                                                 if (!error) {
                                                     [subscriber sendNext:response];
                                                     [subscriber sendCompleted];
                                                     [progress sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                     [progress sendError:error];
                                                 }
                                             }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ -rac_POST: %@, parameters: %@, constructingBodyWithBlock %@, progress %@",
            self.class, URLString, parameters, block, progress];
}

@end
