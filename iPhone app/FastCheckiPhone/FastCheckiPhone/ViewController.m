//
//  ViewController.m
//  FastCheckiPhone
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
@property (nonatomic) JGBeacon* beacon;

@end

@implementation ViewController
@synthesize webView;
@synthesize loginWithEventbriteButton;
//@synthesize eventbriteIDLabel;
@synthesize beaconTableView;

#pragma mark all the bluetooth shit

-(void)receivedData:(NSData *)data{
}
-(void)connectedToBeacon:(NSUUID *)identifier{
}
-(void)disconnectedFromBeacon:(NSUUID *)identifier{
}
-(void)sendData {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    [self.beacon queueDataToSend:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
}
#pragma mark fuck
- (void)viewDidLoad
{
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconSendingOnly;
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken.length > 0) {
        loginWithEventbriteButton.alpha = 0;
        [self getEventbriteID];
    }
    else {
    }
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (NSDictionary*)urlParams:(NSString*)url {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    url = [[url componentsSeparatedByString:@"#"] objectAtIndex:1];
    for (NSString *param in [url componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }
    return params;
}
-(IBAction)loginWithEventbrite:(id)sender
{
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=6DFNDX6C6HYXX5IY33"]];
    webView.delegate = self;
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

#pragma mark UIWebView Delegates
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *url = [request.URL absoluteString];
    if ([url hasPrefix:@"http://canzhiye.com/"]) {
        NSDictionary *dictionary = [self urlParams:url];
        
        [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"access_token"] forKey:@"access_token"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [webView removeFromSuperview];
        [loginWithEventbriteButton removeFromSuperview];
        [self getEventbriteID];
        NSLog(@"done");
        return NO;
    }
    return YES;
}
-(void)getEventbriteID
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://www.eventbriteapi.com/v3/users/me/?token=%@",accessToken];
    NSError *error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"results %@",resultsDictionary);
    
    [self sendData];
}

-(void)webViewDidFinishLoad:(UIWebView *)wv
{
    //NSString *urlString = [[NSString alloc] initWithFormat:@"%@",wv.request.URL];
    //NSLog(@"url %@",urlString);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
