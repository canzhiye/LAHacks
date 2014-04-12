//
//  NSDictionary+BVJSONString.h
//  LOL
//
//  Created by Canzhi Ye on 3/1/14.
//  Copyright (c) 2014 facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;

@end
