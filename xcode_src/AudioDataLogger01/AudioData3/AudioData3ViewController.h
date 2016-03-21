//
//  AudioData3ViewController.h
//  AudioData3
//
//  Created by ZhongLin Yuan on 2012-09-13.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>
#include <AudioToolbox/AudioToolbox.h>


#import "my_helper.h"
#import "CAStreamBasicDescription.h"

@interface AudioData3ViewController : UIViewController <MFMailComposeViewControllerDelegate>{
Float64					  hwSampleRate;
AudioConverterRef           audioConverter;
AudioBufferList*            drawABL;
CAStreamBasicDescription	    thruFormat;
CAStreamBasicDescription      drawFormat;
}

@property (weak, nonatomic) IBOutlet UILabel *myDisplay;
@property (nonatomic, assign) AudioUnit		 rioUnit;
@property (nonatomic, assign) BOOL                        unitHasBeenCreated;
@property (nonatomic, assign) BOOL                        unitIsRunning;

@property (nonatomic, assign) AURenderCallbackStruct		inputProc;
@property (retain) NSTimer *myAudioDataReadingTimer;
@property (nonatomic, assign) DCRejectionFilter*			dcFilter;

-(void) logToFile;

@end
