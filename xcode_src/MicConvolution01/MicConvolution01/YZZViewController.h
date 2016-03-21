//
//  YZZViewController.h
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
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

#import <MessageUI/MFMailComposeViewController.h>

@interface YZZViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    Float64 hwSampleRate;
    AudioConverterRef audioConverter;
    AudioBufferList *drawABL;
    CAStreamBasicDescription thruFormat;
    CAStreamBasicDescription drawFormat;
    
    // Add new instance variable
    dispatch_queue_t backgroundQueue;
}
//Capture strucutre:
//@property (strong, atomic) YZZDataCapturer *dataCapturer;

//Cross Correlation:
//@property (strong, nonatomic) Convolution *myCrossCorr;

//AUDIO handler:
@property (nonatomic, assign) BOOL unitHasBeenCreated;
@property (nonatomic, assign) AURenderCallbackStruct inputProc;
@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) BOOL unitIsRunning;
@property (nonatomic, assign) DCRejectionFilter *dcFilter;

//ACC and GYR handler:
@property (strong, nonatomic) CMMotionManager *motionManager;

//VIEW Calibrate:
- (IBAction)ButtonStoreLocation1:(id)sender;
- (IBAction)ButtonStoreLocation2:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *StoreLoc01Button;
@property (strong, nonatomic) IBOutlet UILabel *Location1StoreStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *StoreLoc02Button;
@property (strong, nonatomic) IBOutlet UILabel *Location2StoreStatusLabel;

//VIEW Detection:
- (IBAction)StartDetectionButton:(id)sender;
- (IBAction)StopDetectionButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *DetectionStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *LocationTappedStatusLabel;

- (IBAction)emailDataButton:(id)sender;
@end
