//
//  ViewController.h
//  FastCheckiPhone
//
//  Created by Canzhi Ye on 4/11/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>
#import "JGBeacon.h"

@interface ViewController : UIViewController <JGBeaconDelegate, UIWebViewDelegate>
{
    UIWebView *webView;
    UIButton *loginWithEventbriteButton;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *loginWithEventbriteButton;
@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;

-(IBAction)loginWithEventbrite:(id)sender;

@end
