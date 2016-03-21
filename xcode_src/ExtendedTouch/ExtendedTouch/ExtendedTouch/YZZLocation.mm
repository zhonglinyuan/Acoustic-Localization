//
//  YZZLocation.m
//  SimpleTap
//
//  Created by Kai Zou on 2012-12-02.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import "YZZLocation.h"

@interface YZZLocation ()
    @property (strong, nonatomic) NSFileManager *myFileManager;
@end

@implementation YZZLocation

//begin code improvements
@synthesize myFileManager = _myFileManager;

@synthesize SensorBufferNames = _SensorBufferNames;
@synthesize SensorFileNames = _SensorFileNames;
@synthesize SensorFilePaths = _SensorFilePaths;
@synthesize SensorFileHandles = _SensorFileHandles;
//end code improvements

-(id) initWithLocationID:(int)locID {
    self = [super init];
    
    self.SensorFileNames = [[NSMutableArray alloc]init];
    self.SensorFilePaths = [[NSMutableArray alloc]init];
    self.SensorFileHandles = [[NSMutableArray alloc]init];
    //create the buffer names
    self.SensorBufferNames = [NSMutableArray arrayWithObjects:@"Mic", @"AccX", @"AccY", @"AccZ", @"GyroX", @"GyroY", @"GyroZ", nil];
    
    self->LocationID = locID;
    self->totalNumberOfSensors = TOTAL_NUMBER_OF_SENSORS;
    
    //create the sensor fifos
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
            self->SensorFifo[i] = new FixedFifo(MIC_DATA_BUFF_SIZE, MIC_DATA_BUFF_SIZE_TRIGGER);
            NSLog(@"fifo %d created", i);
        }
        else {
            self->SensorFifo[i] = new FixedFifo(DATA_BUFF_STRUCT_SIZE, DATA_BUFF_STRUCT_SIZE_TRIGGER);
            NSLog(@"fifo %d created", i);
        }
    }
    
    //create the sensor file names
    NSString *tmpStr;
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        tmpStr = [[NSString alloc] initWithFormat:@"%@_%d.txt", [self.SensorBufferNames objectAtIndex:i], self->LocationID];
        [self.SensorFileNames addObject:tmpStr];
        NSLog(@"asdf %@", [self.SensorFileNames objectAtIndex:i]);
    }
    
    //creating file paths for each sensor
    self.myFileManager = [NSFileManager defaultManager];
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *tempPathString;
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        tempPathString = [[NSString alloc]initWithString:[myPathList objectAtIndex:0]];
        tempPathString = [tempPathString stringByAppendingPathComponent:[self.SensorFileNames objectAtIndex:i]];
        [self.SensorFilePaths addObject:tempPathString];
    }
    
    [self clearAllFiles]; //make sure no files exist
    //end code improvements
    
    return self;
}

-(void)clearAllBuffers {
    for (int i=0;i<TOTAL_NUMBER_OF_SENSORS;i++) {
        self->SensorFifo[i]->clearAll();
    }
}

-(void) clearAllFiles {
    for (int i=0;i<TOTAL_NUMBER_OF_SENSORS;i++) {
        if (![self.myFileManager fileExistsAtPath:[self.SensorFilePaths objectAtIndex:i]]) {
            [self.myFileManager removeItemAtPath:[self.SensorFilePaths objectAtIndex:i] error:nil];
            NSLog(@"cleared file at %@", [self.SensorFilePaths objectAtIndex:i]);
        }
    }
}
-(void)createFilesAndAttacheFileHandlesForAllBuffers {
    //create files and attach file handles
    for (int i=0; i<TOTAL_NUMBER_OF_SENSORS; i++) {
        [self.myFileManager createFileAtPath:[self.SensorFilePaths objectAtIndex:i] contents:nil attributes:nil];
        [self.SensorFileHandles addObject:[NSFileHandle fileHandleForUpdatingAtPath:[self.SensorFilePaths objectAtIndex:i]]];
        NSLog(@"created file at:%@",[self.SensorFilePaths objectAtIndex:i]);
    }
}

-(void) writeAllBuffersToFile {
    for (int i=0;i<TOTAL_NUMBER_OF_SENSORS; i++) {
        float *linearBuffer = self->SensorFifo[i]->getDataLinear();

        if ([[self.SensorBufferNames objectAtIndex:i] isEqualToString:@"Mic"]) {
                    NSLog(@"blah MIC");
            for (int j=0;j<MIC_DATA_BUFF_SIZE;j++) { //for mic
                NSString *bufferString = [[NSString alloc]initWithFormat:@"%f\n", linearBuffer[j]];
                [[self.SensorFileHandles objectAtIndex:i] writeData:[bufferString dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        else {
            NSLog(@"blah OTHER sensors");
            for (int j=0;j<DATA_BUFF_STRUCT_SIZE;j++) { //for other sensors
                NSString *bufferString = [[NSString alloc]initWithFormat:@"%f\n", linearBuffer[j]];
                [[self.SensorFileHandles objectAtIndex:i] writeData:[bufferString dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        
        [[self.SensorFileHandles objectAtIndex:i] closeFile];
        free(linearBuffer);
    }
}


@end
