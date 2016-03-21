//
//  KKZViewController.h
//  AGDataLogger01
//
//  Created by Kai Zou on 2012-09-16.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreMotion/CoreMotion.h>

@interface KKZViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)buttonPressed:(UIButton *)sender;
- (void)displayComposerSheet;
@end
