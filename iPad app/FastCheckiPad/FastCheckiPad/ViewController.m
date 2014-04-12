//
//  ViewController.m
//  FastCheckiPad
//
//  Created by Canzhi Ye on 4/11/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import "ViewController.h"
const int kEventsTableViewTag = 0;
const int kSignedInTableViewTag = 1;
const int kNotSignedInTableViewTag = 2;

@interface ViewController ()
@property (nonatomic) JGBeacon *beacon;

@end

@implementation ViewController
@synthesize eventsTableView, signedInTableView, notSignedInTableView;

- (void)viewDidLoad
{
    self.navigationController.navigationBar.hidden = YES;
    //fuck us
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconReceivingOnly;
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken.length > 0) {
        
    }
    else {
        UIWebView* webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=6DFNDX6C6HYXX5IY33"]];
        webView.delegate = self;
        [webView loadRequest:request];
        [self.view addSubview:webView];
    }
    
    arrayOfEvents = [[NSMutableArray alloc]init];
    arrayOfSignedIn = [[NSMutableArray alloc]init];
    arrayOfNotSignedIn = [[NSMutableArray alloc]init];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)receivedData:(NSData *)data{
    //[NSString stringWithFormat:@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    Firebase *f = [[Firebase alloc] initWithUrl:@"https://luminous-fire-5364.firebaseio.com/"];
    NSString *eventbriteID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[f childByAppendingPath:eventbriteID] setValue:@{@"checked_in": @YES}];
}

-(void)connectedToBeacon:(NSUUID *)identifier{
    
}

-(void)disconnectedFromBeacon:(NSUUID *)identifier{
    
}

#pragma mark UIWebView Delegates
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *url = [request.URL absoluteString];
    if ([url hasPrefix:@"http://canzhiye.com/"]) {
        NSDictionary *dictionary = [self urlParams:url];
        NSString *accessToken = [dictionary objectForKey:@"access_token"];
        
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [webView removeFromSuperview];
        
        NSData *data0 = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/users/me/?%@",accessToken]]];
        NSError *error = nil;
        NSDictionary *resultsDictionary0 = [NSJSONSerialization JSONObjectWithData:data0 options:kNilOptions error:&error];
        NSString *userID = [resultsDictionary0 objectForKey:@"id"];
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/users/%@/owned_events/",userID]]];
        NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",resultsDictionary);
        
        NSLog(@"done");
        return NO;
    }
    return YES;
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
#pragma  mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kEventsTableViewTag) {
        return 44;
    }
    else if (tableView.tag == kSignedInTableViewTag) {
        return 44;
    }
    else if (tableView.tag == kNotSignedInTableViewTag) {
        return 44;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kEventsTableViewTag) {
        return arrayOfEvents.count;
    }
    else if (tableView.tag == kSignedInTableViewTag) {
        return arrayOfSignedIn.count;
    }
    else if (tableView.tag == kNotSignedInTableViewTag) {
        return arrayOfNotSignedIn.count;
    }
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    if (tableView.tag == kEventsTableViewTag) {
        
    }
    else if (tableView.tag == kSignedInTableViewTag) {
        
    }
    else if (tableView.tag == kNotSignedInTableViewTag) {
        
    }
    
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
