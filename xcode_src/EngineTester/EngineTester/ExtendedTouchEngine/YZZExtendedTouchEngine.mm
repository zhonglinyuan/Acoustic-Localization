//
//  YZZExtendedTouchEngine.m
//  EngineTester
//
//  Created by Kai Zou on 2013-01-25.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZExtendedTouchEngine.h"

@interface YZZExtendedTouchEngine()
@property (strong, nonatomic) YZZSensorController *sensorController;
@property (strong, nonatomic) NSMutableArray *all_taps_label_list;
@property (strong, nonatomic) NSMutableArray *best_templates_label_list;
@property (strong, nonatomic) YZZSignalProcessor *signalProcessor;
@property (strong, nonatomic) YZZTemplateSelector *templateSeletctor;
@end

@implementation YZZExtendedTouchEngine

@synthesize sensorController = _sensorController;
@synthesize all_taps_label_list = _all_taps_label_list;
@synthesize best_templates_label_list = _best_templates_label_list;
@synthesize signalProcessor = _signalProcessor;
@synthesize templateSeletctor = _templateSeletctor;

- (id)initWithSensorMode:(int)mode_flag{//(SensorMode)mode_flag {
    self = [super init];
    //create a SensorController in required mode
    self.sensorController = [[YZZSensorController alloc] initWithMode:mode_flag];
    //create an array of labels for recording templates
    self.all_taps_label_list = [[NSMutableArray alloc] init];
    self.signalProcessor = [[YZZSignalProcessor alloc]initWithSetupLength:PREPROCESS_DATA_WINDOW_SIZE*2];
    
    self.templateSeletctor = [[YZZTemplateSelector alloc]init];
    self.best_templates_label_list = [[NSMutableArray alloc]init];
    
    self.confidenceThreashold = 0.5;
    
    return self;
}

- (void)uninitialize {
}

- (YZZLabel *) getLabelFromAllLabelsListWithID:(int)labelID {
    YZZLabel *searchedLabel = nil;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        searchedLabel = [self.all_taps_label_list objectAtIndex:i];
        if (searchedLabel->labelID == labelID) {
            return searchedLabel;
        }
    }
    return nil;
}

- (bool)registerLabel:(int)labelId {
    YZZLabel *searchedLabel = [self getLabelFromAllLabelsListWithID:labelId];
    
    if (searchedLabel==nil) {
        [self.all_taps_label_list addObject:[[YZZLabel alloc]initWithLabelID:labelId]];
        return true;
    }
    return false;
}

- (bool)unregisterLabel:(int)labelId {
    YZZLabel *searchedLabel = [self getLabelFromAllLabelsListWithID:labelId];
    
    if (searchedLabel != nil) {
        [self.all_taps_label_list removeObject:searchedLabel];
        return true;
    }
    return false;
}

- (YZZTapRecording *)sync_startRecordNextTap:(bool *)tapEventDetected {
    YZZTapRecording *newTapRecording = [[YZZTapRecording alloc]init];
    __block bool eventDetected=false;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sensorController setCapture_Data_Active:true];
        eventDetected = [self.sensorController captureDataAtLocation:newTapRecording];
    });
    
    if (tapEventDetected != nil) {
        *tapEventDetected = eventDetected;
    }
    
    return newTapRecording;
}

- (bool)registerTap:(YZZTapRecording *)tapRecording WithTap:(int)tapId andLabel:(int)labelId {
    YZZLabel *searchedLabel = [self getLabelFromAllLabelsListWithID:labelId];
    if (searchedLabel == nil) {
        return false;
    }
    return [searchedLabel registerTapRecording:tapRecording withTapID:tapId withLabel:labelId];
}

-(int)numberOfRegisteredTapsAtLabelID:(int)labelID {
    YZZLabel *searchedLabel = [self getLabelFromAllLabelsListWithID:labelID];
    if (searchedLabel != nil) {
        return [searchedLabel getNumberOfTapRecordings];
    }
    return -1;
}

- (bool)unregisterAllTapsWithLabel:(int)labelId{
    YZZLabel *searchedLabel = [self getLabelFromAllLabelsListWithID:labelId];
    if (searchedLabel != nil) {
        return [searchedLabel unregisterAllTapRecordings];
    }
    return nil;
}

- (bool)unregisterTapWithTapID:(int)tapId andLabel:(int)labelId{
    YZZLabel *searchedLabel = [self getLabelFromAllLabelsListWithID:labelId];
    if (searchedLabel!=nil) {
        return [searchedLabel unregisterTapRecording:tapId];
    }
    return false;
}

- (bool)invalidateTapWithTapID:(int)tapId andLabel:(int)labelID {
    YZZLabel *searchLabel = [self getLabelFromAllLabelsListWithID:labelID];
    if (searchLabel!=nil) {
        return [searchLabel invalidateTapRecording:tapId];
    }
    return false;
}

