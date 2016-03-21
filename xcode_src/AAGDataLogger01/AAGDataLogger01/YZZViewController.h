//
//  YZZViewController.h
//  AAGDataLogger01
//
//  Created by Kai Zou on 2012-09-17.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreMotion/CoreMotion.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>
#include <AudioToolbox/AudioToolbox.h>

//#import "Foundation/NSLock.h"

#import "my_helper.h"
#import "CAStreamBasicDescription.h"

@interface YZZViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    Float64 hwSampleRate;
    AudioConverterRef audioConverter;
    AudioBufferList *drawABL;
    CAStreamBasicDescription thruFormat;
    CAStreamBasicDescription drawFormat;
}
@property (weak, nonatomic) IBOutlet UILabel *myDisplay;
@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) BOOL unitHasBeenCreated;
@property (nonatomic, assign) BOOL unitIsRunning;

@property (nonatomic, assign) AURenderCallbackStruct inputProc;
//@property (retain) NSTimer *triggerSensorReadTimer;
@property (nonatomic, assign) DCRejectionFilter *dcFilter;
@property (strong, nonatomic) IBOutlet UITextField *xCoorTxtField;
@property (strong, nonatomic) IBOutlet UITextField *yCoorTxtField;
@property (strong, nonatomic) IBOutlet UITextField *surfaceTypeTxtField;
@property (strong, nonatomic) IBOutlet UITextField *numTapsTxtField;
@property (strong, nonatomic) IBOutlet UITextField *tapTypeTxtField;

-(void) readSensors;
-(IBAction)buttonPressed:(UIButton *)sender;
-(void)displayComposerSheet;
- (IBAction)inputDoneEditing:(id)sender;
- (IBAction)backGroundTapped:(id)sender;

@end
