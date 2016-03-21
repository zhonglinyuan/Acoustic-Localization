//
//  YZZTemplateSelector.m
//  EngineTester
//
//  Created by ZhongLin Yuan on 2013-02-21.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZTemplateSelector.h"

@interface YZZTemplateSelector()
@property (strong, nonatomic) YZZSignalProcessor *signalProcessor;

@end

@implementation YZZTemplateSelector

@synthesize signalProcessor = _signalProcessor;

-(id)init {
    self = [super init];
    
    self.signalProcessor = [[YZZSignalProcessor alloc]init];
    
    return self;
}

-(NSMutableArray *)FindBestThreeTemplates:(YZZLabel *)myLabel
{
//    NSLog(@"inside my function!!!!!!!!!!");
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] init];
    NSNumber *t1 = [[NSNumber alloc]initWithInt:-1];
    NSNumber *t2 = [[NSNumber alloc]initWithInt:-1];
    NSNumber *t3 = [[NSNumber alloc]initWithInt:-1];
    [arrayToReturn addObject:t1];
    [arrayToReturn addObject:t2];
    [arrayToReturn addObject:t3];
    int numberOfRecordings = [myLabel getNumberOfTapRecordings];
//    numberOfRecordings = 10;   //<--- for testing purposes
    int logicMatrix[numberOfRecordings][numberOfRecordings];
    float crossCorrMatrix[numberOfRecordings][numberOfRecordings];
    float largestValue = 0;
    int i;
    int j;
    //initialize matrix
    for(i=0;i<numberOfRecordings;i++)
    {
        for(j=0; j<numberOfRecordings;j++)
        {
            logicMatrix[i][j] = 0;
        }
    }
    for (i=0; i<numberOfRecordings; i++)
    {
        for (j=i + 1; j<numberOfRecordings; j++)
        {
            YZZTapRecording *tmp1 = [myLabel getTapRecordingWithIndex:i];
            YZZTapRecording *tmp2 = [myLabel getTapRecordingWithIndex:j];
            
            
            float *temp1 = tmp1->SensorFifo[0]->getDataLinearNormalized();
            float *temp2 = tmp2->SensorFifo[0]->getDataLinearNormalized();
            int len = tmp1->SensorFifo[0]->length();
            float tmpCrossCorr = [self.signalProcessor crosscorrelateMicInput:temp1 WithMicRef:temp2 ofLength:len];
//            float tmpCrossCorr = [self.signalProcessor crosscorrelateTapRecording1:tmp1 andTapRecording2:tmp2];
            free(temp1);
            free(temp2);
            if (tmpCrossCorr > largestValue)
            {
                largestValue = tmpCrossCorr;
                [arrayToReturn replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:i]];
                [arrayToReturn replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:j]];
            }
            crossCorrMatrix[i][j] = tmpCrossCorr;
            NSLog(@"xcorrr %f", tmpCrossCorr);
            if (tmpCrossCorr > XCORR_THRESHOLD)
                logicMatrix[i][j] = 1;
        }
    } 
    //for testing purposes-----------------------
/*    for (i=0; i<numberOfRecordings; i++)
    {
        for (j=0; j<numberOfRecordings; j++)
        {
            if(i==2 && j==9){
            logicMatrix[i][j]=1;
                
            }
            else if(i==3 && j==9)
                logicMatrix[i][j]=1;
            else if(i==2 && j==3)
                logicMatrix[i][j]=1;
            else
                logicMatrix[i][j]=0;
            
        }
    }
    printf("hello %d\n",            logicMatrix[1][7]);

    for(i=0; i<numberOfRecordings; i++)
    {
        NSLog(@"%d %d %d %d %d %d %d %d %d %d", logicMatrix[i][0],logicMatrix[i][1],logicMatrix[i][2],logicMatrix[i][3],logicMatrix[i][4],logicMatrix[i][5],logicMatrix[i][6],logicMatrix[i][7],logicMatrix[i][8],logicMatrix[i][9] );
    }*/
    float largestSum = 0;
    
    for (i=0; i<numberOfRecordings; i++)
    {
        for (j=i + 1; j<numberOfRecordings; j++)
        {
            if (logicMatrix[i][j] == 1)
            {
                int k;
                for (k=i+1; k<j; k++)
                {
                    if(logicMatrix[k][j] ==1)
                    {
                        if(logicMatrix[i][k] ==1)
                        {
                            float sum = crossCorrMatrix[i][j] + crossCorrMatrix[k][j] + crossCorrMatrix[i][k];
                            if(sum > largestSum)
                            {
                                largestSum = sum;
                                NSNumber *best1 = [NSNumber numberWithInt:[myLabel getTapRecordingWithIndex:i]->tapID];
                                NSNumber *best2 = [NSNumber numberWithInt:[myLabel getTapRecordingWithIndex:j]->tapID];
                                NSNumber *best3 = [NSNumber numberWithInt:[myLabel getTapRecordingWithIndex:k]->tapID];
                                [arrayToReturn replaceObjectAtIndex:0 withObject:best1];
                                [arrayToReturn replaceObjectAtIndex:1 withObject:best2];
                                [arrayToReturn replaceObjectAtIndex:2 withObject:best3];
                                NSLog(@"--------------got inside1!------------");
                                NSLog(@"the indices are %d %d %d",i,j,k);
                            }
                        }
                    }
                }
                for(k=j+1;k<numberOfRecordings;k++)
                {
                    if(logicMatrix[j][k] == 1)
                    {
                        if(logicMatrix[i][k])
                        {
                            float sum = crossCorrMatrix[i][j] + crossCorrMatrix[k][j] + crossCorrMatrix[i][k];
                            if(sum > largestSum)
                            {
                                largestSum = sum;
                                NSNumber *best1 = [NSNumber numberWithInt:[myLabel getTapRecordingWithIndex:i]->tapID];
                                NSNumber *best2 = [NSNumber numberWithInt:[myLabel getTapRecordingWithIndex:j]->tapID];
                                NSNumber *best3 = [NSNumber numberWithInt:[myLabel getTapRecordingWithIndex:k]->tapID];
                                [arrayToReturn replaceObjectAtIndex:0 withObject:best1];
                                [arrayToReturn replaceObjectAtIndex:1 withObject:best2];
                                [arrayToReturn replaceObjectAtIndex:2 withObject:best3];
                                NSLog(@"-----------------got inside2!-------------");
                                NSLog(@"the indices are %d %d %d",i,j,k);
                            }
                        }
                    }
                }
            }
        }
    }
    
    return arrayToReturn;
}
@end