- (YZZTapRecording *)deepCopyTapRecording:(YZZTapRecording *)sourceTapRecording {
    YZZTapRecording *newTapRecording = [[YZZTapRecording alloc]initDeepCopy:sourceTapRecording];
    return newTapRecording;
}

-(bool) getMicCaptureBufferIsFull {
    return [self.sensorController getMicCaptureBufferIsFull];
}

-(bool)isRecordingNextTap {
    return [self.sensorController getCapture_Data_Active];
}

-(void)stopRecordingNextTap {
    [self.sensorController setCapture_Data_Active:false];
}

- (void)sync_performEnvironmentCalibration {
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sensorController determineAccelThreshold];
        });
    //});
}

- (NSMutableArray *) findBestKTemplates:(int)clique_Size fromLabelID:(int)labelID {
    YZZLabel *searched_in_all_taps_label_list = [self getLabelFromAllLabelsListWithID:labelID];
    if (searched_in_all_taps_label_list == nil) {
        return nil;
    }
    return [self.templateSeletctor FindBestThreeTemplates:searched_in_all_taps_label_list];
}

- (DSPSplitComplex *) getFreqDomReversedArray:(YZZTapRecording *)recording {
    return recording->micFreqDomReversed;
}

- (DSPSplitComplex *) getFreqDomForwardArray:(YZZTapRecording *)recording {
    return recording->micFreqDomForward;
}

- (int)returnFFTCrossCorrBestMatchWithTapRecordingsInAllLabels:(YZZTapRecording *)recording {

    [recording createTimeForwardMicArrayAndFreqDomArray];
    DSPSplitComplex *recordingMicFreqDomForward = [self getFreqDomForwardArray:recording];
    
    YZZLabel *currentLabel;
    YZZTapRecording *currentTapRecording;
    float current_xcorr_value;
    float max_xcorr_value=0;
    int best_match_label;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        for (int j=0; j<[currentLabel getNumberOfTapRecordings]; j++) {
            currentTapRecording = [currentLabel getTapRecordingWithIndex:j];

            DSPSplitComplex *tapRecordingMicFreqDomReverse = [self getFreqDomReversedArray:currentTapRecording];
            int complex_array_len = currentTapRecording->micFreqDomReversedLen;
            current_xcorr_value = [self.signalProcessor fftxcorr_TapRecording:recordingMicFreqDomForward withTapTemplate:tapRecordingMicFreqDomReverse ofLen:complex_array_len];
            
            NSLog(@"fftxcorr w/ label:%d tap:%d =%f", currentLabel->labelID, currentTapRecording->tapID, current_xcorr_value);
            if (current_xcorr_value > max_xcorr_value) {
                max_xcorr_value = current_xcorr_value;
                best_match_label = currentLabel->labelID;
            }
        }
    }
    return best_match_label;
}

- (int)returnFFTCrossCorrBestAverageMatchWithMultipleRecordings:(YZZTapRecording *)recording{

    [recording createTimeForwardMicArrayAndFreqDomArray];
    DSPSplitComplex *recordingMicFreqDomForward = [self getFreqDomForwardArray:recording];
    
    NSLog(@"INFO: returnFFTCrossCorrBestAverageMatchWithMultipleRecordings\n\t length of mic waveform:%d", recording->SensorFifo[0]->length());
    
    YZZLabel *currentLabel;
    YZZTapRecording *currentTapRecording;
    
    double xcoorForLabels[[self.all_taps_label_list count]];
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        xcoorForLabels[i]=0;
    }
    
    double current_xcorr_value=0;
    
    for (int i=0; i<[self.all_taps_label_list count]; i++) { //for each label
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        for (int j=0; j<[currentLabel getNumberOfTapRecordings]; j++) { //for each recording of label
            currentTapRecording = [currentLabel getTapRecordingWithIndex:j];

            //get time reversed freq domain complex array and its length of the test tap
            DSPSplitComplex *tapRecordingMicFreqDomReverse = [self getFreqDomReversedArray:currentTapRecording];
            int complex_array_len = currentTapRecording->micFreqDomReversedLen;
            //freq domain xcorr of tap recording with template recording
            
            current_xcorr_value = [self.signalProcessor fftxcorr_TapRecording:recordingMicFreqDomForward withTapTemplate:tapRecordingMicFreqDomReverse ofLen:complex_array_len];
            
            //NSLog(@"fftxcorr w/ label:%d tap:%d =%f", currentLabel->labelID, currentTapRecording->tapID, current_xcorr_value);
            //do a sum
            xcoorForLabels[i] = xcoorForLabels[i] + current_xcorr_value;
        }
        //do an average of the sum
        xcoorForLabels[i] = xcoorForLabels[i]/[currentLabel getNumberOfTapRecordings];
        //NSLog(@"label%d, xcorr:%f",i, xcoorForLabels[i]);
    }
    
    bool bad_xcorr = true;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        if (xcoorForLabels[i] > self.confidenceThreashold) {
            bad_xcorr = false;
        }
    }
    if (bad_xcorr==true) {
        return -1;
    }
    
    double large=0;
    int best_match_label=-1;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        if (xcoorForLabels[i] > large) {
            best_match_label = currentLabel->labelID;
            large = xcoorForLabels[i];
        }
    }
        
    return best_match_label;
}


