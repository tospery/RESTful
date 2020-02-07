//
//  RESTModelResponseSerializer.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <AFNetworking/AFURLResponseSerialization.h>
#import <RESTful/RESTUtilities.h>

@class RESTURLMatcher;

NS_ASSUME_NONNULL_BEGIN

/**
 AFJSONResponseSerializer subclass that validates and transforms a JSON response into a
 `RESTResponse` object.
 */
@interface RESTModelResponseSerializer : AFHTTPResponseSerializer

/**
 Matches URLs in HTTP responses with model classes.
 */
@property (strong, nonatomic, readonly) RESTURLMatcher *modelClassURLMatcher;
/**
 Matches URLs in HTTP responses with response classes.
 */
@property (strong, nonatomic, readonly, REST_NULLABLE) RESTURLMatcher *responseClassURLMatcher;

/**
 Matches URLs in HTTP responses with error model classes.
 */
@property (strong, nonatomic, readonly, REST_NULLABLE) RESTURLMatcher *errorModelClassURLMatcher;

/**
 TODO: Doc for why don't inherite it (PR104)
 */
@property(nonatomic, strong) AFJSONResponseSerializer *jsonSerializer;

/**
 Creates and returns model serializer.
 */
+ (instancetype)serializerWithURLMatcher:(RESTURLMatcher *)modelClassURLMatcher
                           responseClass:(REST_NULLABLE Class)responseClass
                         errorModelClass:(REST_NULLABLE Class)errorModelClass;

+ (instancetype)serializerWithURLMatcher:(RESTURLMatcher *)modelClassURLMatcher
                 responseClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)responseClassURLMatcher
               errorModelClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)errorModelClassURLMatcher;

- (instancetype)initWithURLMatcher:(RESTURLMatcher *)modelClassURLMatcher
           responseClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)responseClassURLMatcher
         errorModelClassURLMatcher:(REST_NULLABLE RESTURLMatcher *)errorModelClassURLMatcher NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - Deprecated

@interface RESTModelResponseSerializer (Deprecated)

@property (strong, nonatomic, readonly) RESTURLMatcher *URLMatcher REST_DEPRECATED("Use `modelClassURLMatcher` property");

@end

NS_ASSUME_NONNULL_END
