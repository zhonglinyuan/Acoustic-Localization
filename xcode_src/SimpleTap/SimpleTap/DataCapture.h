//
//  DataCapture.h
//  SimpleTap
//
//  Created by ZhongLin Yuan on 2012-11-17.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#include <AudioToolbox/AudioToolbox.h>
#include "Location.h"
#include <libkern/OSAtomic.h>
#import "CAXException.h"


@interface DataCapture : NSObject
- (void)captureDataWithMotion:(CMMotionManager *)myManager AU:(AudioUnit *)myAU andLocation: (Location *)myLocation fromBuffer: (FixedFifo *)captureBuffer toLabel: (UILabel *)myLabel withMessage: (NSString *)myMessage;
- (void) setupSensors:(CMMotionManager *)myManager AU:(AudioUnit *)myAU;
- (void) cleanupSensors:(CMMotionManager *)myManager AU:(AudioUnit *)myAU;

@property (atomic) volatile BOOL done;
@end