- (float *) getNormalizedMicArrayFrom:(YZZTapRecording *)recording {
    float *micArray = recording->SensorFifo[0]->getDataLinearNormalized();
    return micArray;
}

- (int)returnCrossCorrBestMatchWithTapRecordingsInAllLabels:(YZZTapRecording *)recording{
    float *recordingMicArray = [self getNormalizedMicArrayFrom:recording];
    
    YZZLabel *currentLabel;
    YZZTapRecording *currentTapRecording;
    float current_xcorr_value;
    float max_xcorr_value=0;
    int best_match_label;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        for (int j=0; j<[currentLabel getNumberOfTapRecordings]; j++) {
            currentTapRecording = [currentLabel getTapRecordingWithIndex:j];
//            current_xcorr_value = [self.signalProcessor crosscorrelateTapRecording1:recording andTapRecording2:currentTapRecording];
            
            float *micRef = [self getNormalizedMicArrayFrom:currentTapRecording];
            current_xcorr_value = [self.signalProcessor crosscorrelateMicInput:recordingMicArray WithMicRef:micRef ofLength:MIC_DATA_BUFF_SIZE];
            free(micRef);
            
            NSLog(@"xcorr w/ label:%d tap:%d =%f", currentLabel->labelID, currentTapRecording->tapID, current_xcorr_value);
            if (current_xcorr_value > max_xcorr_value) {
                max_xcorr_value = current_xcorr_value;
                best_match_label = currentLabel->labelID;
            }
        }
    }
    free(recordingMicArray);
    return best_match_label;
}

- (int)returnCrossCorrBestAverageMatchWithMultipleRecordings:(YZZTapRecording *)recording{
    
    float *recordingMicArray = [self getNormalizedMicArrayFrom:recording];
    
    YZZLabel *currentLabel;
    YZZTapRecording *currentTapRecording;
    
    double xcoorForLabels[[self.all_taps_label_list count]];
    double current_xcorr_value=0;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        xcoorForLabels[i]=0;
    }
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        for (int j=0; j<[currentLabel getNumberOfTapRecordings]; j++) {
            currentTapRecording = [currentLabel getTapRecordingWithIndex:j];
//            current_xcorr_value = [self.signalProcessor crosscorrelateTapRecording1:recording andTapRecording2:currentTapRecording];
            
            float *micRef = [self getNormalizedMicArrayFrom:currentTapRecording];
            current_xcorr_value = [self.signalProcessor crosscorrelateMicInput:recordingMicArray WithMicRef:micRef ofLength:MIC_DATA_BUFF_SIZE];
            free(micRef);
            
            xcoorForLabels[i] = xcoorForLabels[i] + current_xcorr_value;
            NSLog(@"xcorr w/ label:%d tap:%d =%f", currentLabel->labelID, currentTapRecording->tapID, current_xcorr_value);
        }
        
        xcoorForLabels[i] = xcoorForLabels[i]/[currentLabel getNumberOfTapRecordings];
    }
    free(recordingMicArray);

    double large=0;
    int best_match_label=-1;
    for (int i=0; i<[self.all_taps_label_list count]; i++) {
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        if (xcoorForLabels[i] > large) {
            best_match_label = currentLabel->labelID;
            large = xcoorForLabels[i];
        }
    }
    
    //average
    NSLog(@"avg %f %f", xcoorForLabels[0], xcoorForLabels[1]);
    
    return best_match_label;
}

