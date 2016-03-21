//
//  YZZViewController.m
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import "YZZViewController.h"
#import "AudioUnit/AudioUnit.h"
#import "CAXException.h"
#include "CAHostTimeBase.h"

#define ACCEL_THRESHHOLD 0.04
#define MIC_THRESHOLD 20

@interface YZZViewController ()
@property (strong, nonatomic) NSFileManager *myFileManager;
@property (strong, nonatomic) NSFileHandle *accelLoc01FileHandle;
@property (strong, nonatomic) NSFileHandle *micLoc01FileHandle;
@property (strong, nonatomic) NSFileHandle *accelLoc02FileHandle;
@property (strong, nonatomic) NSFileHandle *micLoc02FileHandle;
@property (strong, nonatomic) NSFileHandle *accelCaptureFileHandle;
@property (strong, nonatomic) NSFileHandle *micCaptureFileHandle;
@property (strong, nonatomic) NSString *accelLoc01FilePath;
@property (strong, nonatomic) NSString *micLoc01FilePath;
@property (strong, nonatomic) NSString *accelLoc02FilePath;
@property (strong, nonatomic) NSString *micLoc02FilePath;
@property (strong, nonatomic) NSString *accelCaptureFilePath;
@property (strong, nonatomic) NSString *micCaptureFilePath;

@end

@implementation YZZViewController {
//    float output01[OUTPUT_MIC_CONV_SIZE];
//    float output02[OUTPUT_MIC_CONV_SIZE];
    float *micLoc01;
    float *micLoc02;
    float *micInput;
    NSLock *myLock;
//    Convolution *myCrossCorr;
}

@synthesize	rioUnit;
@synthesize unitHasBeenCreated;
@synthesize unitIsRunning;
@synthesize inputProc;
@synthesize dcFilter;

//@synthesize dataCapturer;
//@synthesize myCrossCorr;

@synthesize motionManager;

//file managment
@synthesize myFileManager;
@synthesize accelLoc01FileHandle;
@synthesize micLoc01FileHandle;
@synthesize accelLoc02FileHandle;
@synthesize micLoc02FileHandle;
@synthesize accelCaptureFileHandle;
@synthesize micCaptureFileHandle;

@synthesize accelLoc01FilePath;
@synthesize micLoc01FilePath;
@synthesize accelLoc02FilePath;
@synthesize micLoc02FilePath;
@synthesize accelCaptureFilePath;
@synthesize micCaptureFilePath;

