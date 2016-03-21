//
//  YZZSensorManager.h
//  TapLocator
//
//  Created by Kai Zou on 2012-12-01.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioUnit/AudioUnit.h>
#import "YZZLocation.h"
#include "my_helper.h"
#include "FixedFifo.h"
#import "YZZLocationManager.h"

@interface YZZSensorManager : NSObject {
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

-(void)setEmailSent:(BOOL)_emailSent;
-(BOOL)getEmailSent;


-(id)init;
-(void)captureDataAtLocation:(YZZLocation *)myLocation;

-(void)determineAccelThreshold;

@end
