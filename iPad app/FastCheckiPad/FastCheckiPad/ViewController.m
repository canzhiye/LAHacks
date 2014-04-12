//
//  ViewController.m
//  FastCheckiPad
//
//  Created by Canzhi Ye on 4/11/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import "ViewController.h"

static NSString * const kUUID = @"00000000-0000-0000-0000-000000000000";
static NSString * const kIdentifier = @"HiBeacons";

static NSString * const kOperationCellIdentifier = @"OperationCell";
static NSString * const kBeaconCellIdentifier = @"BeaconCell";

static NSString * const kMonitoringOperationTitle = @"Monitoring";
static NSString * const kAdvertisingOperationTitle = @"Advertising";
static NSString * const kRangingOperationTitle = @"Ranging";
static NSUInteger const kNumberOfSections = 2;
static NSUInteger const kNumberOfAvailableOperations = 3;
static CGFloat const kOperationCellHeight = 44;
static CGFloat const kBeaconCellHeight = 52;
static NSString * const kBeaconSectionTitle = @"Looking for beacons...";
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 12};
static NSString * const kBeaconsHeaderViewIdentifier = @"BeaconsHeader";

static void * const kMonitoringOperationContext = (void *)&kMonitoringOperationContext;
static void * const kRangingOperationContext = (void *)&kRangingOperationContext;

typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTOperationsSection,
    NTDetectedBeaconsSection
};

typedef NS_ENUM(NSUInteger, NTOperationsRow) {
    NTMonitoringRow,
    NTAdvertisingRow,
    NTRangingRow
};

@interface ViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, weak) UISwitch *monitoringSwitch;
@property (nonatomic, weak) UISwitch *advertisingSwitch;
@property (nonatomic, weak) UISwitch *rangingSwitch;
@property (nonatomic, unsafe_unretained) void *operationContext;
@property (nonatomic) JGBeacon *beacon;

@end

@implementation ViewController
@synthesize connectedLabel;
@synthesize beaconTableView;

- (void)viewDidLoad
{
    //fuck us
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconReceivingOnly;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)receivedData:(NSData *)data{
    connectedLabel.text = [NSString stringWithFormat:@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
}

-(void)connectedToBeacon:(NSUUID *)identifier{
    
}

-(void)disconnectedFromBeacon:(NSUUID *)identifier{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
