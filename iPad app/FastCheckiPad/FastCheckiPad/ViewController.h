//
//  ViewController.h
//  FastCheckiPad
//
//  Created by Canzhi Ye on 4/11/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "JGBeacon.h"

@interface ViewController : UIViewController <UIWebViewDelegate,JGBeaconDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSMutableArray *arrayOfEvents;
    NSMutableArray *arrayOfSignedIn;
    NSMutableArray *arrayOfNotSignedIn;
    
    NSString *userID;
    
    int currentIndex;
}
@property (nonatomic, retain) IBOutlet UITableView *eventsTableView;
@property (nonatomic, retain) IBOutlet UITableView *signedInTableView;
@property (nonatomic, retain) IBOutlet UITableView *notSignedInTableView;

@end
