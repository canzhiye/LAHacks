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

@interface ViewController : UIViewController <UIWebViewDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate, JGBeaconDelegate>
{
    UILabel *connectedLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *connectedLabel;
@property (nonatomic, retain) IBOutlet UITableView *beaconTableView;
@end