- (int)returnCrossCorrBestMatchWithMultipleRecordingsUsingBestTemplates:(YZZTapRecording *)recording{
    float *recordingMicArray = [self getNormalizedMicArrayFrom:recording];
    
    YZZLabel *currentLabel;
    YZZTapRecording *currentTapRecording;
    
    int numberOfLabels = [self.best_templates_label_list count];
    double xcoorForLabels[numberOfLabels];
    double current_xcorr_value=0;
    for (int i=0; i<numberOfLabels; i++) {
        xcoorForLabels[i]=0;
    }
    for (int i=0; i<numberOfLabels; i++) {
        currentLabel = [self.best_templates_label_list objectAtIndex:i];
        //float currentLabelMax = 0;
        for (int j=0; j<[currentLabel getNumberOfTapRecordings]; j++) {
            currentTapRecording = [currentLabel getTapRecordingWithIndex:j];
//            current_xcorr_value = [self.signalProcessor crosscorrelateTapRecording1:recording andTapRecording2:currentTapRecording];
            float *micRef = [self getNormalizedMicArrayFrom:currentTapRecording];
            current_xcorr_value = [self.signalProcessor crosscorrelateMicInput:recordingMicArray WithMicRef:micRef ofLength:MIC_DATA_BUFF_SIZE];
            free(micRef);
            
            xcoorForLabels[i] = xcoorForLabels[i] + current_xcorr_value;
            NSLog(@"xcorr w/ label:%d tap:%d =%f", currentLabel->labelID, currentTapRecording->tapID, current_xcorr_value);
        }
        
        xcoorForLabels[i] = xcoorForLabels[i]/[currentLabel getNumberOfTapRecordings];
    }
    free(recordingMicArray);
    
    double large=0;
    int best_match_label=-1;
    for (int i=0; i<numberOfLabels; i++) {
        currentLabel = [self.all_taps_label_list objectAtIndex:i];
        if (xcoorForLabels[i] > large) {
            best_match_label = currentLabel->labelID;
            large = xcoorForLabels[i];
        }
    }
    
    //average
    NSLog(@"avg %f %f", xcoorForLabels[0], xcoorForLabels[1]);

    return best_match_label;
}

#pragma mark dealing with valid labels

- (YZZLabel *) getLabelFromValidLabelsListWithID:(int)labelID {
    YZZLabel *searchedLabel = nil;
    for (int i=0; i<[self.best_templates_label_list count]; i++) {
        searchedLabel = [self.best_templates_label_list objectAtIndex:i];
        if (searchedLabel->labelID == labelID) {
            return searchedLabel;
        }
    }
    return nil;
}

- (bool) createValidLabelWithID:(int)labelId {
    YZZLabel *searchedValidLabel = [self getLabelFromValidLabelsListWithID:labelId];
    if (searchedValidLabel == nil) {
        [self.best_templates_label_list addObject:[[YZZLabel alloc]initWithLabelID:labelId]];
        return true;
    }
    return false;
}

- (bool) removeValidLabelWithID:(int)labelId {
    YZZLabel *searchedValidLabel = [self getLabelFromValidLabelsListWithID:labelId];
    if (searchedValidLabel != nil) {
        [self.best_templates_label_list removeObject:searchedValidLabel];
        return true;
    }
    return false;
}

//-- invalidate_templates_which_are_not_best int labelID based on index array
- (bool) invalidateRecordingsBasedLowXCorrIndexGivenByTapIDArray:(NSMutableArray *)tapIDArray InRecordingLabel:(int)labelID {
    YZZLabel *searchRecordingLabel = [self getLabelFromAllLabelsListWithID:labelID];
    if (searchRecordingLabel != nil) {
        YZZTapRecording *tapRecording;
        int tapID;
        for (int i=0; i<[tapIDArray count]; i++) {
            tapID = [[tapIDArray objectAtIndex:i] intValue];
            tapRecording = [searchRecordingLabel getTapRecordingWithTapID:tapID];
            if (tapRecording != nil) {
                tapRecording->valid = false;
            } else assert(0);
        }
        return true;
    }
    return false;
}

//remove_invalid_templates_from_all_templates_label_list int labelID and return the tapid of those that were remeoved
- (NSMutableArray *) removeInvalidTemplatesFromRecordingsLabelID:(int)labelID {
    NSMutableArray *removedRecordingsWithTapIDArray=nil;
    NSNumber *tapID=nil;
    
    NSMutableIndexSet *indexesMarkedForRemoval = [[NSMutableIndexSet alloc]init];
    
    YZZLabel *searchedRecordingLabel = [self getLabelFromAllLabelsListWithID:labelID];
    if (searchedRecordingLabel != nil) {
        YZZTapRecording *tapRecording;
        for (int i=0; i<[searchedRecordingLabel getNumberOfTapRecordings]; i++) {
            tapRecording = [searchedRecordingLabel getTapRecordingWithIndex:i];
            if (tapRecording->valid == false) {
                tapID = [[NSNumber alloc]initWithInt:tapRecording->tapID];
                [removedRecordingsWithTapIDArray addObject:tapID];
                [indexesMarkedForRemoval addIndex:i];
            }
        }
    }
    [searchedRecordingLabel unregisterTapRecordingWithIndexes:indexesMarkedForRemoval];
    return removedRecordingsWithTapIDArray;
}

- (bool)removeTemplateWithTapID:(int)tapId fromValidLabelID:(int)labelId {
    YZZLabel *searchedLabel = [self getLabelFromValidLabelsListWithID:labelId];
    if (searchedLabel!=nil) {
        return [searchedLabel unregisterTapRecording:tapId];
    }
    return false;
}

@end
