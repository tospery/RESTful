//
//  RESTResponse.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <Mantle/Mantle.h>
#import <RESTful/RESTUtilities.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a parsed response.
 */
@interface RESTResponse RESTGenerics(ResultType) : MTLModel<MTLJSONSerializing>

/**
 The HTTP response.
 */
@property (strong, nonatomic, readonly, REST_NULLABLE) NSHTTPURLResponse *HTTPResponse;

/**
 The parsed result.
 
 Depending on the response JSON, this can contain a single `MTLModel` object or an array of
 `MTLModel` objects.
 */
@property (strong, nonatomic, readonly, REST_NULLABLE) RESTGenericType(ResultType, id) result;

/**
 Class of used to parsed result
 */
@property (strong, nonatomic, readonly, REST_NULLABLE) Class resultClass;

@property (nonatomic, strong, readonly) id rawResult;

/**
 Returns the result key path in the JSON.
 
 This method returns `nil` by default. For JSON responses with additional metadata, subclasses
 should override this method and return the key path of the result.
 */
+ (REST_NULLABLE NSString *)resultKeyPathForJSONDictionary:(NSDictionary *)JSONDictionary;

/**
 Attempts to parse a JSON dictionary into an `RESTResponse` object.
 
 @param HTTPResponse The HTTP response.
 @param JSONObject A foundation object with JSON data.
 @param resultClass The `MTLModel` subclass in which `result` will be transformed.
 @param error The error occurred if parsing fails.
 
 @return A new `RESTResponse` object upon success, or nil if a parsing error occurred.
 */
+ (REST_NULLABLE instancetype)responseWithHTTPResponse:(REST_NULLABLE NSHTTPURLResponse *)HTTPResponse
                                           JSONObject:(REST_NULLABLE id)JSONObject
                                          resultClass:(REST_NULLABLE Class)resultClass
                                                error:(NSError *REST__NULLABLE __autoreleasing *REST__NULLABLE)error;

@end

#pragma mark - Deprecated

@interface RESTResponse (Deprecated)

+ (REST_NULLABLE instancetype)responseWithHTTPResponse:(REST_NULLABLE NSHTTPURLResponse *)HTTPResponse
                                           JSONObject:(REST_NULLABLE id)JSONObject
                                          resultClass:(REST_NULLABLE Class)resultClass
REST_DEPRECATED("Replaced by +responseWithHTTPResponse:JSONObject:resultClass:error:")
NS_SWIFT_UNAVAILABLE("Deprecated. use `init(HTTPResponse:JSONObject:resultClass:) throws`");

@end

NS_ASSUME_NONNULL_END
