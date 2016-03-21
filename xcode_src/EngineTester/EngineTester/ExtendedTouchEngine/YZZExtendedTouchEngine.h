//
//  YZZExtendedTouchEngine.h
//  EngineTester
//
//  Created by Kai Zou on 2013-01-25.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "YZZSensorController.h"
#import "YZZLabel.h"
#import "YZZTapRecording.h"
#include "FixedFifo.h"
#include "YZZTemplateSelector.h"
#import <dispatch/dispatch.h>

#define NUMBER_OF_BEST_MATCH_TEMPLATES 3

#define XCORR_DECISION_THREASHOLD 0.5

@interface YZZExtendedTouchEngine : NSObject

@property (nonatomic) float confidenceThreashold;

//init engine with "Continuous" or "Start_stop" mode
- (id)initWithSensorMode:(int)mode_flag;//(SensorMode)mode_flag; //done

//not implemented
- (void)uninitialize; //skipped

//dealing with all recordings labels list
- (bool)registerLabel:(int)labelId; //done
- (bool)unregisterLabel:(int)labelId; //done
- (YZZLabel *) getLabelFromAllLabelsListWithID:(int)labelID;

//dealing with tap recordings
- (YZZTapRecording *)sync_startRecordNextTap:(bool *)tapEventDetected; //done
- (bool)registerTap:(YZZTapRecording *)tapRecording WithTap:(int)tapId andLabel:(int)labelId; //done
- (int)numberOfRegisteredTapsAtLabelID:(int)labelID;
- (bool)unregisterAllTapsWithLabel:(int)label; //done
- (bool)unregisterTapWithTapID:(int)tap andLabel:(int)label; //done
- (bool)invalidateTapWithTapID:(int)tap andLabel:(int)label;
- (YZZTapRecording *)deepCopyTapRecording:(YZZTapRecording *)sourceTapRecording;
-(bool) getMicCaptureBufferIsFull;

//helper functions
- (void) sync_performEnvironmentCalibration; //done
- (bool) isRecordingNextTap;
- (void) stopRecordingNextTap;

//finding best match template
- (int)returnCrossCorrBestMatchWithTapRecordingsInAllLabels:(YZZTapRecording *)recording;
- (int)returnCrossCorrBestAverageMatchWithMultipleRecordings:(YZZTapRecording *)recording;
- (int)returnCrossCorrBestMatchWithMultipleRecordingsUsingBestTemplates:(YZZTapRecording *)recording;

- (int)returnFFTCrossCorrBestMatchWithTapRecordingsInAllLabels:(YZZTapRecording *)recording;
- (int)returnFFTCrossCorrBestAverageMatchWithMultipleRecordings:(YZZTapRecording *)recording;

//deciding which templates to use
- (NSMutableArray *) findBestKTemplates:(int)clique_Size fromLabelID:(int)labelID;

//dealing with "best" templates
//-- create_best_label_list with labelID
- (bool) createValidLabelWithID:(int)labelId;

//-- remove_best_label_list with labelID
- (bool) removeValidLabelWithID:(int)labelId;

//-- invalidate_templates_which_are_not_best int labelID based on index array
- (bool) invalidateRecordingsBasedLowXCorrIndexGivenByTapIDArray:(NSMutableArray *)tapIDArray InRecordingLabel:(int)labelID;

//-- remove_invalid_templates_from_all_templates_label_list int labelID and return the tapid of those that were remeoved
- (NSMutableArray *) removeInvalidTemplatesFromRecordingsLabelID:(int)labelID;

//-- remove_template_from_best_label_list with tapID and labelID
- (bool)removeTemplateWithTapID:(int)tapId fromValidLabelID:(int)labelId;

@end
