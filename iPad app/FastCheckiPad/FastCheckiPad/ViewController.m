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

const int kEventsTableViewTag = 0;
const int kSignedInTableViewTag = 1;
const int kNotSignedInTableViewTag = 2;

#define COLOR_MEDIUM_GRAY [UIColor colorWithRed:(84.0/255.0) green:(84.0/255.0) blue:(84.0/255.0) alpha:1.0]
#define COLOR_BG_GRAY [UIColor colorWithRed:(235.0/255.0) green:(235.0/255.0) blue:(235.0/255.0) alpha:1.0]
#define COLOR_LINE_GRAY [UIColor colorWithRed:(180.0/255.0) green:(180.0/255.0) blue:(180.0/255.0) alpha:1.0]

@interface ViewController ()
@property (nonatomic) JGBeacon *beacon;

@end

@implementation ViewController
@synthesize eventsTableView, signedInTableView, notSignedInTableView;

- (void)viewDidLoad {
    arrayOfEvents = [[NSMutableArray alloc]init];
    arrayOfSignedIn = [[NSMutableArray alloc]init];
    arrayOfNotSignedIn = [[NSMutableArray alloc]init];
    eventsTableView.tag = kEventsTableViewTag;
    signedInTableView.tag = kSignedInTableViewTag;
    notSignedInTableView.tag = kNotSignedInTableViewTag;
    
    currentIndex = 0;
    
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconSendingAndReceiving;
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken.length > 0) {
        [self loadEventDataWithAccessToken:accessToken];
        [self loadAttendeesWithAccessToken:accessToken];
    } else {
        UIWebView* webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=6DFNDX6C6HYXX5IY33"]];
        webView.delegate = self;
        [webView loadRequest:request];
        [self.view addSubview:webView];
    }
    
    [super viewDidLoad];
    
    //tableViewOne.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    tableViewTwo.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    tableViewThree.contentInset = tableViewTwo.contentInset;
    tableViewTwo.backgroundColor = COLOR_BG_GRAY;
    tableViewThree.backgroundColor = COLOR_BG_GRAY;
    
    tableViewOne.separatorColor = COLOR_LINE_GRAY;
    tableViewTwo.separatorColor = COLOR_LINE_GRAY;
    tableViewThree.separatorColor = COLOR_LINE_GRAY;

    tableViewOne.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    tableViewTwo.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    tableViewThree.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    tableViewOne.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableViewTwo.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableViewThree.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *lineOne = [[UIView alloc] initWithFrame:CGRectMake(341.5683, 0, 0.5, 768)];
    lineOne.backgroundColor = COLOR_LINE_GRAY;
    [self.navigationController.view addSubview:lineOne];
    
    UIView *lineTwo = [[UIView alloc] initWithFrame:CGRectMake(341+342, 0, 0.5, 768)];
    lineTwo.backgroundColor = COLOR_LINE_GRAY;
    [self.navigationController.view addSubview:lineTwo];
    
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 341, 44)];
    labelOne.textAlignment = NSTextAlignmentCenter;
    labelOne.textColor = COLOR_MEDIUM_GRAY;
    labelOne.text = @"Your Events";
    labelOne.font = [UIFont fontWithName:@"OpenSans" size:17];
    [self.navigationController.view addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(341, 20, 341, 44)];
    labelTwo.textAlignment = NSTextAlignmentCenter;
    labelTwo.textColor = COLOR_MEDIUM_GRAY;
    labelTwo.text = @"Signed in users";
    labelTwo.font = [UIFont fontWithName:@"OpenSans" size:17];
    [self.navigationController.view addSubview:labelTwo];
    
    UILabel *labelThree = [[UILabel alloc] initWithFrame:CGRectMake(683, 20, 341, 44)];
    labelThree.textAlignment = NSTextAlignmentCenter;
    labelThree.textColor = COLOR_MEDIUM_GRAY;
    labelThree.text = @"Other registered users";
    labelThree.font = [UIFont fontWithName:@"OpenSans" size:17];
    [self.navigationController.view addSubview:labelThree];
}

-(void)receivedData:(NSData *)data{
    //NSString *dataString = [NSString stringWithFormat:@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    //Firebase *f = [[Firebase alloc] initWithUrl:@"https://luminous-fire-5364.firebaseio.com/"];
    //NSString *eventbriteID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    Person *person = [[Person alloc] init];
    person.userID = [d objectForKey:@"id"];
    person.name = [d objectForKey:@"name"];
    person.email = [d objectForKey:@"email"];
    
    NSMutableDictionary *ok = [[NSMutableDictionary alloc]init];
    [ok setObject:@{@"name":person.name, @"check_in":@YES,@"email":person.email} forKey:person.userID];
    
    //[[f childByAppendingPath:@"id"] updateChildValues:ok];
    
    //[f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
    //    NSLog(@"UPDATED %@ -> %@", snapshot.name, snapshot.value);
    //}];
    
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

- (void)loadEventDataWithAccessToken:(NSString*)accessToken {
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

-(void)loadAttendeesWithAccessToken:(NSString*)s {
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

#pragma  mark UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 17, 331, 19)];
    title.textColor = COLOR_MEDIUM_GRAY;
    title.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
    [cell.contentView addSubview:title];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 36, 331, 16)];
    text.textColor = COLOR_MEDIUM_GRAY;
    text.font = [UIFont fontWithName:@"OpenSans" size:12];
    [cell.contentView addSubview:text];
    
    if (tableView.tag == kEventsTableViewTag) {
        Event *event = [arrayOfEvents objectAtIndex:indexPath.row];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12.5, 45, 45)];
        imageView.layer.cornerRadius = imageView.frame.size.height/2;
        imageView.layer.masksToBounds = YES;
        [imageView setImageWithURL:[NSURL URLWithString:event.logo_url]];
        [cell addSubview:imageView];
        
        title.frame = CGRectMake(64, 17, 331, 19);
        text.frame = CGRectMake(64, 36, 331, 17);
        title.text = event.name;
        text.text = @"50% signed in";
    } else if (tableView.tag == kSignedInTableViewTag) {
        Person *person = [[Person alloc] init];
        
        person = [arrayOfSignedIn objectAtIndex:indexPath.row];
        
        title.text = [NSString stringWithFormat:@"%@ - XS",person.name];
        text.text = @"";
    } else if (tableView.tag == kNotSignedInTableViewTag) {
        Person *person = [[Person alloc] init];
        
        person = [arrayOfNotSignedIn objectAtIndex:indexPath.row];
        
        title.text = person.name;
        text.text = @"Signed up on 4/6/14 @ 3:23PM";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Hacker",nil];
    [actionSheet showFromRect:CGRectMake(0, 0, 120, 40) inView:[tableView cellForRowAtIndexPath:indexPath] animated:YES];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
       //do shit to the backend
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
