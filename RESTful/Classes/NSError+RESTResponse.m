//
//  NSError+RESTResponse.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "NSError+RESTResponse.h"
#import <Mantle/NSDictionary+MTLManipulationAdditions.h>

NSString *const RESTResponseKey = @"RESTResponse";

@implementation NSError (RESTResponse)

- (instancetype)rest_errorWithUnderlyingResponse:(RESTResponse *)response {
    if (response == nil) {
        return self;
    }
    
    NSDictionary *userInfo = @{RESTResponseKey: response};
    userInfo = [userInfo mtl_dictionaryByAddingEntriesFromDictionary:self.userInfo];
    
    return [self.class errorWithDomain:self.domain code:self.code userInfo:userInfo];
}

- (RESTResponse *)rest_response {
    return self.userInfo[RESTResponseKey];
}

@end
