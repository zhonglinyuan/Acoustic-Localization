//
//  YZZTapRecording.m
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZTapRecording.h"

@interface YZZTapRecording ()
@property (strong, nonatomic) NSFileManager *myFileManager;
@property (strong, nonatomic) YZZSignalProcessor *localSignalProcessor;
@end

@implementation YZZTapRecording
@synthesize myFileManager = _myFileManager;
@synthesize localSignalProcessor = _localSignalProcessor;

@synthesize SensorBufferNames = _SensorBufferNames;
@synthesize SensorFileHandles = _SensorFileHandles;

-(id) init {
    self = [super init];
    
    self.localSignalProcessor = [[YZZSignalProcessor alloc]initWithSetupLength:PREPROCESS_DATA_WINDOW_SIZE*2];
    
    //create the buffer names
    self.SensorBufferNames = [NSMutableArray arrayWithObjects:@"Mic", @"AccX", @"AccY", @"AccZ", @"GyroX", @"GyroY", @"GyroZ", nil];
    
    self->tapID = -1;
    self->labelID = -1;
    self->valid = true;
    self->totalNumberOfSensors = TOTAL_NUMBER_OF_SENSORS;
    //create the sensor fifos
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
            self->SensorFifo[i] = new FixedFifo(MIC_DATA_BUFF_SIZE, MIC_DATA_BUFF_SIZE_TRIGGER);
        }
        else {
            self->SensorFifo[i] = new FixedFifo(DATA_BUFF_STRUCT_SIZE, DATA_BUFF_STRUCT_SIZE_TRIGGER);
        }
    }
//    NSLog(@"created new tapRecording: labelID:%d tapID:%d valid:true", self->labelID, self->tapID);
    
    
    self->micReversedTimeDomLen = 0;
    self->micReversedTimeDom = NULL;
    self->micFreqDomReversedLen = 0;
    self->micFreqDomReversed = NULL;

    self->micForwardTimeDomLen = 0;
    self->micForwardTimeDom = NULL;
    self->micFreqDomForwardLen = 0;
    self->micFreqDomForward = NULL;
    
    return self;
}

-(id)initDeepCopy:(YZZTapRecording *)sourceTapRecording {
    self = [self init];
    
    self->tapID = sourceTapRecording->tapID;
    self->labelID = sourceTapRecording->labelID;
    self->valid = sourceTapRecording->valid;
    
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        float *linearBuffer = sourceTapRecording->SensorFifo[i]->getDataLinear();
        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
            for (int j=0;j<MIC_DATA_BUFF_SIZE;j++) { //for mic
                self->SensorFifo[i]->push(linearBuffer[j]);
            }
        }
        else {
            for (int j=0;j<DATA_BUFF_STRUCT_SIZE;j++) { //for other sensors
                self->SensorFifo[i]->push(linearBuffer[j]);
            }
        }
        free(linearBuffer);
    }
    
    return self;
}

-(void)dealloc {
    delete *self->SensorFifo;
    
    if (self->micReversedTimeDom != NULL) {
        free(self->micReversedTimeDom);
    }
    if (self->micFreqDomReversed != NULL) {
        [self.localSignalProcessor free_DSPSplitComplex:self->micFreqDomReversed];
    }
    if (self->micForwardTimeDom != NULL) {
        free(self->micForwardTimeDom);
    }
    if (self->micFreqDomForward != NULL) {
        [self.localSignalProcessor free_DSPSplitComplex:self->micFreqDomForward];
    }
    NSLog(@"dealloc tapRecording labelID:%d tapID:%d", self->labelID, self->tapID);
}

-(void)registerTapRecordingID:(int)tapId withLabel:(int)labelId {
    self->tapID = tapId;
    self->labelID = labelId;
    self->valid = true;
    NSLog(@"registeredTapRecording labelID:%d tapID:%d valid:true", self->labelID, self->tapID);
    
    //precompute mic information
    [self createTimeReversedMicArrayAndFreqDomArray];
}


