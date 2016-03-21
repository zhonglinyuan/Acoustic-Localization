//
//  YZZLocationManager.h
//  SimpleTap
//
//  Created by Kai Zou on 2012-12-02.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZZLocation.h"
#import "YZZSignalProcessor.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface YZZLocationManager : NSObject
{
    int totalNumberOfLocations;
}
@property (strong, nonatomic) NSMutableArray *locationArray;

-(id)initWithNumberOfLocations:(int)numberOfLocations;

-(YZZLocation *)getLocationObject:(int)locationIndex;

-(int)crosscorrelateAllLocations;

-(void)writeAllLocationBuffersToFiles;

-(void)addFilesAsAttachmentsWithComposer:(MFMailComposeViewController *)picker andFileName:(NSString *)fileName withTimeStamp:(NSTimeInterval)thisTimeInSeconds;

@end
