//
//  SimpleTapViewController.h
//  SimpleTap
//
//  Created by ZhongLin Yuan on 2012-11-14.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "CAStreamBasicDescription.h"
#import <dispatch/dispatch.h>

#import "YZZSensorManager.h"
#import "YZZLocationManager.h"

#define NUMBER_OF_LOCATION_TEMPLATES 3 //IMPORTANT DEFINE!

@interface SimpleTapViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    UIButton *Location1Button;
    UIButton *Location2Button;
}

@property (strong, nonatomic) NSMutableArray *arrayColors;

@property (strong, nonatomic) IBOutlet UIButton *Location1Button;
@property (strong, nonatomic) IBOutlet UIButton *Location2Button;
@property (strong, nonatomic) NSMutableArray *locationIndicators;
@property (weak, nonatomic) IBOutlet UILabel *myDisplay;
@property (strong, nonatomic) IBOutlet UILabel *location1Indicator;
@property (strong, nonatomic) IBOutlet UILabel *location2Indicator;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UITextField *actualTappedLocationField;
- (IBAction)inputDoneEditing:(id)sender;

- (IBAction)EmailResultButton:(UIButton *)sender;
- (IBAction)LocationButtonPressed:(UIButton *)sender;
- (IBAction)StartTesting:(UIButton *)sender;
- (IBAction)StopTestingButton:(UIButton *)sender;

@end