-(int) findClosest2Power:(int)num {
    int power = 0;
    
    int twoPower = (int)pow(2, power);
    
    while (num > twoPower) {
        power++;
        twoPower = (int)pow(2, power);
    }
    return power;
}

-(void) createTimeReversedMicArrayAndFreqDomArray {
    if (self->micReversedTimeDom != NULL || self->micFreqDomReversed != NULL) {
        return;
    }
    
    int rawMicDataLen = self->SensorFifo[0]->length();
    float *rawMicData =self->SensorFifo[0]->getDataLinearNormalized();
    
    int power = [self findClosest2Power:rawMicDataLen];
    int closest2Power = (int)pow(2, power);
    NSLog(@"HERE HERE %d",closest2Power);
    self->micReversedTimeDomLen = closest2Power*2;
    
    self->micReversedTimeDom = (float *) malloc((self->micReversedTimeDomLen)*sizeof(float));
    //creating time reversed mic data
    for (int i=0; i<self->micReversedTimeDomLen; i++) {
        if (i<(closest2Power - rawMicDataLen)) {
            self->micReversedTimeDom[i] = 0;
        } else if (i >= (closest2Power - rawMicDataLen) && i < closest2Power) {
            self->micReversedTimeDom[i] = rawMicData[ (rawMicDataLen-1) - (i - (closest2Power - rawMicDataLen)) ];
        } else if (i >= closest2Power) {
            self->micReversedTimeDom[i] = 0;
        }
    }
    
    //create freq dom array and get fft
    self->micFreqDomReversedLen = self->micReversedTimeDomLen / 2;
    self->micFreqDomReversed = [self.localSignalProcessor malloc_DSPSplitComplexWithLength:self->micFreqDomReversedLen];
    [self.localSignalProcessor fft_wrap:self->micReversedTimeDom ofInputLen:self->micReversedTimeDomLen toGetOutput:self->micFreqDomReversed ofOutputLen:self->micFreqDomReversedLen];
}

-(void) createTimeForwardMicArrayAndFreqDomArray {
    if (self->micForwardTimeDom != NULL || self->micFreqDomForward != NULL) {
        return;
    }
    
    int rawMicDataLen = self->SensorFifo[0]->length();
    float *rawMicData = self->SensorFifo[0]->getDataLinearNormalized();
    
    int power = [self findClosest2Power:rawMicDataLen];
    int closest2Power = (int)pow(2, power);
    self->micForwardTimeDomLen = closest2Power*2;
    
    self->micForwardTimeDom = (float *) malloc((self->micForwardTimeDomLen)*sizeof(float));
    //creating time reversed mic data
    for (int i=0; i<self->micForwardTimeDomLen; i++) {
        if (i<rawMicDataLen) {
            self->micForwardTimeDom[i] = rawMicData[i];
        } else {
            self->micForwardTimeDom[i] = 0;
        }
    }
    
    //create freq dom array and get fft
    self->micFreqDomForwardLen = self->micForwardTimeDomLen / 2;
    self->micFreqDomForward = [self.localSignalProcessor malloc_DSPSplitComplexWithLength:self->micFreqDomForwardLen];
    [self.localSignalProcessor fft_wrap:self->micForwardTimeDom ofInputLen:self->micForwardTimeDomLen toGetOutput:self->micFreqDomForward ofOutputLen:self->micFreqDomForwardLen];
}

-(void)clearAllBuffers {
//    NSLog(@"clearAllBuffers labelID:%d tapID:%d", self->labelID, self->tapID);
    for (int i=0;i<TOTAL_NUMBER_OF_SENSORS;i++) {
        self->SensorFifo[i]->clearAll();
    }
}

#pragma mark file handeling

