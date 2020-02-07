//
//  RESTHTTPSessionManager.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import <RESTful/RESTUtilities.h>

@class RESTResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 `RESTHTTPSessionManager` provides methods to communicate with a web application over HTTP, mapping
 responses into native model objects which can optionally be persisted in a Core Data store.
 */
@interface RESTHTTPSessionManager RESTGenerics(ResponseType: RESTResponse *) : AFHTTPSessionManager

/**
 Specifies how to map responses to different model classes.

 Subclasses must override this method and return a dictionary mapping resource paths to model
 classes.
 Note that you can use `*` and `**` to match any text or `#` to match only digits.

 @see https://github.com/RESTful/RESTful#specifying-model-classes

 @return A dictionary mapping resource paths to model classes.
 */
+ (NSDictionary RESTGenerics(NSString *, id) *)modelClassesByResourcePath;

/**
 Specifies how to map responses to different response classes.

 Subclasses can override this method and return a dictionary mapping resource paths to response
 classes. Consider the following example for a GitHub client:

 + (NSDictionary *)responseClassesByResourcePath {
 return @{
 @"/users": [GTHUserResponse class],
 @"/orgs": [GTHOrganizationResponse class]
 };
 }

 Note that you can use `*` to match any text or `#` to match only digits.
 If a subclass override this method, the responseClass method will be ignored

 @return A dictionary mapping resource paths to response classes.
 */
+ (REST_NULLABLE NSDictionary RESTGenerics(NSString *, id) *)responseClassesByResourcePath;

+ (REST_NULLABLE NSDictionary RESTGenerics(NSString *, id) *)errorModelClassesByResourcePath;

///---------------------------
/// @name Making HTTP Requests
///---------------------------

/**
 Creates and runs an `NSURLSessionDataTask` with a `GET` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param downloadProgress A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)GET:(NSString *)URLString
                                parameters:(REST_NULLABLE id)parameters
                                  progress:(REST_NULLABLE void(^)(NSProgress *downloadProgress))downloadProgress
                                completion:(REST_NULLABLE void(^)
                                            (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                             NSError * REST__NULLABLE error))completion;

/**
 Creates and runs an `NSURLSessionDataTask` with a `HEAD` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)HEAD:(NSString *)URLString
                                 parameters:(REST_NULLABLE id)parameters
                                 completion:(REST_NULLABLE void(^)
                                             (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                              NSError * REST__NULLABLE error))completion;

/**
 Creates and runs an `NSURLSessionDataTask` with a multipart `POST` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param uploadProgress A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)POST:(NSString *)URLString
                                 parameters:(REST_NULLABLE id)parameters
                                   progress:(REST_NULLABLE void(^)(NSProgress *uploadProgress))uploadProgress
                                 completion:(REST_NULLABLE void(^)
                                             (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                              NSError * REST__NULLABLE error))completion;

/**
 Creates and runs an `NSURLSessionDataTask` with a multipart `POST` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param block A block that takes a single argument and appends data to the HTTP body. The block
 argument is an object adopting the `AFMultipartFormData` protocol.
 @param uploadProgress A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)POST:(NSString *)URLString
                                 parameters:(REST_NULLABLE id)parameters
                  constructingBodyWithBlock:(REST_NULLABLE void(^)(id<AFMultipartFormData> formData))block
                                   progress:(REST_NULLABLE void(^)(NSProgress *uploadProgress))uploadProgress
                                 completion:(REST_NULLABLE void(^)
                                             (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                              NSError * REST__NULLABLE error))completion;

/**
 Creates and runs an `NSURLSessionDataTask` with a `PUT` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)PUT:(NSString *)URLString
                                parameters:(REST_NULLABLE id)parameters
                                completion:(REST_NULLABLE void(^)
                                            (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                             NSError * REST__NULLABLE error))completion;

/**
 Creates and runs an `NSURLSessionDataTask` with a `PATCH` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)PATCH:(NSString *)URLString
                                  parameters:(REST_NULLABLE id)parameters
                                  completion:(REST_NULLABLE void(^)
                                              (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                               NSError * REST__NULLABLE error))completion;

/**
 Creates and runs an `NSURLSessionDataTask` with a `DELETE` request.

 If the request completes successfully, the `response` parameter of the completion block contains a
 `RESTResponse` object, and the `error` parameter is `nil`. If the request fails, the error parameter
 contains information about the failure.

 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param completion A block to be executed when the request finishes.
 */
- (REST_NULLABLE NSURLSessionDataTask *)DELETE:(NSString *)URLString
                                   parameters:(REST_NULLABLE id)parameters
                                   completion:(REST_NULLABLE void(^)
                                               (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                                NSError * REST__NULLABLE error))completion;

@end

#pragma mark - Deprecated Methods

@interface RESTHTTPSessionManager RESTGenerics(ResponseType: RESTResponse *) (Deprecated)

+ (Class)responseClass REST_DEPRECATED("Use `responseClassesByResourcePath` instead.");
+ (REST_NULLABLE Class)errorModelClass REST_DEPRECATED("Use `errorModelClassesByResourcePath` instead.");

- (REST_NULLABLE NSURLSessionDataTask *)GET:(NSString *)URLString
                                parameters:(REST_NULLABLE id)parameters
                                completion:(REST_NULLABLE void(^)
                                            (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                             NSError * REST__NULLABLE error))completion REST_DEPRECATED("Use `GET:parameters:progress:completion:` instead.");
- (REST_NULLABLE NSURLSessionDataTask *)POST:(NSString *)URLString
                                 parameters:(REST_NULLABLE id)parameters
                                 completion:(REST_NULLABLE void(^)
                                             (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                              NSError * REST__NULLABLE error))completion REST_DEPRECATED("Use `POST:parameters:progress:completion:` instead.");
- (REST_NULLABLE NSURLSessionDataTask *)POST:(NSString *)URLString
                                 parameters:(REST_NULLABLE id)parameters
                  constructingBodyWithBlock:(REST_NULLABLE void(^)(id<AFMultipartFormData> formData))block
                                 completion:(REST_NULLABLE void(^)
                                             (RESTGenericType(ResponseType, RESTResponse *) REST__NULLABLE response,
                                              NSError * REST__NULLABLE error))completion REST_DEPRECATED("Use `POST:parameters:constructingBodyWithBlock:progress:completion:` instead.");

@end

NS_ASSUME_NONNULL_END
