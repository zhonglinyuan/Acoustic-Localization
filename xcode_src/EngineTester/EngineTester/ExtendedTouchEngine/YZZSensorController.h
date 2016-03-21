//
//  YZZSensorController.h
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioUnit/AudioUnit.h>
#import "YZZTapRecording.h"
#import "YZZLabel.h"
#include "my_helper.h"
#include "FixedFifo.h"

typedef enum {
    Start_stop = 0,
    Continuous
}SensorMode;

@interface YZZSensorController : NSObject {
    @public
    bool capture_data_active;
    bool all_sensors_startedup;
    float AccZ_average;
    float AccZ_deviation;
    bool accel_threshold_setup_complete;

}

+(bool)audioUnitStatus;

-(void)setCapture_Data_Active:(bool)_capture_data_active;
-(bool)getCapture_Data_Active;
-(bool) getMicCaptureBufferIsFull;

-(id) initWithMode:(int)mode_flag;//(SensorMode)mode_flag;
-(bool)captureDataAtLocation:(YZZTapRecording *)myTapRecording;

-(void)determineAccelThreshold;

@end
