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
        
        Event *event = [arrayOfEvents objectAtIndex:currentIndex];
        NSString *eventID = event.eventID;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fastcheck.kywu.org/events/%@/users",eventID]]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
        
        if(connection) {
            NSLog(@"Connection Successful");
        } else {
            NSLog(@"Connection could not be made");
        }
    } else {
        UIWebView* webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=6DFNDX6C6HYXX5IY33"]];
        webView.delegate = self;
        [webView loadRequest:request];
        [self.view addSubview:webView];
    }
    
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

    [super viewDidLoad];
}

-(void)receivedData:(NSData *)data{
    NSLog(@"receivedData from iPhone %@",[NSString stringWithFormat:@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]]);
    NSError *error = nil;
    //Firebase *f = [[Firebase alloc] initWithUrl:@"https://luminous-fire-5364.firebaseio.com/"];
    //NSString *eventbriteID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    Person *person = [[Person alloc] init];
    
    for (int i = 0; i < arrayOfNotSignedIn.count; i++) {
        Person *p = [arrayOfNotSignedIn objectAtIndex:i];
        
        if ([p.email isEqualToString:[d objectForKey:@"email"]]) {
            person = p;
            person.userID = [d objectForKey:@"id"];
            break;
        }
    }
    if (person.email==nil) {
        return;
    }
    
    Event *event = [arrayOfEvents objectAtIndex:currentIndex];
    NSString *eventID = event.eventID;
    
    NSString *uid = person.userID;
    userID = uid;
    NSString *name = person.name;
    NSString *email = person.email;
    NSString *shirt = person.tshirt;
    NSString *event_name = event.name;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%@&name=%@&email=%@&shirt=%@&event_name=%@",uid,name,email,shirt,event_name];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fastcheck.kywu.org/events/%@",eventID]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    
    if(connection) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
    
    for (int i = 0; i < arrayOfNotSignedIn.count; i++) {
        Person *p = [arrayOfNotSignedIn objectAtIndex:i];
        if ([p.email isEqualToString:person.email]) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
            person.dateCreated = [NSString stringWithFormat:@"%.0f",timeInterval];
            
            [arrayOfSignedIn addObject:person];
        }
    }
    
    [signedInTableView reloadData];
    [eventsTableView reloadData];
    
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