- (void)viewDidLoad
{   
    [super viewDidLoad];
    myLock = [[NSLock alloc]init];
    
    CircularBuffer myBuff(100);
    myBuff.push(1);
    myBuff.print();

    NSLog(@"mid=%f",myBuff.getMid());
    NSLog(@"trigger=%f",myBuff.get(myBuff.length()/10));
    
    
    for (int i=1; i<60; i++) {
        myBuff.push(i);
    }
    myBuff.print();
    NSLog(@"mid=%f",myBuff.getMid());
    NSLog(@"trigger=%f",myBuff.get(myBuff.length()/10));
    
    for (int i=60; i<100; i++) {
        myBuff.push(i);
    }
    myBuff.print();
    NSLog(@"mid=%f",myBuff.getMid());
    NSLog(@"trigger=%f",myBuff.get(myBuff.length()/10));
    
    for (int i=100; i<550; i++) {
        myBuff.push(i);
    }
    myBuff.print();
    NSLog(@"mid=%f",myBuff.getMid());
    NSLog(@"trigger=%f",myBuff.get(myBuff.length()/10));
    
//    myCrossCorr = [[Convolution alloc]init];
    
//    for (int i=0; i<OUTPUT_MIC_CONV_SIZE; i++) {
//        output01[i] = 0;
//        output02[i] = 0;
//    }
    
    //setup filemanager and file handlers
    self.myFileManager = [NSFileManager defaultManager];
    //setup filepaths
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.accelLoc01FilePath = [myPathList objectAtIndex:0];
    self.micLoc01FilePath = [myPathList objectAtIndex:0];
    self.accelLoc02FilePath = [myPathList objectAtIndex:0];
    self.micLoc02FilePath = [myPathList objectAtIndex:0];
    self.accelCaptureFilePath = [myPathList objectAtIndex:0];
    self.micCaptureFilePath = [myPathList objectAtIndex:0];
    self.accelLoc01FilePath = [self.accelLoc01FilePath stringByAppendingPathComponent:@"accelLoc01Data.txt"];
    self.micLoc01FilePath = [self.micLoc01FilePath stringByAppendingPathComponent:@"micLoc01Data.txt"];
    self.accelLoc02FilePath = [self.accelLoc02FilePath stringByAppendingPathComponent:@"accelLoc02Data.txt"];
    self.micLoc02FilePath = [self.micLoc02FilePath stringByAppendingPathComponent:@"micLoc02Data.txt"];
    self.accelCaptureFilePath = [self.accelCaptureFilePath stringByAppendingPathComponent:@"accelCaptureData.txt"];
    self.micCaptureFilePath = [self.micCaptureFilePath stringByAppendingPathComponent:@"micCaptureData.txt"];

    //always start with clear files
    if ([self.myFileManager fileExistsAtPath:self.accelLoc01FilePath]) {
        [self.myFileManager removeItemAtPath:self.accelLoc01FilePath error:nil];
    }
    if ([self.myFileManager fileExistsAtPath:self.micLoc01FilePath]) {
        [self.myFileManager removeItemAtPath:self.micLoc01FilePath error:nil];
    }
    if ([self.myFileManager fileExistsAtPath:self.accelLoc02FilePath]) {
        [self.myFileManager removeItemAtPath:accelLoc02FilePath error:nil];
    }
    if (![self.myFileManager fileExistsAtPath:self.micLoc02FilePath]) {
        [self.myFileManager removeItemAtPath:micLoc02FilePath error:nil];
    }
    if (![self.myFileManager fileExistsAtPath:self.accelCaptureFilePath]) {
        [self.myFileManager removeItemAtPath:accelCaptureFilePath error:nil];
    }
    if (![self.myFileManager fileExistsAtPath:self.micCaptureFilePath]) {
        [self.myFileManager removeItemAtPath:self.micCaptureFilePath error:nil];
    }
    
    //create files and attach file handles
    [self.myFileManager createFileAtPath:self.accelLoc01FilePath contents:nil attributes:nil];
    self.accelLoc01FileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.accelLoc01FilePath];
    NSLog(@"create file success:%@",self.accelLoc01FilePath);
    [self.myFileManager createFileAtPath:self.micLoc01FilePath contents:nil attributes:nil];
    self.micLoc01FileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.micLoc01FilePath];
    NSLog(@"create file success:%@",self.micLoc01FilePath);
    [self.myFileManager createFileAtPath:self.accelLoc02FilePath contents:nil attributes:nil];
    self.accelLoc02FileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.accelLoc02FilePath];
    NSLog(@"create file success:%@",self.accelLoc02FilePath);
    [self.myFileManager createFileAtPath:self.micLoc02FilePath contents:nil attributes:nil];
    self.micLoc02FileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.micLoc02FilePath];
    NSLog(@"create file success:%@",self.micLoc02FilePath);
    [self.myFileManager createFileAtPath:self.accelCaptureFilePath contents:nil attributes:nil];
    self.accelCaptureFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.accelCaptureFilePath];
    NSLog(@"create file success:%@",self.accelCaptureFilePath);
    [self.myFileManager createFileAtPath:self.micCaptureFilePath contents:nil attributes:nil];
    self.micCaptureFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.micCaptureFilePath];
    NSLog(@"create file success:%@",self.micCaptureFilePath);

    
    NSLog(@"KEVIN AA");
    //setup acc and gyr handler
    self.motionManager = [[CMMotionManager alloc]init];
    
    //setup audio data hanlder
    BOOL initAudioDataSuccess = [self initializeAudioData];
    if (!initAudioDataSuccess) {
        NSLog(@"error during initializeAudioData");
    }
    
    
    ////----experiment with vDSP_conv-----/////
    //---expm #4---//
    NSLog(@"expm4");
    float          *signal, *filter, *result;
    uint32_t        lenSignal, filterLength, resultLength;
    uint32_t        i;
    
    filterLength = 5;
    resultLength = filterLength*2 -1;
