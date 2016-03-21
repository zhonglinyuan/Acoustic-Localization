//
//  YZZTapManager.h
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "YZZTapRecording.h"
#import "YZZSignalProcessor.h"
//#import <MessageUI/MFMailComposeViewController.h>

@interface YZZLabel : NSObject
{
    @public
    int labelID;
}

-(id)initWithLabelID:(int)Id;

-(bool)registerTapRecording:(YZZTapRecording *)tapRecording withTapID:(int)tapId withLabel:(int)labelId; //done

-(bool)invalidateTapRecording:(int)tapId;
-(bool)unregisterAllTapRecordings; //done
-(bool)unregisterTapRecording:(int)tapId; //done
-(bool)unregisterTapRecordingWithIndexes:(NSMutableIndexSet *)indexesMarkedForRemoval;

-(int)getNumberOfTapRecordings;
-(YZZTapRecording *)getTapRecordingWithTapID:(int)tapId;
-(YZZTapRecording *)getTapRecordingWithIndex:(int)index;



@end
