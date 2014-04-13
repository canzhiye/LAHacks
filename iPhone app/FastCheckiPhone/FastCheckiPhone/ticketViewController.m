//
//  ticketViewController.m
//  FastCheckiPhone
//
//  Created by Coulton Vento on 4/13/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import "ticketViewController.h"

@interface ticketViewController ()

@end

@implementation ticketViewController
@synthesize stringTitle, stringSubtitle, stringFooter;

#define COLOR_MEDIUM_GRAY [UIColor colorWithRed:(84.0/255.0) green:(84.0/255.0) blue:(84.0/255.0) alpha:1.0]
#define COLOR_BG_GRAY [UIColor colorWithRed:(235.0/255.0) green:(235.0/255.0) blue:(235.0/255.0) alpha:1.0]
#define COLOR_LINE_GRAY [UIColor colorWithRed:(180.0/255.0) green:(180.0/255.0) blue:(180.0/255.0) alpha:1.0]
#define COLOR_HIGHLIGHT [UIColor colorWithRed:(80.0/255.0) green:(171.0/255.0) blue:(229.0/255.0) alpha:1.0]

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {  }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    self.view.backgroundColor = COLOR_HIGHLIGHT;
    
    pageTitle.font = [UIFont fontWithName:@"OpenSans" size:28];
    pageSubtitle.font = [UIFont fontWithName:@"OpenSans-Light" size:19];
    pageFooter.font = [UIFont fontWithName:@"OpenSans-Light" size:19];
    
    pageTitle.text = stringTitle;
    pageSubtitle.text = stringSubtitle;
    pageFooter.text = stringFooter;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
