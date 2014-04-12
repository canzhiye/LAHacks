//
//  ViewController.m
//  FastCheckiPhone
//
//  Created by Canzhi Ye on 4/11/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import "ViewController.h"
#import "NSDictionary+BVJSONString.h"

@interface ViewController ()
@property (nonatomic) JGBeacon* beacon;
@end

@implementation ViewController

#define COLOR_MEDIUM_GRAY [UIColor colorWithRed:(84.0/255.0) green:(84.0/255.0) blue:(84.0/255.0) alpha:1.0]
#define COLOR_BG_GRAY [UIColor colorWithRed:(235.0/255.0) green:(235.0/255.0) blue:(235.0/255.0) alpha:1.0]
#define COLOR_LINE_GRAY [UIColor colorWithRed:(180.0/255.0) green:(180.0/255.0) blue:(180.0/255.0) alpha:1.0]

#pragma mark - Bluetooth

- (void)receivedData:(NSData *)data { NSLog(@"got data"); }
- (void)connectedToBeacon:(NSUUID *)identifier { NSLog(@"connected"); }
- (void)disconnectedFromBeacon:(NSUUID *)identifier{ NSLog(@"disconnected"); }

#pragma mark - Set up

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Have you logged in before?
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken.length > 0) {
        
        // Do you have a user id?
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_json"];
        if (userId.length == 0) {
            
            // Let's do it in the background
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
                NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
                NSString *url = [[NSString alloc] initWithFormat:@"https://www.eventbriteapi.com/v3/users/me/?token=%@",accessToken];
                NSError *error = nil;
                NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
                
                // Nil data, don't crash!
                if (data != nil) {
                    NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    
                    NSLog(@"%@", resultsDictionary);
                    
                    NSDictionary *dictionary = @{
                                                 @"id" : [resultsDictionary objectForKey:@"id"],
                                                 @"name" : [resultsDictionary objectForKey:@"name"]
                                                 , @"email" : [[[resultsDictionary objectForKey:@"emails"] objectAtIndex:0] objectForKey:@"email"]
                                                 };
                    [[NSUserDefaults standardUserDefaults] setObject:[dictionary bv_jsonStringWithPrettyPrint:NO] forKey:@"user_json"];
                    
                    // Looks good. Go to the main thread
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        // Give JGBeacon enough time to connect to some devices
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            // GOGOGOGOGO
                            [self.beacon queueDataToSend:[[dictionary bv_jsonStringWithPrettyPrint:NO] dataUsingEncoding:NSUTF8StringEncoding]];
                        });
                    });
                }
            });
        }
    } else {
        
        // You haven't logged in
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"login" sender:self];
        });
    }
}

- (void)viewDidLoad {
    tableView.backgroundColor = COLOR_BG_GRAY;
    tableView.separatorColor = COLOR_LINE_GRAY;
    tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    dataArray = [[NSMutableArray alloc] init];
    [dataArray addObject:@[
                           @"You signed into LAHacks.",[self dateDiff:@"123456789"]
                           ]];
    [dataArray addObject:@[
                           @"You signed into LAHacks.",[self dateDiff:@"123456789"]
                           ]];
    [dataArray addObject:@[
                           @"You signed into LAHacks.",[self dateDiff:@"123456789"]
                           ]];
    
    [self setTitle:@"Notifications"];
    [super viewDidLoad];
    
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconSendingOnly;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_json"];
    if (userId.length > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.beacon queueDataToSend:[userId dataUsingEncoding:NSUTF8StringEncoding]];
        });
    }
    else {
    }
    
    [leftButton setTitleTextAttributes:@{
                                         NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:15.0],
                                         NSForegroundColorAttributeName : COLOR_MEDIUM_GRAY
                                         }
                              forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"user_json"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"access_token"];
    
    [self performSegueWithIdentifier:@"login" sender:self];
}
#pragma mark NSURL stuff
/*
 this method might be calling more than one times according to incoming data size
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //[self.receivedData appendData:data];
}

/*
 if there is an error occured, this method will be called by connection
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"%@" , error);
}
/*
 if data is successfully received, this method will be called by connection
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
}
#pragma mark - UITableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"message"];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 20)];
    title.font = [UIFont fontWithName:@"OpenSans" size:15];
    title.textColor = COLOR_MEDIUM_GRAY;
    title.text = [[dataArray objectAtIndexedSubscript:indexPath.row] objectAtIndex:0];
    title.numberOfLines = 0;
    [title sizeToFit];
    [cell.contentView addSubview:title];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, title.frame.origin.y+title.frame.size.height-1.0f, 300, 17)];
    text.font = [UIFont fontWithName:@"OpenSans-Light" size:13];
    text.textColor = COLOR_MEDIUM_GRAY;
    text.text = [[dataArray objectAtIndexedSubscript:indexPath.row] objectAtIndex:1];
    text.numberOfLines = 0;
    [text sizeToFit];
    [cell.contentView addSubview:text];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 20)];
    title.font = [UIFont fontWithName:@"OpenSans" size:15];
    title.text = [[dataArray objectAtIndexedSubscript:indexPath.row] objectAtIndex:0];
    title.numberOfLines = 0;
    [title sizeToFit];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, title.frame.origin.y+title.frame.size.height-1.0f, 300, 17)];
    text.font = [UIFont fontWithName:@"OpenSans-Light" size:13];
    text.text = [[dataArray objectAtIndexedSubscript:indexPath.row] objectAtIndex:1];
    text.numberOfLines = 0;
    [text sizeToFit];
    
    return text.frame.size.height+text.frame.origin.y+17.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Helpers -

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:17];
        titleView.textColor = COLOR_MEDIUM_GRAY;
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
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

@end
