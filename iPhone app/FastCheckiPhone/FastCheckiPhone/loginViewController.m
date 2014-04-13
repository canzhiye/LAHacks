//
//  loginViewController.m
//  FastCheckiPhone
//
//  Created by Coulton Vento on 4/12/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import "loginViewController.h"

@interface loginViewController ()

@end

@implementation loginViewController

#define COLOR_MEDIUM_GRAY [UIColor colorWithRed:(84.0/255.0) green:(84.0/255.0) blue:(84.0/255.0) alpha:1.0]
#define COLOR_BG_GRAY [UIColor colorWithRed:(235.0/255.0) green:(235.0/255.0) blue:(235.0/255.0) alpha:1.0]
#define COLOR_LINE_GRAY [UIColor colorWithRed:(180.0/255.0) green:(180.0/255.0) blue:(180.0/255.0) alpha:1.0]
#define COLOR_HIGHLIGHT [UIColor colorWithRed:(80.0/255.0) green:(171.0/255.0) blue:(229.0/255.0) alpha:1.0]

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {  }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=6DFNDX6C6HYXX5IY33"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UIWebView Delegates

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *url = [request.URL absoluteString];
    if ([url hasPrefix:@"http://canzhiye.com/"]) {
        NSDictionary *dictionary = [self urlParams:url];
        
        [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"access_token"] forKey:@"access_token"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [self setTitle:[wv stringByEvaluatingJavaScriptFromString:@"document.title"]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Helpers

-  (NSDictionary*)urlParams:(NSString*)url {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    url = [[url componentsSeparatedByString:@"#"] objectAtIndex:1];
    for (NSString *param in [url componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }
    return params;
}

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

@end
