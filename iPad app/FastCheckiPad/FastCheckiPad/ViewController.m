//
//  ViewController.m
//  FastCheckiPad
//
//  Created by Canzhi Ye on 4/11/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Event.h"
#import "UIImageView+WebCache.h"
#import "sendgrid.h"

const int kEventsTableViewTag = 0;
const int kSignedInTableViewTag = 1;
const int kNotSignedInTableViewTag = 2;
NSString *kPassword = @"HelloJuniorYear2012";

@interface ViewController ()
@property (nonatomic) JGBeacon *beacon;

@end

@implementation ViewController
@synthesize eventsTableView, signedInTableView, notSignedInTableView;

- (void)viewDidLoad
{
    
    arrayOfEvents = [[NSMutableArray alloc]init];
    arrayOfSignedIn = [[NSMutableArray alloc]init];
    arrayOfNotSignedIn = [[NSMutableArray alloc]init];
    eventsTableView.tag = kEventsTableViewTag;
    signedInTableView.tag = kSignedInTableViewTag;
    notSignedInTableView.tag = kNotSignedInTableViewTag;
    
    currentIndex = 0;
    
    self.navigationController.navigationBar.hidden = YES;
    //fuck us
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconSendingAndReceiving;
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken.length > 0) {
        [self loadEventDataWithAccessToken:accessToken];
        [self loadAttendeesWithAccessToken:accessToken];
    }
    else {
        UIWebView* webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=6DFNDX6C6HYXX5IY33"]];
        webView.delegate = self;
        [webView loadRequest:request];
        [self.view addSubview:webView];
    }
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)receivedData:(NSData *)data{
    NSString *dataString = [NSString stringWithFormat:@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    Firebase *f = [[Firebase alloc] initWithUrl:@"https://luminous-fire-5364.firebaseio.com/"];
    //NSString *eventbriteID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    Person *person = [[Person alloc] init];
    person.userID = [d objectForKey:@"id"];
    person.name = [d objectForKey:@"name"];
    person.email = [d objectForKey:@"email"];
    
    NSMutableDictionary *ok = [[NSMutableDictionary alloc]init];
    [ok setObject:@{@"name":person.name, @"check_in":@YES,@"email":person.email} forKey:person.userID];
    
    [[f childByAppendingPath:@"id"] updateChildValues:ok];
    
    [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"UPDATED %@ -> %@", snapshot.name, snapshot.value);
    }];
    
    
    [arrayOfSignedIn addObject:person];
    [signedInTableView reloadData];
    
    for (int i = 0; i < arrayOfNotSignedIn.count; i++) {
        Person *p = [arrayOfNotSignedIn objectAtIndex:i];
        NSLog(@"%@",p.email);
        if ([p.email isEqualToString:person.email]) {
            [arrayOfNotSignedIn removeObject:p];
        }
    }
    
    [notSignedInTableView reloadData];
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
        
        [self loadEventDataWithAccessToken:accessToken];
        [self loadAttendeesWithAccessToken:accessToken];
        
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
-(void)loadEventDataWithAccessToken:(NSString*)s
{
    NSString *accessToken = s;

    NSData *data0 = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/users/me/?token=%@",accessToken]]];
    NSError *error = nil;
    NSDictionary *resultsDictionary0 = [NSJSONSerialization JSONObjectWithData:data0 options:kNilOptions error:&error];
    userID = [resultsDictionary0 objectForKey:@"id"];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/users/%@/owned_events/?token=%@",userID,accessToken]]];
    NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"RESULTS MOTHA FUCKA %@",resultsDictionary);
    NSArray *fuckinArray = [resultsDictionary objectForKey:@"events"];
    
    for (int i = 0;i < fuckinArray.count; i++) {
        Event *event = [[Event alloc]init];
        NSDictionary *d = [[resultsDictionary objectForKey:@"events"] objectAtIndex:i];
        event.name = [[d objectForKey:@"name"]objectForKey:@"text"];
        event.logo_url = [d objectForKey:@"logo_url"];
        event.registrants = [[[d objectForKey:@"ticket_classes"] objectAtIndex:0] objectForKey:@"quantity_sold"];
        event.eventID = [d objectForKey:@"id"];
        [arrayOfEvents addObject:event];
    }
    
    [eventsTableView reloadData];
}
-(void)loadAttendeesWithAccessToken:(NSString*)s
{
    Event *event = [arrayOfEvents objectAtIndex:currentIndex];
    NSString *eventID = event.eventID;
    
    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/events/%@/attendees/?token=%@",eventID,s]]];
    NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"RESULTS MOTHA FUCKA %@",resultsDictionary);
    NSArray *attendees = [resultsDictionary objectForKey:@"attendees"];
    
    for (int i = 0; i < attendees.count; i++) {
        Person *person = [[Person alloc] init];
        person.userID = [[attendees objectAtIndex:i] objectForKey:@"id"];
        NSString *firstName = [[[attendees objectAtIndex:i] objectForKey:@"profile"]objectForKey:@"first_name"];
        NSString *lastName = [[[attendees objectAtIndex:i] objectForKey:@"profile"]objectForKey:@"last_name"];
        person.email = [[[attendees objectAtIndex:i]objectForKey:@"profile"] objectForKey:@"email"];
        person.name = [firstName stringByAppendingString:[NSString stringWithFormat:@" %@",lastName]];
        
        if (![arrayOfSignedIn containsObject:person]) {
            [arrayOfNotSignedIn addObject:person];
        }
        NSLog(@"%@",arrayOfNotSignedIn);
    }
}
#pragma  mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kEventsTableViewTag) {
        return 60;
    }
    else if (tableView.tag == kSignedInTableViewTag) {
        return 60;
    }
    else if (tableView.tag == kNotSignedInTableViewTag) {
        return 60;
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
        Event *event = [arrayOfEvents objectAtIndex:indexPath.row];
        NSString *urlString = event.logo_url;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        imageView.layer.cornerRadius = imageView.frame.size.height/2;
        imageView.layer.masksToBounds = YES;
        [imageView setImageWithURL:[NSURL URLWithString:urlString]];
        [cell addSubview:imageView];
        cell.textLabel.text= event.name;
    }
    else if (tableView.tag == kSignedInTableViewTag) {
        Person *person = [[Person alloc] init];
        person = [arrayOfSignedIn objectAtIndex:indexPath.row];
        cell.textLabel.text = person.name;
    }
    else if (tableView.tag == kNotSignedInTableViewTag) {
        Person *person = [[Person alloc] init];
        person = [arrayOfNotSignedIn objectAtIndex:indexPath.row];
        cell.textLabel.text = person.name;
    }
    
    return cell;
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Email Hacker" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = indexPath.row;
    [actionSheet showFromRect:CGRectMake(0, 0, 120, 40) inView:[tableView cellForRowAtIndexPath:indexPath] animated:YES];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        Person *person = [arrayOfSignedIn objectAtIndex:actionSheet.tag];
        
       //send email via sendgrid
        sendgrid *msg = [sendgrid user:@"canzhiye" andPass:kPassword];
        
        msg.to = person.email;
        msg.subject = @"LA Hacks";
        msg.from = @"canzhiye@gmail.com";
        msg.text = @"hello world";
        msg.html = @"<h1>hello world!</h1>";
        
        [msg sendWithWeb];
    }
    //NSLog(@"button %ld clicked", (long)buttonIndex);
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [actionSheet.subviews enumerateObjectsUsingBlock:^(id _currentView, NSUInteger idx, BOOL *stop) {
        if ([_currentView isKindOfClass:[UIButton class]]) {
            [((UIButton *)_currentView).titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
            // OR
            //[((UIButton *)_currentView).titleLabel setFont:[UIFont fontWithName:@"Exo2-SemiBold" size:17]];
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
