//
//  YZZLocationManager.m
//  SimpleTap
//
//  Created by Kai Zou on 2012-12-02.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import "YZZLocationManager.h"

@interface YZZLocationManager()
@property (strong, nonatomic) NSFileManager *myFileManager;
@property (strong, nonatomic) YZZSignalProcessor *signalProcessor;
@end

@implementation YZZLocationManager

@synthesize myFileManager;
@synthesize signalProcessor;
@synthesize locationArray;


-(id)initWithNumberOfLocations:(int)numberOfLocations {
    self = [super init];

    //create a signal processor
    self.signalProcessor = [[YZZSignalProcessor alloc]init];
    
    totalNumberOfLocations = numberOfLocations;
    
    //create the location objects
    locationArray = [[NSMutableArray alloc]init];
    for (int i=0; i<totalNumberOfLocations;i++) {
        [locationArray addObject:[[YZZLocation alloc]initWithLocationID:i]];
    }
    
    return self;
}

-(YZZLocation *)getLocationObject:(int)locationIndex{
    return [locationArray objectAtIndex:locationIndex];
}

-(int)crosscorrelateAllLocations{
    int largest_correlated_location=0;
    float largest_correlated_value=0;
    float correlated_value=0;
    for (int i=1; i<totalNumberOfLocations; i++) {
        correlated_value = [self.signalProcessor crosscorrelateLocation1:[locationArray objectAtIndex:i] andLocation2:[locationArray objectAtIndex:0]];
        if (correlated_value > largest_correlated_value) {
            largest_correlated_value = correlated_value;
            largest_correlated_location = i;
        }
    }
    [self template_check_sum];
    return largest_correlated_location;
}

-(void) template_check_sum {
    float sum = 0;
    
    float *mic;
    for (int i=0; i<totalNumberOfLocations; i++) {
        sum = 0;
        YZZLocation *currLocation = [locationArray objectAtIndex:i];
        mic = currLocation->SensorFifo[0]->getDataLinear(); //this is alloc mem, need to free later
        for (int j=0; j<MIC_DATA_BUFF_SIZE; j++) {
            sum = sum + mic[j];
        }
        free(mic);
        printf("check sum %d = %f\n", i, sum);
    }
}

#pragma mark filemanagment and emailing

//-(void)addFilesAsAttachmentsWithComposer:(MFMailComposeViewController *)picker andFileName:(NSString *)fileName withTimeStamp:(NSTimeInterval)thisTimeInSeconds {
    
-(void)addFilesAsAttachmentsWithComposer:(MFMailComposeViewController *)picker andFileName:(NSString *)fileName withTimeStamp:(NSTimeInterval)thisTimeInSeconds withActualTappedLocation:(int)actualLocation withPredictedTappedLocation:(int)predictedLocation {
    
    YZZLocation *currLocation;
    for (int i=0;i<totalNumberOfLocations;i++) {
        currLocation = [locationArray objectAtIndex:i];
        
        for (int j=0;j<currLocation->totalNumberOfSensors;j++) {
            NSData *bufferData = [NSData dataWithContentsOfFile:[currLocation.SensorFilePaths objectAtIndex:j]];
            NSString *bufferFileName = [[NSString alloc] initWithFormat:@"%@_%f_%d_%d_%@",fileName, thisTimeInSeconds,actualLocation, predictedLocation,[currLocation.SensorFileNames objectAtIndex:j]];
            [picker addAttachmentData:bufferData mimeType:@"text/plain" fileName:bufferFileName];
        }
    }
}

-(void)writeAllLocationBuffersToFiles {
    YZZLocation *currLocation;
    for (int i=0;i<totalNumberOfLocations;i++) {
        //each location in the location array
        currLocation = [locationArray objectAtIndex:i];
        //make sure to start with fresh files first
        [currLocation clearAllFiles];
        //create the files and attach file handles
        [currLocation createFilesAndAttacheFileHandlesForAllBuffers];
        
        //write all buffers to file
        [currLocation writeAllBuffersToFile];
    }
    NSLog(@"finished write to files");
}

@end
