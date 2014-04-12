//
//  Person.h
//  FastCheckiPad
//
//  Created by Canzhi Ye on 4/12/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
{
    NSString *name;
    NSString *userID;
    NSString *email;
    NSString *dateCreated;
    NSString *tshirt;
}
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *dateCreated;
@property (nonatomic) NSString *tshirt;
@end
