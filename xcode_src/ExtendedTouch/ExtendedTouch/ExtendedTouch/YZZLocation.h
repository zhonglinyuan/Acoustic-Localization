//
//  YZZLocation.h
//  SimpleTap
//
//  Created by Kai Zou on 2012-12-02.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FixedFifo.h"

#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

#define DATA_BUFF_STRUCT_SIZE 40
#define DATA_BUFF_STRUCT_SIZE_TRIGGER DATA_BUFF_STRUCT_SIZE*0.5
#define MIC_DATA_BUFF_SIZE DATA_BUFF_STRUCT_SIZE*kMinDrawSamples
#define MIC_DATA_BUFF_SIZE_TRIGGER DATA_BUFF_STRUCT_SIZE*kMinDrawSamples*0.5

#define TOTAL_NUMBER_OF_SENSORS 7 //this order is important: Mic, AccX, AccY, AccZ, GyroX, GyroY, GyroZ

@interface YZZLocation : NSObject
{
    @public
    int LocationID;

//    YZZLocation *nextLocation;
    
    int totalNumberOfSensors; //this order is important: Mic, AccX, AccY, AccZ, GyroX, GyroY, GyroZ
    FixedFifo *SensorFifo[TOTAL_NUMBER_OF_SENSORS];
}

@property (strong, nonatomic) NSMutableArray *SensorBufferNames;
@property (strong, nonatomic) NSMutableArray *SensorFileNames;
@property (strong, nonatomic) NSMutableArray *SensorFilePaths;
@property (strong, nonatomic) NSMutableArray *SensorFileHandles;

-(id)initWithLocationID:(int)locID;

-(void)clearAllBuffers;

-(void)clearAllFiles;

-(void)createFilesAndAttacheFileHandlesForAllBuffers;

-(void)writeAllBuffersToFile;

@end
