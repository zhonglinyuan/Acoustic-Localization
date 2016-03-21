//
//  YZZRecordingLabel.h
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FixedFifo.h"
#import <Accelerate/Accelerate.h>
#include <math.h>
#import "YZZSignalProcessor.h"

#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

#define DATA_BUFF_STRUCT_SIZE 32
#define DATA_BUFF_STRUCT_SIZE_TRIGGER 20
#define MIC_DATA_BUFF_SIZE DATA_BUFF_STRUCT_SIZE*kMinDrawSamples
#define MIC_DATA_BUFF_SIZE_TRIGGER 20

#define TOTAL_NUMBER_OF_SENSORS 7 //this order is important: Mic, AccX, AccY, AccZ, GyroX, GyroY, GyroZ

#define RECORDING_IS_GOOD_MIC_MAX 20
#define RECORDING_IS_GOOD_MIC_MAX_INDEX 500
#define RECORDING_IS_GOOD_MIC_STD 2

#define PREPROCESS_DATA_SUBSAMPLING_RATIO 4
#define PREPROCESS_DATA_WINDOW_SIZE 2048


@interface YZZTapRecording : NSObject
{
    @public
    int tapID;
    int labelID;
    bool valid;
    int totalNumberOfSensors;
    FixedFifo *SensorFifo[TOTAL_NUMBER_OF_SENSORS];
    
    //
    int micReversedTimeDomLen;
    float *micReversedTimeDom;
    int micFreqDomReversedLen;
    DSPSplitComplex *micFreqDomReversed;
    
    int micForwardTimeDomLen;
    float *micForwardTimeDom;
    int micFreqDomForwardLen;
    DSPSplitComplex *micFreqDomForward;
}
@property (strong, nonatomic) NSMutableArray *SensorBufferNames;
@property (strong, nonatomic) NSMutableArray *SensorFileHandles;

-(id)init;
-(id)initDeepCopy:(YZZTapRecording *)sourceTapRecording;
-(void)registerTapRecordingID:(int)tapID withLabel:(int)labelId; //done
-(void) createTimeForwardMicArrayAndFreqDomArray;
-(void)clearAllBuffers;
-(void) writeAllBuffersToFileForSetup:(int)setupNumber UsingLabel:(int)labelId andInferredLocation:(int)guess;
-(bool) recordingIsGood;
-(void) preprocessData;

@end

