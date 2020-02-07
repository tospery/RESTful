//
//  NSError+RESTResponse.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import <Foundation/Foundation.h>
#import <RESTful/RESTUtilities.h>

NS_ASSUME_NONNULL_BEGIN

@class RESTResponse;

extern NSString * const RESTResponseKey;

@interface NSError (RESTResponse)

- (instancetype)rest_errorWithUnderlyingResponse:(REST_NULLABLE RESTResponse *)response;

@property (nonatomic, readonly, REST_NULLABLE) RESTResponse *rest_response;

@end

NS_ASSUME_NONNULL_END
