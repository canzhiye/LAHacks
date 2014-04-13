//
//  ticketViewController.h
//  FastCheckiPhone
//
//  Created by Coulton Vento on 4/13/14.
//  Copyright (c) 2014 we so cool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ticketViewController : UIViewController {
    IBOutlet UILabel *pageTitle, *pageSubtitle, *pageFooter;
    NSString *stringTitle, *stringSubtitle, *stringFooter;
}

@property (nonatomic, retain) NSString *stringTitle, *stringSubtitle, *stringFooter;

- (IBAction)close:(id)sender;

@end