//works    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    lenSignal = filterLength + resultLength;
    
    printf("\nConvolution ( resultLength = %d, "
           "filterLength = %d, lenSignal=%d)\n\n", resultLength, filterLength, lenSignal);
    
    /* Allocate memory for the input operands and check its availability. */
    signal = (float *) malloc(lenSignal * sizeof(float));
    filter = (float *) malloc(filterLength * sizeof(float));
    result = (float *) malloc(resultLength * sizeof(float));
    memset(signal, 0, lenSignal*sizeof(float));
    memset(filter, 0, filterLength*sizeof(float));
    memset(result, 0, resultLength*sizeof(float));
    
    for (i = 0; i < filterLength; i++)
        filter[i] = (float)1.0;
    
    for (i = 0; i < resultLength; i++)
        if (i >=resultLength-filterLength)
            signal[i] = 1.0;//filter[i - filterLength+1];
    
    /* Correlation. */
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);
    
    printf("signal: ");
    for (i = 0; i < lenSignal; i++)
        printf("%2.1f \n", signal[i]);
    
    printf("\n filter: ");
    for (i = 0; i < filterLength; i++)
        printf("%2.1f \n", filter[i]);
    
    printf("\n result: ");
    for (i = 0; i < resultLength; i++)
        printf("%2.1f \n", result[i]);
    
    
    /* Free allocated memory. */
    free(signal);
    free(filter);
    free(result);
    NSLog(@"done");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"memory issue");
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailDataButton:(id)sender {
    if (calibratingLoc01 || calibratingLoc02 || detectingInput) {
        return;
    }
    //populate the files
    NSLog(@"starting write to files");
    float *accelLoc01 = accelLoc01Buffer->getDataLinear();
    float *accelLoc02 = accelLoc02Buffer->getDataLinear();
    float *accelCapture = accelCaptureBuffer->getDataLinear();
    for (int i=0; i<DATA_BUFF_STRUCT_SIZE; i++) {
        NSString *accelLoc01String = [[NSString alloc]initWithFormat:@"AzLoc01:%f\n", accelLoc01[i]];
        [self.accelLoc01FileHandle writeData:[accelLoc01String dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *accelLoc02String = [[NSString alloc]initWithFormat:@"AzLoc02:%f\n", accelLoc02[i]];
        [self.accelLoc02FileHandle writeData:[accelLoc02String dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *accelCaptureString = [[NSString alloc]initWithFormat:@"AzCapture:%f\n", accelCapture[i]];
        [self.accelCaptureFileHandle writeData:[accelCaptureString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.accelLoc01FileHandle closeFile];
    [self.accelLoc02FileHandle closeFile];
    [self.accelCaptureFileHandle closeFile];
    free(accelLoc01);
    free(accelLoc02);
    free(accelCapture);
    
    float *_micLoc01 = micLoc01Buffer->getDataLinear();
    float *_micLoc02 = micLoc02Buffer->getDataLinear();
    float *_micCapture = micCaptureBuffer->getDataLinear();
    for (int i=0; i<micLoc01Buffer->maxLength(); i++) {
        NSString *micLoc01String = [[NSString alloc]initWithFormat:@"MicLoc01:%f\n", _micLoc01[i]];
        [self.micLoc01FileHandle writeData:[micLoc01String dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *micLoc02String = [[NSString alloc]initWithFormat:@"MicLoc02:%f\n", _micLoc02[i]];
        [self.micLoc02FileHandle writeData:[micLoc02String dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *micCaptureString = [[NSString alloc]initWithFormat:@"MicCapture:%f\n", _micCapture[i]];
        [self.micCaptureFileHandle writeData:[micCaptureString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.micLoc01FileHandle closeFile];
    [self.micLoc02FileHandle closeFile];
    [self.micCaptureFileHandle closeFile];
    free(_micLoc01);
    free(_micLoc02);
    free(_micCapture);
    NSLog(@"finished write to files");
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        [self displayComposerSheet];
    }
}

- (IBAction)ButtonStoreLocation1:(id)sender {
    if (calibratingLoc01==true) {
        self.Location1StoreStatusLabel.text = @"tap a surface now!";
    }
    else if (calibratingLoc02 == true || detectingInput == true) {
        self.Location1StoreStatusLabel.text = @"SOMETHING ELSE IS RUNNING"; //print to screen
    } else {
        calibratingLoc01=true;
        self.StoreLoc02Button.enabled = NO;
        self.StoreLoc02Button.alpha = 0.4;
        
        //turn on audio sesson
        XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        //turn on operationqueue for accel
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.0;
        
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
             if (error) {
                 calibratingLoc01=false;
                 [self.motionManager stopAccelerometerUpdates];
             } else {
                 //store accel data
                 accelLoc01Buffer->push((float)self.motionManager.accelerometerData.acceleration.z);
                 float computedThresholdValue = 0;
                 if (accelLoc01Buffer->isEmpty()==false)
                 {
//                     computedThresholdValue = accelLoc01Buffer->get(DATA_BUFF_STRUCT_SIZE/10) + 1.035;
//                     computedThresholdValue = accelLoc01Buffer->get((accelLoc01Buffer->length())/10) + 1.035;
                     computedThresholdValue = accelLoc01Buffer->getMid() + 1.035;
//                     NSLog(@"computedThresholdValue = %f", computedThresholdValue);
                     computedThresholdValue = (computedThresholdValue<0 ? (computedThresholdValue*-1.0):computedThresholdValue);
                 }
                 
                 //if threshold value attained, then stop the audio session, stop accel, stop gyro
                 if (computedThresholdValue > ACCEL_THRESHHOLD) {
                     [self.motionManager stopAccelerometerUpdates];
                     XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
                     XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
                     
                     self.Location1StoreStatusLabel.text = @"Location 1 STORED"; //print to screen
                     self.StoreLoc02Button.enabled = YES;
                     self.StoreLoc02Button.alpha = 1.0;
                     calibratingLoc01=false;
                     NSLog(@"location 1 stored");
                 }
             }
         }];
        
        //turn on operationqueue for gyro
/*        NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
        self.motionManager.gyroUpdateInterval = (double) 0.01001;
        [self.motionManager startGyroUpdatesToQueue:queue2 withHandler:
         ^(CMGyroData *gyroData, NSError *error) {
             if (error) {
                 [self.motionManager stopGyroUpdates];
             } else {
                 //store gyro data here
                 myDataQueuer.loc01GyrData->push((float)self.motionManager.gyroData.rotationRate.x);
                 //bill myDataQueuer.enqueueLoc01GyrData((float)self.motionManager.gyroData.rotationRate.x);
             }
         }];
 */
    
    }
}

- (IBAction)ButtonStoreLocation2:(id)sender {
    
    if (calibratingLoc02==true) {
        self.Location2StoreStatusLabel.text = @"tap a surface now!";
    }
    else if (calibratingLoc01 == true || detectingInput == true ) {
        self.Location2StoreStatusLabel.text = @"SOMETHING ELSE IS RUNNING"; //print to screen
    } else {
        calibratingLoc02 = true;
        self.StoreLoc01Button.enabled = NO;
        self.StoreLoc01Button.alpha = 0.4;

        //turn on audio sesson
        XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        
        //turn on operationqueue for accel
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.0;
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:
         ^(CMAccelerometerData *accelerometerData, NSError *error){
             if (error) {
                 calibratingLoc02=false;
                 [self.motionManager stopAccelerometerUpdates];
             } else {
                 //store accel data here
                 accelLoc02Buffer->push((float)self.motionManager.accelerometerData.acceleration.z);
                 float computedThresholdValue = 0;
                 if (accelLoc02Buffer->isEmpty()==false) {
//                     computedThresholdValue = accelLoc02Buffer->get(DATA_BUFF_STRUCT_SIZE/10)+1.035;
                     computedThresholdValue = accelLoc02Buffer->getMid()+1.035;
//                     computedThresholdValue = accelLoc02Buffer->get((accelLoc02Buffer->length())/10)+1.035;
                     computedThresholdValue = (computedThresholdValue<0 ? computedThresholdValue*-1:computedThresholdValue);
                 }

                 //if threshold value attained, then stop the audio session, stop accel, stop gyro
                 if (computedThresholdValue > ACCEL_THRESHHOLD) { //stop storing when peak detected
                     [self.motionManager stopAccelerometerUpdates];
                     XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
                     XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");

                     self.Location2StoreStatusLabel.text = @"Location 2 STORED";
                     self.StoreLoc01Button.enabled = YES;
                     self.StoreLoc01Button.alpha = 1.0;
                     calibratingLoc02=false;
                     NSLog(@"location 2 stored");
                }
             }
         }];
        
        //turn on operationqueue for gyro
/*        NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
        self.motionManager.gyroUpdateInterval = (double) 0.01001;
        [self.motionManager startGyroUpdatesToQueue:queue2 withHandler:
         ^(CMGyroData *gyroData, NSError *error) {
             if (error) {
                 [self.motionManager stopGyroUpdates];
             } else {
                 //store gyro data here
                 myDataQueuer.loc02GyrData->push((float)self.motionManager.gyroData.rotationRate.x);
                 //bill  myDataQueuer.enqueueLoc02GyrData((float)self.motionManager.gyroData.rotationRate.x);
             }
         }];
 */
    }
}

- (IBAction)StartDetectionButton:(id)sender {

    if (calibratingLoc01 == true || calibratingLoc02 == true) {
        self.DetectionStatusLabel.text = @"SOMETHING ELSE IS RUNNING";
    } else {
        XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        detectingInput = true;
        self.DetectionStatusLabel.text = @"STARTED";
        NSLog(@"KEVIN ONE");
        //start audio session
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.0;
        
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:
         ^(CMAccelerometerData *accelerometerData, NSError *error){
             if ([myLock tryLock]==true) {
             
                 if (error) {
                     detectingInput = false;
                     [self.motionManager stopAccelerometerUpdates];
                 } else {
                     //store accel data here
                     accelCaptureBuffer->push((float)self.motionManager.accelerometerData.acceleration.z);
                     
                     float computedThresholdValue = 0;
                     if (accelCaptureBuffer->isEmpty()==false) {
                         computedThresholdValue = accelCaptureBuffer->getMid()+1.035;
                         computedThresholdValue = (computedThresholdValue<0 ? computedThresholdValue*-1:computedThresholdValue);
                     }
//                     NSLog(@"computedThresholdvalue %f", computedThresholdValue);
                     
                     if (computedThresholdValue > ACCEL_THRESHHOLD) { //peak detected, do crosscorr
                         XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
                         XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
                         [self.motionManager stopAccelerometerUpdates];
                         detectingInput=false;
                         
//first method (too slow)                         [self micConvolutionMethod01];
                         [self micConvolutionMethod02];
                         

//                         assert(false);
                         detectingInput = false;
                     }
                     
                 }
                 [myLock unlock];
             }//end lock test
         }];

        /*disable gyro input stuff for now
        NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
        self.motionManager.gyroUpdateInterval = (double) 0.01001;
        [self.motionManager startGyroUpdatesToQueue:queue2 withHandler:
         ^(CMGyroData *gyroData, NSError *error) {
             if (error) {
                 [self.motionManager stopGyroUpdates];
             } else {
                 //store gyro data here
                 myDataQueuer.enqueueInputGyrData(self.motionManager.gyroData.rotationRate.x);
             }
         }];
         */
    }
}

-(void) micConvolutionMethod01 {
    float          *signal, *filter, *result;
    uint32_t        lenSignal, filterLength, resultLength;
    
    filterLength = MIC_DATA_BUFF_SIZE;
    resultLength = filterLength*2-1;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    //printf("\nConvolution(resultLength = %d,filterLength=%d,lenSignal=%d)\n\n", resultLength, filterLength, lenSignal);
    
    micLoc01 = micLoc01Buffer->getDataLinear(); //this is alloc mem, need to free later
    micInput = micCaptureBuffer->getDataLinear();//this is alloc mem, need to free later
    
    /* Allocate memory for the input operands and check its availability. */
    signal = (float *) malloc(lenSignal * sizeof(float));
    filter = (float *) malloc(filterLength * sizeof(float));
    result = (float *) malloc(resultLength * sizeof(float));
    memset(signal, 0, lenSignal*sizeof(float));
    memset(filter, 0, filterLength*sizeof(float));
    memset(result, 0, resultLength*sizeof(float));
    
    for (int i = 0; i < filterLength; i++)
        filter[i] = micInput[i];
    free(micInput);
    for (int i = 0; i < resultLength; i++)
        if (i >=resultLength-filterLength)
            signal[i] = micLoc01[i-filterLength+1];//filter[i - filterLength+1];
    free(micLoc01);
    
    //xcorr with micLoc01 and micInput
    self.DetectionStatusLabel.text = @"crossCorr01";
    NSLog(@"crossCor01 started");
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);
    float crossCorLoc01 = result[0];
    for (int i=0; i<resultLength; i++) {
        if (crossCorLoc01<result[i]) {
            crossCorLoc01=result[i];
        }
    }
    
    //crosscorr for micLoc02 and micInput
    micLoc02 = micLoc02Buffer->getDataLinear(); //this is alloc mem, need to free later
    memset(signal, 0, lenSignal*sizeof(float));
    memset(result, 0, resultLength*sizeof(float));
    for (int i = 0; i < resultLength; i++)
        if (i >=resultLength-filterLength)
            signal[i] = micLoc02[i-filterLength+1];//filter[i - filterLength+1];
    free(micLoc02);
    
    //xcorr with micLoc01 and micInput
    self.DetectionStatusLabel.text = @"crossCorr02";
    NSLog(@"crossCor02 started");
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);
    float crossCorLoc02 = result[0];
    for (int i=0; i<resultLength; i++) {
        if (crossCorLoc02<result[i]) {
            crossCorLoc02=result[i];
        }
    }
    
    free(signal);
    free(filter);
    free(result);
    
    if (crossCorLoc01 > crossCorLoc02) {
        self.LocationTappedStatusLabel.text = @"location 01 tapped";
    } else if (crossCorLoc01 < crossCorLoc02) {
        self.LocationTappedStatusLabel.text = @"location 02 tapped";
    } else {
        self.LocationTappedStatusLabel.text = @"location not found";
    }
    
    NSLog(@"crossCorLoc01 %f corsscorrloc02 %f",crossCorLoc01,crossCorLoc02);
    self.DetectionStatusLabel.text = @"STOPPED";
}

-(void) micConvolutionMethod02 {
    
    //get micInput buffer
    micInput = micCaptureBuffer->getDataLinear();//this is alloc mem, need to free later
    uint32_t micInputPOIStart=0;
    uint32_t micInputPOIEnd=0;
    int filterLength;
    //find start of POI
    for (int i=0; i<micCaptureBuffer->length(); i++) {
        if ((micInput[i]<0? -1*micInput[i]:micInput[i]) >= MIC_THRESHOLD) {
            micInputPOIStart = (uint32_t)i;
            break;
        }
    }
    //find end of POI
    for (int i=micCaptureBuffer->length()-1; i>=0; i--) {
        if ((micInput[i]<0? -1*micInput[i]:micInput[i]) >= MIC_THRESHOLD) {
            micInputPOIEnd = (uint32_t)i;
            break;
        }
    }
    //find length of POI (filterLength)
    filterLength=micInputPOIEnd-micInputPOIStart+1;
    NSLog(@"micInput[%d]=%f micInput[%d]=%f",micInputPOIStart,micInput[micInputPOIStart], micInputPOIEnd, micInput[micInputPOIEnd]);
    //create filter array that's filterLength long and copy POI into filter array
    float *filter = (float *)malloc(filterLength*sizeof(float));
    for (int i=0; i<filterLength; i++) {
        filter[i] = micInput[micInputPOIStart + i];
    }
    free(micInput); //this is necessary since getDataLinear() uses "new"
    //!now we have the filter array created!
    
    //computer resultLength now that we have filterLength
    uint32_t resultLength=filterLength*2-1;
    //create result array
    float *result = (float *) malloc(resultLength*sizeof(float));

    //get micLoc01 buffer
    micLoc01 = micLoc01Buffer->getDataLinear(); //this is alloc mem, need to free later
    uint32_t micLoc01POIStart=0;
    uint32_t micLoc01POIEnd=0;
    uint32_t signalLength=((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    uint32_t micLoc01POILength=0;
    //find start of POI for micLoc01
    for (int i=0; i<micLoc01Buffer->length(); i++) {
        if ((micLoc01[i]<0? -1*micLoc01[i]:micLoc01[i]) >= MIC_THRESHOLD) {
            micLoc01POIStart = (uint32_t)i;
            break;
        }
    }
    //find end of POI for micLoc01
    for (int i=micLoc01Buffer->length()-1; i>=0; i--) {
        if ((micLoc01[i]<0? -1*micLoc01[i]:micLoc01[i]) >= MIC_THRESHOLD) {
            micLoc01POIEnd = (uint32_t)i;
            break;
        }
    }
    micLoc01POILength = micLoc01POIEnd - micLoc01POIStart + 1;
    if (micLoc01POILength>signalLength) {
        signalLength=micLoc01POILength;
    }
    //create signal array that is signalLength long and copy POI into signal array
    float *signal = (float *)malloc(signalLength*sizeof(float));
    memset(signal, 0, signalLength*sizeof(float));
    for (int i=0; i<resultLength; i++) {
        if (i>=resultLength-filterLength) {
            signal[i] = micLoc01[(i-filterLength+1)+micLoc01POIStart];
        }
    }
    free(micLoc01);
    //!now we have the signal array created!//
    
    printf("\nConvolution(resultLength = %d,filterLength=%d,signalLength=%d)\n\n", resultLength, filterLength, signalLength);
    //xcorr with micLoc01 (signal) and micInput (filter) now that we have the necessary arrays
    self.DetectionStatusLabel.text = @"crossCorr01";
    NSLog(@"crossCor01 started");
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);

    float crossCorLoc01 = result[0];
    for (int i=0; i<resultLength; i++) {
        if (crossCorLoc01<result[i]) {
            crossCorLoc01=result[i];
        }
    }
    free(signal);
    
//    free(filter); //do not free this, still need it later
//    free(result); // no need to free, just reset it to 0s

    //reset result array to 0 since we're done with it
    memset(result, 0, resultLength*sizeof(float));
    //get micLoc02 buffer
    micLoc02 = micLoc02Buffer->getDataLinear(); //this is alloc mem, need to free later
    uint32_t micLoc02POIStart=0;
    uint32_t micLoc02POIEnd=0;
    signalLength=((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    uint32_t micLoc02POILength=0;
    //find start of POI for micLoc02
    for (int i=0; i<micLoc02Buffer->length(); i++) {
        if ((micLoc02[i]<0? -1*micLoc02[i]:micLoc02[i]) >= MIC_THRESHOLD) {
            micLoc02POIStart = (uint32_t)i;
            break;
        }
    }
    //find end of POI for micLoc02
    for (int i=micLoc02Buffer->length()-1; i>=0; i--) {
        if ((micLoc02[i]<0? -1*micLoc02[i]:micLoc02[i]) >= MIC_THRESHOLD) {
            micLoc02POIEnd = (uint32_t)i;
            break;
        }
    }
    micLoc02POILength = micLoc02POIEnd - micLoc02POIStart + 1;
    if (micLoc02POILength>signalLength) {
        signalLength=micLoc02POILength;
    }
    //create signal array that is signalLength long and copy POI into signal array
    signal = (float *)malloc(signalLength*sizeof(float));
    memset(signal, 0, signalLength*sizeof(float));
    for (int i=0; i<resultLength; i++) {
        if (i>=resultLength-filterLength) {
            signal[i] = micLoc02[(i-filterLength+1)+micLoc02POIStart];
        }
    }
    free(micLoc02);
            NSLog(@"crossCor01 finished");
    printf("\nConvolution(resultLength = %d,filterLength=%d,signalLength=%d)\n\n", resultLength, filterLength, signalLength);
    //xcorr with micLoc02 (signal) and micInput (filter) now that we have the necessary arrays
    self.DetectionStatusLabel.text = @"crossCorr02";
    NSLog(@"crossCor02 started");
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);
    float crossCorLoc02 = result[0];
    for (int i=0; i<resultLength; i++) {
        if (crossCorLoc02<result[i]) {
            crossCorLoc02=result[i];
        }
    }
            NSLog(@"crossCor02 finished");
    free(result);
    free(filter);
    free(signal);
    
    if (crossCorLoc01 > crossCorLoc02) {
        self.LocationTappedStatusLabel.text = @"location 01 tapped";
    } else if (crossCorLoc01 < crossCorLoc02) {
        self.LocationTappedStatusLabel.text = @"location 02 tapped";
    } else {
        self.LocationTappedStatusLabel.text = @"location not found";
    }
    
    NSLog(@"crossCorLoc01 %f corsscorrloc02 %f",crossCorLoc01,crossCorLoc02);
    self.DetectionStatusLabel.text = @"STOPPED";
}

- (IBAction)StopDetectionButton:(id)sender {
    self.DetectionStatusLabel.text = @"STOPPED";
    XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
    XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
//    [self.motionManager stopGyroUpdates];
    [self.motionManager stopAccelerometerUpdates];
    detectingInput=false;
}

-(BOOL)initializeAudioData
{
    // Override point for customization after application launch.
    inputProc.inputProc = PerformThru;
	inputProc.inputProcRefCon = (__bridge void*)self;
    
    try {
        // Initialize and configure the audio session
		XThrowIfError(AudioSessionInitialize(NULL, NULL, rioInterruptionListener, (__bridge void*)self), "couldn't initialize audio session");
        
		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
        
		Float32 preferredBufferSize = .005;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
		
		UInt32 size = sizeof(hwSampleRate);
		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
        
        //		XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        
		XThrowIfError(SetupRemoteIO(rioUnit, inputProc, thruFormat), "couldn't setup remote i/o unit");
		unitHasBeenCreated = true;
        
        drawFormat.SetAUCanonical(2, false);
        drawFormat.mSampleRate = 44100;
        
        XThrowIfError(AudioConverterNew(&thruFormat, &drawFormat, &audioConverter), "couldn't setup AudioConverter");
		
		dcFilter = new DCRejectionFilter[thruFormat.NumberChannels()];
        
		UInt32 maxFPS;
		size = sizeof(maxFPS);
		XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
        
        drawABL = (AudioBufferList*) malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
        drawABL->mNumberBuffers = 2;
        for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
        {
            drawABL->mBuffers[i].mData = (SInt32*) calloc(maxFPS, sizeof(SInt32));
            drawABL->mBuffers[i].mDataByteSize = maxFPS * sizeof(SInt32);
            drawABL->mBuffers[i].mNumberChannels = 1;
        }
        
        //		XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        
		size = sizeof(thruFormat);
		XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &thruFormat, &size), "couldn't get the remote I/O unit's output client format");
		
		unitIsRunning = 1;
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		unitIsRunning = 0;
		if (dcFilter) delete[] dcFilter;
        if (drawABL)
        {
            for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
                free(drawABL->mBuffers[i].mData);
            free(drawABL);
            drawABL = NULL;
        }
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
		unitIsRunning = 0;
		if (dcFilter) delete[] dcFilter;
        if (drawABL)
        {
            for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
                free(drawABL->mBuffers[i].mData);
            free(drawABL);
            drawABL = NULL;
        }
	}
    
    return YES;
}

#pragma mark -Audio Session Interruption Listener

void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
    try {
        printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
        
        YZZViewController *THIS = (__bridge YZZViewController*)inClientData;
        
        if (inInterruption == kAudioSessionEndInterruption) {
            // make sure we are again the active session
            XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active");
            XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
        }
        
        if (inInterruption == kAudioSessionBeginInterruption) {
            XThrowIfError(AudioOutputUnitStop(THIS->rioUnit), "couldn't stop unit");
        }
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
}

#pragma mark -RIO Render Callback

static OSStatus	PerformThru(
							void						*inRefCon,
							AudioUnitRenderActionFlags 	*ioActionFlags,
							const AudioTimeStamp 		*inTimeStamp,
							UInt32 						inBusNumber,
							UInt32 						inNumberFrames,
							AudioBufferList 			*ioData)
{
    /*    if (audioBufferHasNewData == 1 && global_readingSensors == 1)
     {
     NSLog(@"audiobufferhasnewdata %d  global_readingsensors %d",audioBufferHasNewData, global_readingSensors);
     assert(1==0);
     }*/
    
	YZZViewController *THIS = (__bridge YZZViewController *)inRefCon;
	OSStatus err = AudioUnitRender(THIS->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
	
	// Remove DC component
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
		THIS->dcFilter[i].InplaceFilter((Float32*)(ioData->mBuffers[i].mData), inNumberFrames);
	
    
    if ( drawBufferLen_alloced == 0)
    {
        drawBuffers[0] = (SInt8 *)realloc(NULL, kMinDrawSamples);
        clockTime = (UInt64 *)realloc(NULL, 1);
        bzero(clockTime, 1);
        bzero(drawBuffers[0], kMinDrawSamples);
        drawBufferLen_alloced++;
    }
    
    *clockTime = inTimeStamp->mHostTime;
    
    //Convert the floating point audio data to integer (Q7.24)
    err = AudioConverterConvertComplexBuffer(THIS->audioConverter, inNumberFrames, ioData, THIS->drawABL);
    if (err) { printf("AudioConverterConvertComplexBuffer: error %d\n", (int)err); return err; }
    
    SInt8 *data_ptr = (SInt8 *)(THIS->drawABL->mBuffers[0].mData);
    
    /*    int i;
     for (i=0; i<inNumberFrames; i++)
     {
     //     if ((i+drawBufferIdx) >= drawBufferLen)
     if ((i+drawBufferIdx) >= kMinDrawSamples)
     {
     drawBufferIdx = -i;
     }
     drawBuffers[0][i + drawBufferIdx] = data_ptr[2];
     data_ptr += 4;
     }*/

    if (calibratingLoc01==true && calibratingLoc02==false && detectingInput==false) {
        for (int i=0;i<inNumberFrames; i++) {
            micLoc01Buffer->push((float)data_ptr[2]);
            data_ptr += 4;
        }
//        NSLog(@"YEP");
    } else if (calibratingLoc01==false && calibratingLoc02==true && detectingInput==false) {
        for (int i=0; i<inNumberFrames; i++) {
            micLoc02Buffer->push((float)data_ptr[2]);
            data_ptr += 4;
        }
//        NSLog(@"YEPYEP");
    } else if (calibratingLoc01==false && calibratingLoc02==false && detectingInput==true) {
        for (int i=0; i<inNumberFrames; i++) {
            micCaptureBuffer->push((float)data_ptr[2]);
            data_ptr += 4;
        }
//        NSLog(@"YEPYEPYEP");
    }
    
	return err;
}

#pragma mark -
#pragma mark Compose Mail

-(void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
    picker.mailComposeDelegate = self;
    
    NSTimeInterval thisTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *fileName=[[NSString alloc]initWithFormat:@"MicCrossCorrVersion1"];
    NSString *subject = [[NSString alloc] initWithFormat:@"Mic Cross Corr %f %@",thisTimeInSeconds,fileName];
    [picker setSubject:subject];
    NSArray *toRecipients = [NSArray arrayWithObjects:@"kaizou898@gmail.com", @"maxzly@gmail.com", @"keiby.zhou@gmail.com", "liujidon@gmail.com", nil];
//    NSArray *toRecipients = [NSArray arrayWithObjects:@"keiby.zhou@gmail.com", nil];
    //    NSArray *toRecipients = [NSArray arrayWithObjects:@"kaizou898@gmail.com", nil];
    [picker setToRecipients:toRecipients];
    
    //attaching audio data text file
    NSData *myMicLoc01NSData = [NSData dataWithContentsOfFile:self.micLoc01FilePath];
    NSString *fileMicLoc01ToSend = [[NSString alloc]initWithFormat:@"%@_%f_micLoc01.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myMicLoc01NSData mimeType:@"text/plain" fileName:fileMicLoc01ToSend];
    
    NSData *myMicLoc02NSData = [NSData dataWithContentsOfFile:self.micLoc02FilePath];
    NSString *fileMicLoc02ToSend = [[NSString alloc]initWithFormat:@"%@_%f_micLoc02.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myMicLoc02NSData mimeType:@"text/plain" fileName:fileMicLoc02ToSend];
    
    NSData *myMicCaptureNSData = [NSData dataWithContentsOfFile:self.micCaptureFilePath];
    NSString *fileMicCaptureToSend = [[NSString alloc]initWithFormat:@"%@_%f_micCapture.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myMicCaptureNSData mimeType:@"text/plain" fileName:fileMicCaptureToSend];
    
    //attaching accelgyro data text file
    NSData *myAccelLoc01NSData = [NSData dataWithContentsOfFile:self.accelLoc01FilePath];
    NSString *fileAccelLoc01ToSend = [[NSString alloc]initWithFormat:@"%@_%f_accelLoc01.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myAccelLoc01NSData mimeType:@"text/plain" fileName:fileAccelLoc01ToSend];
    
    NSData *myAccelLoc02NSData = [NSData dataWithContentsOfFile:self.accelLoc02FilePath];
    NSString *fileAccelLoc02ToSend = [[NSString alloc]initWithFormat:@"%@_%f_accelLoc02.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myAccelLoc02NSData mimeType:@"text/plain" fileName:fileAccelLoc02ToSend];
    
    NSData *myAccelCaptureNSData = [NSData dataWithContentsOfFile:self.accelCaptureFilePath];
    NSString *fileAccelCaptureToSend = [[NSString alloc]initWithFormat:@"%@_%f_accelCapture.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myAccelCaptureNSData mimeType:@"text/plain" fileName:fileAccelCaptureToSend];
    
    NSString *emailBody = @"Data used for mic cross correlation";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
//    [self presentModalViewController:picker animated:YES];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			self.DetectionStatusLabel.text = @"email canceled";
			break;
		case MFMailComposeResultSaved:
			self.DetectionStatusLabel.text = @"email saved";
			break;
		case MFMailComposeResultSent:
			self.DetectionStatusLabel.text = @"email sent";
			break;
		case MFMailComposeResultFailed:
			self.DetectionStatusLabel.text = @"email failed";
			break;
		default:
			self.DetectionStatusLabel.text = @"email not sent";
			break;
	}
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
