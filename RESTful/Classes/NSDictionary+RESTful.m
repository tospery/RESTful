//
//  NSDictionary+RESTful.m
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#import "NSDictionary+RESTful.h"

@implementation NSDictionary (RESTful)

- (id)rest_objectForKeyPath:(NSString *)keyPath {
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    id object = self;
    
    for (NSString *key in keys) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            object = object[key];
        } else {
            object = nil;
            break;
        }
    }
    
    return object;
}

@end
