//
//  LYZZViewController.m
//  TapLocalization
//
//  Created by Kai Zou on 2012-11-14.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "LYZZViewController.h"
#import "AudioUnit/AudioUnit.h"
#import "CAXException.h"
#include "CAHostTimeBase.h"
#define ACCEL_THRESHHOLD 0.03
#define MIC_THRESHOLD 20

@interface LYZZViewController ()
@end

@implementation LYZZViewController {
    
    
    float *micLoc01;
    float *micLoc02;
    float *micInput;
    NSLock *myLock;
    
    bool location1SetupComplete;
    bool location2SetupComplete;
    bool location1Detected;
    bool location2Detected;
}

@synthesize Location1Button;
@synthesize Location2Button;
@synthesize BeginTestButton;

@synthesize	rioUnit;
@synthesize unitHasBeenCreated;
@synthesize unitIsRunning;
@synthesize inputProc;
@synthesize dcFilter;
@synthesize motionManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
    myLock = [[NSLock alloc]init];
    self.motionManager = [[CMMotionManager alloc]init];
    
    //setup audio data hanlder
    BOOL initAudioDataSuccess = [self initializeAudioData];
    if (!initAudioDataSuccess) {
        NSLog(@"error during initializeAudioData");
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.Location1ButtonProperty = [UIButton buttonWithType:UIButtonTypeCustom];
    [self initFlags];
    [self initGUI];
}


-(void) initFlags {
    location1SetupComplete=false;
    location2SetupComplete=false;
    location1Detected=false;
    location2Detected=false;
}
//initialize GUI
-(void) initGUI {
    //draw button border    
    [[Location1Button layer] setCornerRadius:8.0f];
    [[Location1Button layer] setBorderWidth:1.0f];
    
    [[Location2Button layer] setCornerRadius:8.0f];
    [[Location2Button layer] setBorderWidth:1.0f];
    
    [[BeginTestButton layer] setCornerRadius:8.0f];
    [[BeginTestButton layer] setBorderWidth:1.0f];
    
    //grey the test button
    BeginTestButton.alpha=GREY_BUTTON;
    BeginTestButton.enabled=false;
}

//updates button GUI
-(void)updateGUI {
    if (location1SetupComplete) {
        [Location1Button setBackgroundColor:[UIColor greenColor]];
    }
    if (location2SetupComplete) {
        [Location2Button setBackgroundColor:[UIColor greenColor]];
    }
    if (location1Detected) {
        [[Location1Button layer] setCornerRadius:8.0f];
        [[Location1Button layer] setBorderWidth:10.0f];
        
        Location1Button.layer.borderColor = [UIColor colorWithWhite:0.6f alpha:0.2f].CGColor;
    }
    if (location2Detected) {
        //[Location2Button setBackgroundColor:[UIColor greenColor]];
    }
    if ([self setupComplete]) {
        BeginTestButton.alpha=SOLID_BUTTON;
        BeginTestButton.enabled=true;
    }
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
        
        LYZZViewController *THIS = (__bridge LYZZViewController*)inClientData;
        
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
    
	LYZZViewController *THIS = (__bridge LYZZViewController *)inRefCon;
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

//true when calibration is done
-(bool)setupComplete {
    return location1SetupComplete && location2SetupComplete;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Location1Button:(id)sender {
    //turn on audio sesson
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
    XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
    self.motionManager.accelerometerUpdateInterval = 0.0;

    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
        if (error) {
            calibratingLoc01=false;
            [self.motionManager stopAccelerometerUpdates];
        } else {
            //store accel data
            //                 myDataQueuer.loc01AccData->push((float)self.motionManager.accelerometerData.acceleration.z);
            accelLoc01Buffer->push((float)self.motionManager.accelerometerData.acceleration.z);
            float computedThresholdValue = 0;
            if (accelLoc01Buffer->isEmpty()==false)
            {
                computedThresholdValue = accelLoc01Buffer->getMid() + 1.035;
                computedThresholdValue = (computedThresholdValue<0 ? (computedThresholdValue*-1.0):computedThresholdValue);
            }
            //                 NSLog(@"computedThresholdValue = %f", computedThresholdValue);
            
            //if threshold value attained, then stop the audio session, stop accel, stop gyro
            if (computedThresholdValue > ACCEL_THRESHHOLD) {
                [self.motionManager stopAccelerometerUpdates];
                XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
                XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
                location1SetupComplete = true;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateGUI];});
            }
        }
    }];    
}

- (IBAction)Location2Button:(id)sender {
    //turn on audio sesson
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
    XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
    self.motionManager.accelerometerUpdateInterval = 0.0;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error){
         if (error) {
             calibratingLoc02=false;
             [self.motionManager stopAccelerometerUpdates];
         } else {
             //store accel data here
             accelLoc02Buffer->push((float)self.motionManager.accelerometerData.acceleration.z);
             float computedThresholdValue = 0;
             if (accelLoc02Buffer->isEmpty()==false) {
                 computedThresholdValue = accelLoc02Buffer->getMid()+1.035;
                 computedThresholdValue = (computedThresholdValue<0 ? computedThresholdValue*-1:computedThresholdValue);
             }
             
             //if threshold value attained, then stop the audio session, stop accel, stop gyro
             if (computedThresholdValue > ACCEL_THRESHHOLD) { //stop storing when peak detected
                 [self.motionManager stopAccelerometerUpdates];
                 XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
                 XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
                 location2SetupComplete = true;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self updateGUI];});
             }
         }
     }];
}

- (IBAction)BeginTestButton:(id)sender {
    
    if (![self setupComplete]) {
        return;
    }
    
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
    XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
    detectingInput = true;
    self.motionManager.accelerometerUpdateInterval = 0.0;

    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:
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
                     [self micConvolution];
                     [self updateGUI];
                     //                         assert(false);
                     detectingInput = false;
                 }
                 
             }
             [myLock unlock];
         }//end lock test
     }];

}

-(void) micConvolution {
    
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
    
    if (crossCorLoc01 >= crossCorLoc02) {
        location1Detected = true;
    } else if (crossCorLoc01 < crossCorLoc02) {
        location2Detected = true;
    } else {
        location1Detected = false;
        location2Detected = false;
    }
    
    NSLog(@"crossCorLoc01 %f corsscorrloc02 %f",crossCorLoc01,crossCorLoc02);
}



@end
