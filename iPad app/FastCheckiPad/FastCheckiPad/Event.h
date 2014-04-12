//
//  Event.h
//  FastCheckiPad
//
//  Created by Canzhi Ye on 4/12/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
    NSString *logo_url;
    NSString *name;
    NSNumber *registrants;
    NSString *eventID;
}
@property (nonatomic) NSString *logo_url;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *registrants;
@property (nonatomic) NSString *eventID;

@end
