//
//  DataCapture.m
//  SimpleTap
//
//  Created by ZhongLin Yuan on 2012-11-17.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import "DataCapture.h"
#define ACCEL_THRESHHOLD 0.04

@implementation DataCapture
@synthesize done;

- (void) setupSensors:(CMMotionManager *)myManager AU:(AudioUnit *)myAU {
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
    XThrowIfError(AudioOutputUnitStart(*myAU), "couldn't start remote i/o unit");
    myManager.accelerometerUpdateInterval = 0.0;
    myManager.gyroUpdateInterval = 0.0;
}

- (void) cleanupSensors:(CMMotionManager *)myManager AU:(AudioUnit *)myAU {
    [myManager stopDeviceMotionUpdates];
    XThrowIfError(AudioOutputUnitStop(*myAU), "couldn't stop remote i/o unit");
    XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
}

- (void)captureDataWithMotion:(CMMotionManager *)myManager AU:(AudioUnit *)myAU andLocation: (Location *)myLocation fromBuffer: (FixedFifo *)captureBuffer toLabel:(UILabel *)myLabel withMessage:(NSString *)myMessage
{
    NSCondition *condLock = [[NSCondition alloc] init];
    captureBuffer->clearAll();
    myLocation->MicFifo->clearAll();
    myLocation->AccZFifo->clearAll();
    myLocation->GyroXFifo->clearAll();
    myLocation->GyroYFifo->clearAll();
    
    self.done = NO;
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
    XThrowIfError(AudioOutputUnitStart(*myAU), "couldn't start remote i/o unit");
    myManager.accelerometerUpdateInterval = 0.0;
    myManager.gyroUpdateInterval = 0.0;
    
    [myManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error){
        [condLock lock];
        if (error) {
            [myManager stopDeviceMotionUpdates];
        } else {
            
            /* Add data to the queue. */
            myLocation->AccZFifo->push((float)(motion.userAcceleration.z));// + motion.gravity.z));
//            NSLog(@"%f asdf %f", motion.userAcceleration.z, motion.gravity.z);
            myLocation->GyroXFifo->push((float)motion.rotationRate.x);
            myLocation->GyroYFifo->push((float)motion.rotationRate.y);
            float computedThresholdValue = 0;
            if (myLocation->AccZFifo->isFull())
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    myLabel.backgroundColor = [UIColor greenColor];
                    myLabel.text = @"waiting for input";
                });
                computedThresholdValue = myLocation->AccZFifo->getMid();// + 1.035;
                computedThresholdValue = (computedThresholdValue<0 ? (computedThresholdValue*-1.0):computedThresholdValue);
            }
            
            //if threshold value attained, then stop the audio session, stop accel, stop gyro
            if (computedThresholdValue > ACCEL_THRESHHOLD) {
                [myManager stopDeviceMotionUpdates];
                XThrowIfError(AudioOutputUnitStop(*myAU), "couldn't stop remote i/o unit");
                XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
                float *tmpBuffer =  captureBuffer->getDataLinear();
                int i;
                for (i=0; i<MIC_DATA_BUFF_SIZE; i++)
                {
                    myLocation->MicFifo->push(tmpBuffer[i]);
                }
                free(tmpBuffer);
                if(myMessage != nil)
                    dispatch_async(dispatch_get_main_queue(),^{
                        myLabel.text = myMessage;
                    });
                
                self.done = YES;
                [condLock signal];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dataCollectionIsDone" object:self];
            }
        }
        [condLock unlock];
    }];
    [condLock lock];
    while(self.done == NO){
        [condLock wait];
    }
    [condLock unlock];
}
@end
