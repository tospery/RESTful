//
//  RESTHTTPSessionManager+ReactiveCocoa.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <RESTful/RESTHTTPSessionManager.h>
#import <RESTful/RESTUtilities.h>

@class RACSignal;
@protocol RACSubscriber;

NS_ASSUME_NONNULL_BEGIN

@interface RESTHTTPSessionManager (ReactiveCocoa)

/**
 Enqueues a `GET` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param downloadProgress Subscribes `downloadProgress` to `next` events with `NSProgress` object,
 to be sent on each downloading object update and completes then, send error on downloading error.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_GET:(NSString *)URLString
            parameters:(REST_NULLABLE id)parameters
              progress:(REST_NULLABLE id<RACSubscriber>)downloadProgress;

/**
 Enqueues a `HEAD` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_HEAD:(NSString *)URLString parameters:(REST_NULLABLE id)parameters;

/**
 Enqueues a `POST` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param uploadProgress Subscribes `uploadProgress` to `next` events with `NSProgress` object,
 to be sent on each uploading object update and completes then, send error on uploading error.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_POST:(NSString *)URLString
             parameters:(REST_NULLABLE id)parameters
               progress:(REST_NULLABLE id<RACSubscriber>)uploadProgress;

/**
 Enqueues a multipart `POST` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param block A block that takes a single argument and appends data to the HTTP body. The block
 argument is an object adopting the `AFMultipartFormData` protocol.
 @param uploadProgress Subscribes `uploadProgress` to `next` events with `NSProgress` object,
 to be sent on each uploading object update and completes then, send error on uploading error.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_POST:(NSString *)URLString
             parameters:(REST_NULLABLE id)parameters
constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData))block
               progress:(REST_NULLABLE id<RACSubscriber>)uploadProgress;

/**
 Enqueues a `PUT` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_PUT:(NSString *)URLString parameters:(REST_NULLABLE id)parameters;

/**
 Enqueues a `PATCH` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_PATCH:(NSString *)URLString parameters:(REST_NULLABLE id)parameters;

/**
 Enqueues a `DELETE` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_DELETE:(NSString *)URLString parameters:(REST_NULLABLE id)parameters;

@end

#pragma mark - Deprecated Methods

@interface RESTHTTPSessionManager (ReactiveCocoa_Deprecated)

/**
 Enqueues a `GET` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.

 @return A cold signal which sends a `NSProgress` object on each downloading object update
 and `RESTResponse` when downloading complete on next event and completes, or error otherwise
 */
- (RACSignal *)rac_GET:(NSString *)URLString parameters:(REST_NULLABLE id)parameters REST_DEPRECATED("Use `rac_GET:parameters:progress:` instead.");

/**
 Enqueues a `POST` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.

 @return A cold signal which sends a `NSProgress` object on each uploading object update
 and `RESTResponse` when uploading complete on next event and completes, or error otherwise
 */
- (RACSignal *)rac_POST:(NSString *)URLString parameters:(REST_NULLABLE id)parameters REST_DEPRECATED("Use `rac_POST:parameters:progress:` instead.");

/**
 Enqueues a multipart `POST` request.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param block A block that takes a single argument and appends data to the HTTP body. The block
 argument is an object adopting the `AFMultipartFormData` protocol.

 @return A cold signal which sends a `RESTResponse` on next event and completes, or error otherwise
 */
- (RACSignal *)rac_POST:(NSString *)URLString
             parameters:(REST_NULLABLE id)parameters
constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData))block REST_DEPRECATED("Use `rac_POST:parameters:constructingBodyWithBlock:progress:` instead.");

@end

NS_ASSUME_NONNULL_END
