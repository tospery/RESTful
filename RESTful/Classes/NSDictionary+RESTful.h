//
//  NSDictionary+RESTful.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <Foundation/Foundation.h>
#import <RESTful/RESTUtilities.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary RESTGenerics(KeyType, ObjectType) (RESTful)

/**
 *  Returns the value associated with a given key path.
 *
 *  For example, a dictionary like
 *
 *    NSDictionary *someDict = @{
 *        @"dict": @{
 *            @"answer": @42,
 *        },
 *    };
 *    id answer = [someDict rest_objectForKeyPath:@"dict.answer"];
 *
 *  The value of answer variable would be 42.
 *
 *  @param keyPath The key path for which to return the corresponding value.
 *
 *  @return The value associated with keyPath, or nil if no value is associated with keyPath.
 */
- (REST_NULLABLE RESTGenericType(ObjectType, id))rest_objectForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