#pragma mark URLConnection shit
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    
    NSString *urlString = [NSString stringWithFormat:@"%@",connection.currentRequest.URL];
    Event *event = [arrayOfEvents objectAtIndex:currentIndex];
    NSString *eventID = event.eventID;
    
    NSString*compare = [NSString stringWithFormat:@"http://fastcheck.kywu.org/events/%@/users",eventID];
    
    if ([urlString isEqualToString:compare]) {
        NSError *error = nil;
        NSDictionary* newDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"did Receive Data: %@", newDict);
        NSLog(@"error %@", error);
        if (!error && [[newDict objectForKey:@"success"] boolValue]==YES) {
            NSArray *array = [newDict objectForKey:@"users"];
            for (int i = 0; i < array.count; i++) {
                Person *person = [[Person alloc]init];
                person.userID = [[array objectAtIndex:i] objectForKey:@"uid"];
                person.name = [[array objectAtIndex:i] objectForKey:@"name"];
                person.email = [[array objectAtIndex:i] objectForKey:@"email"];
                person.tshirt = [[array objectAtIndex:i] objectForKey:@"shirt"];
                person.dateCreated = [NSString stringWithFormat:@"%@",[[array objectAtIndex:i] objectForKey:@"timestamp"]];
                person.completed = [[[array objectAtIndex:i] objectForKey:@"completed"] boolValue];
                
                [arrayOfSignedIn addObject:person];
                for (int i = 0; i < arrayOfNotSignedIn.count; i++) {
                    Person *p = [arrayOfNotSignedIn objectAtIndex:i];
                    if ([person.email isEqualToString:p.email]) {
                        [arrayOfNotSignedIn removeObject:person];
                    }
                }
                [arrayOfNotSignedIn removeObject:person];
//                if ([[[array objectAtIndex:i] objectForKey:@"completed"] boolValue] == YES) {
//                }
//                else {
//                    [arrayOfNotSignedIn addObject:person];
//                }
            }
        }
        else{
        }
        [eventsTableView reloadData];
        [signedInTableView reloadData];
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //This method , you can use to receive the error report in case of connection is not made to server.
    NSLog(@"did Receive Error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"did Finish Loading: %@", connection);
    
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
        person.userID = userID;
        NSString *firstName = [[[attendees objectAtIndex:i] objectForKey:@"profile"]objectForKey:@"first_name"];
        NSString *lastName = [[[attendees objectAtIndex:i] objectForKey:@"profile"]objectForKey:@"last_name"];
        person.email = [[[attendees objectAtIndex:i]objectForKey:@"profile"] objectForKey:@"email"];
        person.name = [firstName stringByAppendingString:[NSString stringWithFormat:@" %@",lastName]];
        person.dateCreated = [[attendees objectAtIndex:i] objectForKey:@"created"];
        
        if ([[[[attendees objectAtIndex:i] objectForKey:@"answers"] firstObject] objectForKey:@"answer"] == nil) {
            person.tshirt = @"M";
        } else {
            person.tshirt = [[[[attendees objectAtIndex:i] objectForKey:@"answers"] firstObject] objectForKey:@"answer"];
        }
        //building the not signed in list
        if (![arrayOfSignedIn containsObject:person]) {
            if ([[[attendees objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"Attending"]) {
                [arrayOfNotSignedIn addObject:person];
            }
        }
        NSLog(@"%@",arrayOfNotSignedIn);
    }
    if (attendees.count%50==0) {
        int pageNumber = 1+((int)attendees.count/(int)50);
        [self paginateWithPageNumber:pageNumber];
    }
    [notSignedInTableView reloadData];
}
-(void)paginateWithPageNumber:(int)pageNumber
{
    
}
- (NSString *)dateDiff:(NSString *)origDate {
    NSDate *oldDate = [NSDate dateWithTimeIntervalSince1970:[origDate integerValue]];
    NSDate *newDate = [NSDate date];
    double ti = [oldDate timeIntervalSinceDate:newDate];
    ti = ti * -1;
    
    if (ti < 1) {
        return @"1 second ago";
    } else if (ti < 60) {
        return [NSString stringWithFormat:@"%.0f seconds ago",ti];
    } else if (ti < 3600) {
        NSInteger diff = round(ti / 60);
        NSString *plural = @"s";
        if (diff == 1) { plural = @""; }
        return [NSString stringWithFormat:@"%ld minute%@ ago", (long)diff,plural];
    } else if (ti < 86400) {
        NSInteger diff = round(ti / 60 / 60);
        NSString *plural = @"s";
        if (diff == 1) { plural = @""; }
        return[NSString stringWithFormat:@"%ld hour%@ ago", (long)diff,plural];
    } else if (ti < 604800) {
        NSInteger diff = round(ti / 60 / 60 / 24);
        NSString *plural = @"s";
        if (diff == 1) { plural = @""; }
        return[NSString stringWithFormat:@"%ld day%@ ago", (long)diff,plural];
    } else if (ti < 2629740) {
        NSInteger diff = round(ti / 60 / 60 / 24 / 7);
        NSString *plural = @"s";
        if (diff == 1) { plural = @""; }
        return[NSString stringWithFormat:@"%ld week%@ ago", (long)diff,plural];
    } else if (ti < 31556900) {
        NSInteger diff = round(ti / 60 / 60 / 24 / 7 / 4.348);
        NSString *plural = @"s";
        if (diff == 1) { plural = @""; }
        return[NSString stringWithFormat:@"%ld month%@ ago", (long)diff,plural];
    } else if (ti < 315569000) {
        NSInteger diff = round(ti / 60 / 60 / 24 / 365);
        NSString *plural = @"s";
        if (diff == 1) { plural = @""; }
        return[NSString stringWithFormat:@"%ld year%@ ago", (long)diff,plural];
    } else {
        return @"a long time ago";
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
        float percent = 100*((float)arrayOfSignedIn.count/((float)(arrayOfSignedIn.count+arrayOfNotSignedIn.count)));
        NSLog(@"%lu",arrayOfSignedIn.count/(arrayOfSignedIn.count+arrayOfNotSignedIn.count));
        text.text = [NSString stringWithFormat:@"%2.0f%@",percent,@"% signed in"];
    } else if (tableView.tag == kSignedInTableViewTag) {
        Person *person = [[Person alloc] init];
        
        person = [arrayOfSignedIn objectAtIndex:indexPath.row];
        
        title.text = [NSString stringWithFormat:@"%@ - %@",person.name,person.tshirt];
        NSString *unixTimestamp = person.dateCreated;
        text.text = [self dateDiff:unixTimestamp];
        
        if (person.completed == YES) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12.5, 45, 45)];
            imageView.layer.cornerRadius = imageView.frame.size.height/2;
            imageView.layer.masksToBounds = YES;
            [imageView setImageWithURL:[NSURL URLWithString:@"http://ebmedia.eventbrite.com/s3-build/images/5762279/31072625403/1/logo.png"]];
            [cell addSubview:imageView];
            
            [title setTextColor:[UIColor grayColor]];
            [text setTextColor:[UIColor grayColor]];
        }
        
    } else if (tableView.tag == kNotSignedInTableViewTag) {
        Person *person = [[Person alloc] init];
        person = [arrayOfNotSignedIn objectAtIndex:indexPath.row];
        
        // ex: 2014-04-12T21:37:02Z
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'";
        formatter.locale = [NSLocale currentLocale];
        date = [formatter dateFromString:person.dateCreated];
        
        NSDateFormatter *currentFormat = [[NSDateFormatter alloc]init];
        [currentFormat setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
        currentFormat.dateFormat = @"MM'/'dd'/'YY' @ 'h':'mm a";
        
        title.text = person.name;
        text.text = [currentFormat stringFromDate:date];
    }
    
    return cell;
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == kSignedInTableViewTag) {
        
        Person *person = [arrayOfSignedIn objectAtIndex:indexPath.row];
        if (person.completed == NO) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Email Hacker" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Ready for Pickup",nil];
            actionSheet.tag = indexPath.row;
            [actionSheet showFromRect:CGRectMake(0, 0, 120, 40) inView:[tableView cellForRowAtIndexPath:indexPath] animated:YES];
        }
    }
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
        NSString *htmlString = [NSString stringWithFormat:@"<!-- Inliner Build Version 4380b7741bb759d6cb997545f3add21ad48f010b --><!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'><html xmlns='http://www.w3.org/1999/xhtml' xmlns='http://www.w3.org/1999/xhtml'> <head> <meta http-equiv='Content-Type' content='text/html; charset=utf-8' /> <meta name='viewport' content='width=device-width' /> </head> <body style='width: 100%% !important; min-width: 100%%; -webkit-text-size-adjust: 100%%; -ms-text-size-adjust: 100%%; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0; padding: 0;'><style type='text/css'>a:hover {color: #2795b6 !important;}a:active {color: #2795b6 !important;}a:visited {color: #2ba6cb !important;}h1 a:active {color: #2ba6cb !important;}h2 a:active {color: #2ba6cb !important;}h3 a:active {color: #2ba6cb !important;}h4 a:active {color: #2ba6cb !important;}h5 a:active {color: #2ba6cb !important;}h6 a:active {color: #2ba6cb !important;}h1 a:visited {color: #2ba6cb !important;}h2 a:visited {color: #2ba6cb !important;}h3 a:visited {color: #2ba6cb !important;}h4 a:visited {color: #2ba6cb !important;}h5 a:visited {color: #2ba6cb !important;}h6 a:visited {color: #2ba6cb !important;}table.button:hover td {background: #2795b6 !important;}table.button:visited td {background: #2795b6 !important;}table.button:active td {background: #2795b6 !important;}table.button:hover td a {color: #fff !important;}table.button:visited td a {color: #fff !important;}table.button:active td a {color: #fff !important;}table.button:hover td {background: #2795b6 !important;}table.tiny-button:hover td {background: #2795b6 !important;}table.small-button:hover td {background: #2795b6 !important;}table.medium-button:hover td {background: #2795b6 !important;}table.large-button:hover td {background: #2795b6 !important;}table.button:hover td a {color: #ffffff !important;}table.button:active td a {color: #ffffff !important;}table.button td a:visited {color: #ffffff !important;}table.tiny-button:hover td a {color: #ffffff !important;}table.tiny-button:active td a {color: #ffffff !important;}table.tiny-button td a:visited {color: #ffffff !important;}table.small-button:hover td a {color: #ffffff !important;}table.small-button:active td a {color: #ffffff !important;}table.small-button td a:visited {color: #ffffff !important;}table.medium-button:hover td a {color: #ffffff !important;}table.medium-button:active td a {color: #ffffff !important;}table.medium-button td a:visited {color: #ffffff !important;}table.large-button:hover td a {color: #ffffff !important;}table.large-button:active td a {color: #ffffff !important;}table.large-button td a:visited {color: #ffffff !important;}table.secondary:hover td {background: #d0d0d0 !important; color: #555;}table.secondary:hover td a {color: #555 !important;}table.secondary td a:visited {color: #555 !important;}table.secondary:active td a {color: #555 !important;}table.success:hover td {background: #457a1a !important;}table.alert:hover td {background: #970b0e !important;}table.facebook:hover td {background: #2d4473 !important;}table.twitter:hover td {background: #0087bb !important;}table.google-plus:hover td {background: #CC0000 !important;}@media only screen and (max-width: 600px) { table[class='body'] img { width: auto !important; height: auto !important; } table[class='body'] center { min-width: 0 !important; } table[class='body'] .container { width: 95%% !important; } table[class='body'] .row { width: 100%% !important; display: block !important; } table[class='body'] .wrapper { display: block !important; padding-right: 0 !important; } table[class='body'] .columns { table-layout: fixed !important; float: none !important; width: 100%% !important; padding-right: 0px !important; padding-left: 0px !important; display: block !important; } table[class='body'] .column { table-layout: fixed !important; float: none !important; width: 100%% !important; padding-right: 0px !important; padding-left: 0px !important; display: block !important; } table[class='body'] .wrapper.first .columns { display: table !important; } table[class='body'] .wrapper.first .column { display: table !important; } table[class='body'] table.columns td { width: 100%% !important; } table[class='body'] table.column td { width: 100%% !important; } table[class='body'] .columns td.one { width: 8.333333%% !important; } table[class='body'] .column td.one { width: 8.333333%% !important; } table[class='body'] .columns td.two { width: 16.666666%% !important; } table[class='body'] .column td.two { width: 16.666666%% !important; } table[class='body'] .columns td.three { width: 25%% !important; } table[class='body'] .column td.three { width: 25%% !important; } table[class='body'] .columns td.four { width: 33.333333%% !important; } table[class='body'] .column td.four { width: 33.333333%% !important; } table[class='body'] .columns td.five { width: 41.666666%% !important; } table[class='body'] .column td.five { width: 41.666666%% !important; } table[class='body'] .columns td.six { width: 50%% !important; } table[class='body'] .column td.six { width: 50%% !important; } table[class='body'] .columns td.seven { width: 58.333333%% !important; } table[class='body'] .column td.seven { width: 58.333333%% !important; } table[class='body'] .columns td.eight { width: 66.666666%% !important; } table[class='body'] .column td.eight { width: 66.666666%% !important; } table[class='body'] .columns td.nine { width: 75%% !important; } table[class='body'] .column td.nine { width: 75%% !important; } table[class='body'] .columns td.ten { width: 83.333333%% !important; } table[class='body'] .column td.ten { width: 83.333333%% !important; } table[class='body'] .columns td.eleven { width: 91.666666%% !important; } table[class='body'] .column td.eleven { width: 91.666666%% !important; } table[class='body'] .columns td.twelve { width: 100%% !important; } table[class='body'] .column td.twelve { width: 100%% !important; } table[class='body'] td.offset-by-one { padding-left: 0 !important; } table[class='body'] td.offset-by-two { padding-left: 0 !important; } table[class='body'] td.offset-by-three { padding-left: 0 !important; } table[class='body'] td.offset-by-four { padding-left: 0 !important; } table[class='body'] td.offset-by-five { padding-left: 0 !important; } table[class='body'] td.offset-by-six { padding-left: 0 !important; } table[class='body'] td.offset-by-seven { padding-left: 0 !important; } table[class='body'] td.offset-by-eight { padding-left: 0 !important; } table[class='body'] td.offset-by-nine { padding-left: 0 !important; } table[class='body'] td.offset-by-ten { padding-left: 0 !important; } table[class='body'] td.offset-by-eleven { padding-left: 0 !important; } table[class='body'] table.columns td.expander { width: 1px !important; } table[class='body'] .right-text-pad { padding-left: 10px !important; } table[class='body'] .text-pad-right { padding-left: 10px !important; } table[class='body'] .left-text-pad { padding-right: 10px !important; } table[class='body'] .text-pad-left { padding-right: 10px !important; } table[class='body'] .hide-for-small { display: none !important; } table[class='body'] .show-for-desktop { display: none !important; } table[class='body'] .show-for-small { display: inherit !important; } table[class='body'] .hide-for-desktop { display: inherit !important; } table[class='body'] .right-text-pad { padding-left: 10px !important; } table[class='body'] .left-text-pad { padding-right: 10px !important; }}</style> <table class='body' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; height: 100%%; width: 100%%; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='center' align='center' valign='top' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: center; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;'> <center style='width: 100%%; min-width: 580px;'> <table class='row header' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; background: #999999; padding: 0px;' bgcolor='#999999'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='center' align='center' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: center; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' valign='top'> <center style='width: 100%%; min-width: 580px;'> <table class='container' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: inherit; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 10px 0px 0px;' align='left' valign='top'> <table class='twelve columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='six sub-columns' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; min-width: 0px; width: 50%%; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 10px 10px 0px;' align='left' valign='top'> <img src='http://placehold.it/50x50' style='outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; width: auto; max-width: 100%%; float: left; clear: both; display: block;' align='left' /></td> <td class='six sub-columns last' align='right' style='text-align: right; vertical-align: middle; word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; min-width: 0px; width: 50%%; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px;' valign='middle'> <span class='template-label' style='color: #ffffff; font-weight: bold; font-size: 11px;'>Thanks for Signing up for LAHacks!</span> </td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table></center> </td> </tr></table><br /><table class='container' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: inherit; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'> <!-- content start --> <table class='row' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; display: block; padding: 0px;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 10px 0px 0px;' align='left' valign='top'> <table class='twelve columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px;' align='left' valign='top'> <h1 style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 1.3; word-break: normal; font-size: 40px; margin: 0; padding: 0;' align='left'>Hey %@!</h1> <p class='lead' style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 21px; font-size: 18px; margin: 0 0 10px; padding: 0;' align='left'>Glad that you're here for LAHacks!</p> <img width='580' height='300' src='http://ucla.sigmaetapi.com/wp-content/uploads/2013/03/videoThumbnail-865x471.png' style='outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; width: auto; max-width: 100%%; float: left; clear: both; display: block;' align='left' /></td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table><table class='row callout' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; display: block; padding: 0px;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 10px 0px 0px;' align='left' valign='top'> <table class='twelve columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='panel' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; background: #ECF8FF; margin: 0; padding: 10px; border: 1px solid #b9e5ff;' align='left' bgcolor='#ECF8FF' valign='top'> <p style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='left'>We have an application! Download it to stay up to date! <a href='https://itunes.apple.com/us/app/la-hacks/id841785831?mt=8' style='color: #2ba6cb; text-decoration: none;'>Download! »</a></p> </td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table><table class='row' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; display: block; padding: 0px;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 10px 0px 0px;' align='left' valign='top'> <table class='twelve columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px;' align='left' valign='top'> <h3 style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 1.3; word-break: normal; font-size: 32px; margin: 0; padding: 0;' align='left'>Your swag is ready! <small style='font-size: 10px;'>We made it just for you :).</small></h3> <p style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='left'>Just some things to keep in mind for the hackathon: it's a whopping 36 hours, so stay hydrated and refreshed. Also, we have some awesome sponsors that want to meet you. It's why they're here, so go meet them and get your swag!</p> </td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table><table class='row' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; display: block; padding: 0px;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 10px 0px 0px;' align='left' valign='top'> <table class='three columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 130px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px;' align='left' valign='top'> </td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table><table class='row footer' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; display: block; padding: 0px;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; background: #ebebeb; margin: 0; padding: 10px 20px 0px 0px;' align='left' bgcolor='#ebebeb' valign='top'> <table class='six columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 280px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='left-text-pad' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px 10px;' align='left' valign='top'> <h5 style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 1.3; word-break: normal; font-size: 24px; margin: 0; padding: 0 0 10px;' align='left'>Connect With Us:</h5> <table class='tiny-button facebook' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; overflow: hidden; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: center; color: #ffffff; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; display: block; width: auto !important; background: #3b5998; margin: 0; padding: 5px 0 4px; border: 1px solid #2d4473;' align='center' bgcolor='#3b5998' valign='top'> <a href='http://facebok.com/lahacks' style='color: #ffffff; text-decoration: none; font-weight: normal; font-family: Helvetica, Arial, sans-serif; font-size: 12px;'>Facebook</a> </td> </tr></table><br /><table class='tiny-button twitter' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; overflow: hidden; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: center; color: #ffffff; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; display: block; width: auto !important; background: #00acee; margin: 0; padding: 5px 0 4px; border: 1px solid #0087bb;' align='center' bgcolor='#00acee' valign='top'> <a href='http://twitter.com/lahacks' style='color: #ffffff; text-decoration: none; font-weight: normal; font-family: Helvetica, Arial, sans-serif; font-size: 12px;'>Twitter</a> </td> </tr></table><br /><table class='tiny-button google-plus' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; overflow: hidden; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: center; color: #ffffff; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; display: block; width: auto !important; background: #DB4A39; margin: 0; padding: 5px 0 4px; border: 1px solid #cc0000;' align='center' bgcolor='#DB4A39' valign='top'> <a href='http://instagram.com/lahacks' style='color: #ffffff; text-decoration: none; font-weight: normal; font-family: Helvetica, Arial, sans-serif; font-size: 12px;'>Instagram</a> </td> </tr></table></td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> <td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; background: #ebebeb; margin: 0; padding: 10px 0px 0px;' align='left' bgcolor='#ebebeb' valign='top'> <table class='six columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 280px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='last right-text-pad' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px;' align='left' valign='top'> <h5 style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 1.3; word-break: normal; font-size: 24px; margin: 0; padding: 0 0 10px;' align='left'>Contact Info:</h5> <p style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='left'><a href='http://lahacks.com' style='color: #2ba6cb; text-decoration: none;'>LAHacks.com</a></p> <p style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='left'>Phone: 408.341.0600</p> <p style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='left'>Address: 301 Westwood Plaza, Los Angeles, CA 90095</p> <p style='color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='left'>Email: <a href='mailto:hadar@lahacks.com' style='color: #2ba6cb; text-decoration: none;'>hadar@lahacks.com</a></p> </td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table><table class='row' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%%; position: relative; display: block; padding: 0px;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td class='wrapper last' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 10px 0px 0px;' align='left' valign='top'> <table class='twelve columns' style='border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 580px; margin: 0 auto; padding: 0;'><tr style='vertical-align: top; text-align: left; padding: 0;' align='left'><td align='center' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0px 0px 10px;' valign='top'> <center style='width: 100%%; min-width: 580px;'> <p style='text-align: center; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0 0 10px; padding: 0;' align='center'><a href='#' style='color: #2ba6cb; text-decoration: none;'>Unsubscribe</a></p> </center> </td> <td class='expander' style='word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: #222222; font-family: 'Helvetica', 'Arial', sans-serif; font-weight: normal; line-height: 19px; font-size: 14px; margin: 0; padding: 0;' align='left' valign='top'></td> </tr></table></td> </tr></table></td> </tr></table></center> </td> </tr></table></body></html>",person.name];
        msg.html = htmlString;
        
        [msg sendWithWeb];
        
        //person.completed = YES;
        NSString *user_id;
        NSString *event_id;
        NSString *post = [NSString stringWithFormat:@"&user_id=%@&event_id=%@",user_id,event_id];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:@"http://fastcheck.kywu.org/events/complete"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
        
        if(connection) {
            NSLog(@"Connection Successful");
        } else {
            NSLog(@"Connection could not be made");
        }
        person.completed = YES;
        [arrayOfSignedIn replaceObjectAtIndex:actionSheet.tag withObject:person];
        [signedInTableView reloadData];
        
    }
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
