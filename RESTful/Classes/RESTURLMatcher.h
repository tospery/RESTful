//
//  RESTURLMatcher.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <Foundation/Foundation.h>
#import <RESTful/RESTUtilities.h>

NS_ASSUME_NONNULL_BEGIN

@class RESTURLMatcherNode;

/**
 Helper class to aid in matching URLs to model classes.
 
 The source code of this class is based on `SCLURLModelMatcher` from
 https://github.com/dcaunt/Sculptor/ by David Caunt.
 */
@interface RESTURLMatcher : NSObject

+ (instancetype)matcherWithBasePath:(REST_NULLABLE NSString *)basePath
                 modelClassesByPath:(REST_NULLABLE NSDictionary RESTGenerics(NSString *, id) *)modelClassesByPath;
- (instancetype)initWithBasePath:(REST_NULLABLE NSString *)basePath
              modelClassesByPath:(REST_NULLABLE NSDictionary RESTGenerics(NSString *, id) *)modelClassesByPath;

+ (instancetype)matcherWithBasePath:(REST_NULLABLE NSString *)basePath
                 matcherNodesByPath:(REST_NULLABLE NSDictionary RESTGenerics(NSString *, RESTURLMatcherNode *) *)nodes;
- (instancetype)initWithBasePath:(REST_NULLABLE NSString *)basePath
              matcherNodesByPath:(REST_NULLABLE NSDictionary RESTGenerics(NSString *, RESTURLMatcherNode *) *)matcherNodes
NS_DESIGNATED_INITIALIZER;

- (REST_NULLABLE Class)modelClassForURL:(NSURL *)url;
- (REST_NULLABLE Class)modelClassForURLRequest:(REST_NULLABLE NSURLRequest *)request
                               andURLResponse:(REST_NULLABLE NSHTTPURLResponse *)urlResponse;

- (void)addModelClass:(Class)modelClass forPath:(NSString *)path;
- (void)addMatcherNode:(RESTURLMatcherNode *)matcherNode forPath:(NSString *)path;

@end

typedef Class REST__NULLABLE(^RESTURLMatcherNodeBlock)(NSURLRequest *REST__NULLABLE, NSHTTPURLResponse *REST__NULLABLE);

@interface RESTURLMatcherNode : NSObject

+ (instancetype)matcherNodeWithModelClass:(Class)ModelClass;
+ (instancetype)matcherNodeWithResponseCode:(NSDictionary RESTGenerics(NSNumber *, Class) *)modelClasses;
+ (instancetype)matcherNodeWithRequestMethod:(NSDictionary RESTGenerics(NSString *, Class) *)modelClasses;
+ (instancetype)matcherNodeWithModelClasses:(NSDictionary RESTGenerics(id, Class) *)modelClasses;
+ (instancetype)matcherNodeWithBlock:(RESTURLMatcherNodeBlock)block;
- (instancetype)initWithBlock:(RESTURLMatcherNodeBlock)block NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (REST_NULLABLE Class)modelClassForURLRequest:(REST_NULLABLE NSURLRequest *)request
                               andURLResponse:(REST_NULLABLE NSHTTPURLResponse *)urlResponse;

@end

NS_ASSUME_NONNULL_END
