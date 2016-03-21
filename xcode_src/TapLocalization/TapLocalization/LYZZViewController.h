//
//  LYZZViewController.h
//  TapLocalization
//
//  Created by Kai Zou on 2012-11-14.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>
#include <AudioToolbox/AudioToolbox.h>

#import "my_helper.h"
#import "CAStreamBasicDescription.h"
#import "Convolution.h"
#import <dispatch/dispatch.h>
#import "CircularBuffer.h"

#define GREY_BUTTON 0.0
#define SOLID_BUTTON 1.0

@interface LYZZViewController : UIViewController {
    Float64 hwSampleRate;
    AudioConverterRef audioConverter;
    AudioBufferList *drawABL;
    CAStreamBasicDescription thruFormat;
    CAStreamBasicDescription drawFormat;
    
    // Add new instance variable
    dispatch_queue_t backgroundQueue;
    
    UIButton *Location1Button;
    UIButton *Location2Button;
    UIButton *BeginTestButton;
}

//AUDIO handler:
@property (nonatomic, assign) BOOL unitHasBeenCreated;
@property (nonatomic, assign) AURenderCallbackStruct inputProc;
@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) BOOL unitIsRunning;
@property (nonatomic, assign) DCRejectionFilter *dcFilter;

//ACC and GYR handler:
@property (strong, nonatomic) CMMotionManager *motionManager;

- (IBAction)Location1Button:(id)sender;
- (IBAction)Location2Button:(id)sender;
- (IBAction)BeginTestButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *StatusOutputLabel;
@property (strong, nonatomic) IBOutlet UIButton *Location1Button;
@property (strong, nonatomic) IBOutlet UIButton *Location2Button;
@property (strong, nonatomic) IBOutlet UIButton *BeginTestButton;

@end