-(void) writeAllBuffersToFileForSetup:(int)setupNumber UsingLabel:(int)labelId andInferredLocation:(int)guess {
    NSLog(@"writeAllBuffersToFile... labelID:%d tapID:%d", self->labelID, self->tapID);
    
    //get the main directory
    self.myFileManager = [NSFileManager defaultManager];
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *mainDir = [[NSString alloc]initWithString:[myPathList objectAtIndex:0]];
    
    NSTimeInterval thisTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    
    NSString *sensorFilePath;
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        //create file path string
        if (guess == -1) {
            sensorFilePath = [[NSString alloc]initWithFormat:@"%@/setup%d/engineTester_%f_%d_template_%@.txt", mainDir, setupNumber, thisTimeInSeconds, labelId, [self.SensorBufferNames objectAtIndex:i]];
        } else {
            sensorFilePath = [[NSString alloc]initWithFormat:@"%@/setup%d/engineTester_%f_%d_%d_%@.txt", mainDir, setupNumber, thisTimeInSeconds, labelId, guess, [self.SensorBufferNames objectAtIndex:i]];
        }
        
        //create file for sensor
        [self.myFileManager createFileAtPath:sensorFilePath contents:nil attributes:nil];
        
        //attach file handle for the new file
        NSFileHandle *sensorFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:sensorFilePath];
        
        //write sensor buffer content to file
        float *linearBuffer = self->SensorFifo[i]->getDataLinear();
        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
            for (int j=0;j<MIC_DATA_BUFF_SIZE;j++) { //for mic
                NSString *bufferString = [[NSString alloc]initWithFormat:@"%f\n", linearBuffer[j]];
                [sensorFileHandle writeData:[bufferString dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        else {
            for (int j=0;j<DATA_BUFF_STRUCT_SIZE;j++) { //for other sensors
                NSString *bufferString = [[NSString alloc]initWithFormat:@"%f\n", linearBuffer[j]];
                [sensorFileHandle writeData:[bufferString dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        [[self.SensorFileHandles objectAtIndex:i] closeFile];
        free(linearBuffer);
        
        //close file
        [sensorFileHandle closeFile];
    }
    
}

// recordingIsGood checks the signals in the recording and determines whether or not this data is usable
- (bool) recordingIsGood
{
    bool result = YES;
    
    //check mic:
    //  1. max of mic should >
    //  2. index of max should occur >
    //  3. std o mic data should >
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
            float *linearBuffer = self->SensorFifo[i]->getDataLinear();
            int max_index = -1;
            float max = -1;
            float std = 0;
            float mean = 0;
            for (int j=0;j<MIC_DATA_BUFF_SIZE;j++) { //for mic
                if (fabsf(linearBuffer[j]) > max) {
                    max = fabsf(linearBuffer[j]);
                    max_index = j;
                }
                mean += linearBuffer[j];
            }
            mean = mean / self->SensorFifo[i]->length();
            for (int j=0;j<MIC_DATA_BUFF_SIZE;j++) { //for mic
                std += pow((linearBuffer[j] - mean),2);
            }
            std = pow((std)/self->SensorFifo[i]->length(),0.5);
            
            if (max < RECORDING_IS_GOOD_MIC_MAX || max_index < RECORDING_IS_GOOD_MIC_MAX_INDEX || std < RECORDING_IS_GOOD_MIC_STD) {
                result = false;
            }
            NSLog(@"INFO: recordingIsGood(%d)\n\trecording_mic_max:%f recording_mic_max_index:%d recording_mic_std:%f",result, max, max_index, std);
        }
    }
    return result;
}

-(void) preprocessData
{
    //return;
    // preprocess mic data:
    // 1. low pass by avg
    // 2. subsample PREPROCESS_DATA_SUBSAMPLING_RATIO ratio
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
            float *linearBuffer = self->SensorFifo[i]->getDataLinear();
                        
            // create a new fixed-fifo for the new recording
            FixedFifo * tmpFifo = new FixedFifo(PREPROCESS_DATA_WINDOW_SIZE, 0);
            
            for (int j = 0; j < PREPROCESS_DATA_WINDOW_SIZE; j ++){
                int remapped = j * PREPROCESS_DATA_SUBSAMPLING_RATIO;
                    tmpFifo->push((linearBuffer[remapped]+linearBuffer[remapped+1] + linearBuffer[remapped+2] + linearBuffer[remapped+3])/4);
            }
            delete(self->SensorFifo[i]);
            self->SensorFifo[i] = tmpFifo;
        }
    }
}

@end