//
//  YZZTapManager.m
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZLabel.h"

@interface YZZLabel()
//@property (strong, nonatomic) NSFileManager *myFileManager;
@property (strong, nonatomic) NSMutableArray *tapRecordingList;
@end

@implementation YZZLabel

//@synthesize myFileManager = _myFileManager;
@synthesize tapRecordingList = _tapRecordingList;

-(id)initWithLabelID:(int)Id {
    self = [super init];
    self->labelID = Id;
    self.tapRecordingList = [[NSMutableArray alloc]init];
    NSLog(@"created label:%d",self->labelID);
    return self;
}

-(bool)registerTapRecording:(YZZTapRecording *)tapRecording withTapID:(int)tapId withLabel:(int)labelId{
    YZZTapRecording *searchTapRecording = [self getTapRecordingWithTapID:tapId];
    
    if (searchTapRecording == nil) {
        [tapRecording registerTapRecordingID:tapId withLabel:labelId];
        [self.tapRecordingList addObject:tapRecording];
//        NSLog(@"registered tapRecording labelID:%d tapID:%d", labelId, tapId);
        return true;
    }
//    NSLog(@"failed register tapRecording labelID:%d tapID:%d", labelId, tapId);
    return false;
}

-(bool)unregisterAllTapRecordings {
    [self.tapRecordingList removeAllObjects];
//    NSLog(@"unregisteredAllTapRecordings, #ofRecordings:%d", [self.tapRecordingList count]);
    return true;
}

-(bool)unregisterTapRecording:(int)tapId {
    YZZTapRecording *searchedTapRecording = [self getTapRecordingWithTapID:tapId];
    
    if (searchedTapRecording!=nil) {
        [self.tapRecordingList removeObject:searchedTapRecording];
//        NSLog(@"unregistered tapRecording labelID:%d tapID:%d", self->labelID, tapId);
        return true;
    }
//    NSLog(@"failed unregister tapRecording labelID:%d tapID:%d", self->labelID, tapId);
    return false;
}

-(bool)unregisterTapRecordingWithIndexes:(NSMutableIndexSet *)indexesMarkedForRemoval {
    if ([indexesMarkedForRemoval count] > 0) {
        [self.tapRecordingList removeObjectsAtIndexes:indexesMarkedForRemoval];
        return true;
    }
    return false;
}

-(bool)invalidateTapRecording:(int)tapId {
    YZZTapRecording *searchedTapRecording = [self getTapRecordingWithTapID:tapId];
    
    if (searchedTapRecording != nil) {
        searchedTapRecording->valid = false;
//        NSLog(@"invalidated tapRecording labelID:%d tapID:%d", self->labelID, tapId);
        return true;
    }
//    NSLog(@"failed invalidate tapRecording labelID:%d tapID:%d", self->labelID, tapId);
    return false;
}

-(int)getNumberOfTapRecordings {
    return [self.tapRecordingList count];
}

-(YZZTapRecording *) getTapRecordingWithTapID:(int)tapId {
    YZZTapRecording *tapRecording;
    for (int i=0; i<[self.tapRecordingList count]; i++) {
        tapRecording = [self.tapRecordingList objectAtIndex:i];
        if (tapRecording->tapID == tapId) {
            return tapRecording;
        }
    }
    return nil;
}

-(YZZTapRecording *)getTapRecordingWithIndex:(int)index {
    if (index < [self.tapRecordingList count]) {
        return [self.tapRecordingList objectAtIndex:index];
    }
    return nil;
}

@end