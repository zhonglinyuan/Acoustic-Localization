//
//  YZZSensorController.m
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZSensorController.h"

#define DEFAULT_ACCEL_THRESHHOLD 0.05
#define THRESHOLD_FACTOR 3
#define ACCEL_GYRO_READ_INTERVAL 0.009
#define ACCEL_UPDATE_INTERVAL 0.0 //0.0 will default to 0.01
#define GYRO_UPDATE_INTERVAL 0.0 //0.0 will default to 0.01
#define ACCEL_Z_QUIET_STD 0.003

@interface YZZSensorController()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, assign) AURenderCallbackStruct inputProc;
@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) DCRejectionFilter *dcFilter;

@end

static bool audio_already_initilized = false;

@implementation YZZSensorController {
    Float64 hwSampleRate;
    AudioConverterRef audioConverter;
    AudioBufferList *drawABL;
    CAStreamBasicDescription thruFormat;
    CAStreamBasicDescription drawFormat;
    BOOL unitIsRunning;
    BOOL unitHasBeenCreated;
    BOOL thresholdDetected;
    FixedFifo *micCaptureBuffer;
    BOOL micCaptureBufferIsFull;
    int current_sensor_run_mode;//SensorMode current_sensor_run_mode;
}

@synthesize motionManager = _motionManager;
@synthesize inputProc = _inputProc;
@synthesize rioUnit = _rioUnit;
@synthesize dcFilter = _dcFilter;

+(bool)audioUnitStatus {
    return audio_already_initilized;
}

-(void)setCapture_Data_Active:(bool)_capture_data_active {
    self->capture_data_active = _capture_data_active;
}
-(bool)getCapture_Data_Active {
    return self->capture_data_active;
}

-(bool) getMicCaptureBufferIsFull {
    return self->micCaptureBufferIsFull;
}

-(id) initWithMode:(int)mode_flag {//(SensorMode)mode_flag {
    self = [super init];
    
    capture_data_active = false;
    all_sensors_startedup = false;
    
    hwSampleRate = 44100;
    self->unitIsRunning = FALSE;
    self->unitHasBeenCreated = FALSE;
    self->AccZ_average = -1;
    self->AccZ_deviation = 0;
    self->accel_threshold_setup_complete = false;
    self->thresholdDetected = false;
    self->micCaptureBufferIsFull = false;
    
//    self->micCaptureBuffer = new FixedFifo(MIC_DATA_BUFF_SIZE, MIC_DATA_BUFF_SIZE_TRIGGER);
    
    if (audio_already_initilized == false) {
        audio_already_initilized = true;
        NSLog(@"initializing audiodata");
        BOOL initAudioDataSuccess = [self initializeAudioData];
        if (!initAudioDataSuccess) {
            NSLog(@"error during initializeAudioData");
        }
    }
    
    self.motionManager = [[CMMotionManager alloc]init];
    
    if (mode_flag == 1){//Continuous) {
        //current_sensor_run_mode = Continuous;
        current_sensor_run_mode = 1;
        [self startupAllSensors];
    } else if (mode_flag == 0){//Start_stop) {
        current_sensor_run_mode =0;// Start_stop;
    }
    
    NSLog(@"sensor_run_mode=%d",current_sensor_run_mode);
    
    return self;
}

-(void)startupAllSensors {
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
    XThrowIfError(AudioOutputUnitStart(self.rioUnit), "couldn't start remote i/o unit");
    [self.motionManager setAccelerometerUpdateInterval:ACCEL_UPDATE_INTERVAL]; //0.0 should default to maximum (100Hz)
    [self.motionManager setGyroUpdateInterval:GYRO_UPDATE_INTERVAL]; //0.0 should default to maximum
    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startGyroUpdates];
    NSLog(@"all sensors startup");
//    NSLog(@"accel update interval %f",[self.motionManager accelerometerUpdateInterval]);
//    NSLog(@"gyro update interval %f" ,[self.motionManager gyroUpdateInterval]);
    all_sensors_startedup = true;
}

-(void)shutdownAllSensors {
    if (current_sensor_run_mode == 0){//Start_stop) {
        [self.motionManager stopDeviceMotionUpdates];
        XThrowIfError(AudioOutputUnitStop(self.rioUnit), "couldn't stop remote i/o unit");
        XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
        all_sensors_startedup = false;
        NSLog(@"all sensors shutdowned");
    }
}

-(void)determineAccelThreshold {
    if (accel_threshold_setup_complete == true) {
        return;
    }
    
    [self.motionManager setAccelerometerUpdateInterval:ACCEL_UPDATE_INTERVAL]; //0.0 should default to maximum (100Hz)
    [self.motionManager startAccelerometerUpdates];

    while (self.motionManager.accelerometerActive==false) {
        NSLog(@"waiting for device motion active");
        [NSThread sleepForTimeInterval:0.01];
    }
    
    [NSThread sleepForTimeInterval:0.1];
    
    float calibrationX[100];
    float calibrationY[100];
    float calibrationZ[100];
    
    bool flag_done = false;
    while(!flag_done) {
        float sum_AccZ = 0;
        float max_AccZ = -100;
        float min_AccZ = 100;
        float AccZ = 0;
        float AccX = 0;
        float AccY = 0;
        int total_run=100;

        for (int i=0; i<total_run; i++) {
            [NSThread sleepForTimeInterval:ACCEL_GYRO_READ_INTERVAL];
            AccZ = self.motionManager.accelerometerData.acceleration.z;
            AccX = self.motionManager.accelerometerData.acceleration.x;
            AccY = self.motionManager.accelerometerData.acceleration.y;
            if (AccZ > max_AccZ) {
                max_AccZ = AccZ;
            }
            if (AccZ < min_AccZ) {
                min_AccZ = AccZ;
            }
            sum_AccZ = sum_AccZ + AccZ;
            calibrationX[i] = AccX;
            calibrationY[i] = AccY;
            calibrationZ[i] = AccZ;
        }
        
        AccZ_average = sum_AccZ/total_run;
        if (max_AccZ - AccZ_average > AccZ_average - min_AccZ) {
            AccZ_deviation = max_AccZ - AccZ_average;
        } else {
            AccZ_deviation = AccZ_average - min_AccZ;
        }
        
        float std = 0;
        for (int i = 0; i < total_run; i ++) {
            //printf("%f,%f,%f\n",calibrationY[i],calibrationY[i],calibrationZ[i]);
            std += pow(calibrationZ[i] - AccZ_average,2);
        }
        
        std = pow(std/total_run,0.5);
        if (std < ACCEL_Z_QUIET_STD) {
            flag_done = true;
        }

        NSLog(@"accel_average = %f, accel_az_std = %f", AccZ_average, std);
        NSLog(@"max AZ %f", max_AccZ);
        NSLog(@"min AZ %f", min_AccZ);
        NSLog(@"AccZ_deviation %f", AccZ_deviation);
    }
    accel_threshold_setup_complete = true;

}

-(bool)captureDataAtLocation:(YZZTapRecording *)myTapRecording
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [myTapRecording clearAllBuffers];
        //self->micCaptureBuffer = myTapRecording->SensorFifo[0];
        self->micCaptureBuffer = new FixedFifo(MIC_DATA_BUFF_SIZE, MIC_DATA_BUFF_SIZE_TRIGGER);
        
        if (current_sensor_run_mode == 0){//Start_stop) {
            [self startupAllSensors]; //important, start up sensors
        }
        
        while (self.motionManager.accelerometerActive==false || self.motionManager.gyroActive==false) {
            NSLog(@"waiting for device motion active");
            [NSThread sleepForTimeInterval:0.01];
        }
        //[NSThread sleepForTimeInterval:0.01];//wait for accel and gyro value to stablize after activating
        
        self->thresholdDetected = false;
        NSLog(self->capture_data_active ? @"capture=true":@"capture=false");
        while (self->thresholdDetected==false&&self->capture_data_active==true) {
            [NSThread sleepForTimeInterval:ACCEL_GYRO_READ_INTERVAL]; //simulate the read interval of 100Hz as we had before using block queue interrupt method
            // Add accel and gyro data to the queue.
            myTapRecording->SensorFifo[1]->push((float)(self.motionManager.accelerometerData.acceleration.x));
            myTapRecording->SensorFifo[2]->push((float)(self.motionManager.accelerometerData.acceleration.y));
            myTapRecording->SensorFifo[3]->push((float)(self.motionManager.accelerometerData.acceleration.z));
            myTapRecording->SensorFifo[4]->push((float)(self.motionManager.gyroData.rotationRate.x));
            myTapRecording->SensorFifo[5]->push((float)(self.motionManager.gyroData.rotationRate.y));
            myTapRecording->SensorFifo[6]->push((float)(self.motionManager.gyroData.rotationRate.z));
            float computedDeviation = 0;
            if (myTapRecording->SensorFifo[3]->isFull())
            {
                self->micCaptureBufferIsFull = true;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"micBufferFull" object:nil];
                computedDeviation = myTapRecording->SensorFifo[3]->getMid() - AccZ_average;
                computedDeviation = (computedDeviation<0 ? (computedDeviation*-1.0):computedDeviation);
            }
            
            //if threshold value attained, then stop the audio session, stop accel, stop gyro
            if (computedDeviation > AccZ_deviation*THRESHOLD_FACTOR) {
                if (current_sensor_run_mode == 0){//Start_stop) {
                    [self shutdownAllSensors]; //very important, shutdown sensors
                }
                self->thresholdDetected=true;
                
                //if (myTapRecording->tapID!=0) { //if we only collection template buffers, then set this to false after tap event capture
                    self->capture_data_active = false;
                //}
                
                [self PushMicBuffToMyRecordingMicFifo:myTapRecording];
                self->micCaptureBufferIsFull = true;
                delete(self->micCaptureBuffer);
            }
        }//end while
        if (all_sensors_startedup==true) { //very important, make sure that sensors are shut down properly before exiting
            if (current_sensor_run_mode == 0){//Start_stop) {
                [self shutdownAllSensors];
            }
        }
    });
    
    return self->thresholdDetected;
}

- (void) PushMicBuffToMyRecordingMicFifo:(YZZTapRecording *)myTapRecording {
    float * micLinear = self->micCaptureBuffer->getDataLinear();
    for (int i=0; i<MIC_DATA_BUFF_SIZE; i++) {
        myTapRecording->SensorFifo[0]->push(micLinear[i]);
    }
    delete(micLinear);
}

-(BOOL)initializeAudioData
{
    // Override point for customization after application launch.
    self->_inputProc.inputProc = PerformThru;
	self->_inputProc.inputProcRefCon = (__bridge void*)self;
    
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
        
		XThrowIfError(SetupRemoteIO(self->_rioUnit, _inputProc, thruFormat), "couldn't setup remote i/o unit");
		unitHasBeenCreated = true;
        
        drawFormat.SetAUCanonical(2, false);
        drawFormat.mSampleRate = 44100;
        
        XThrowIfError(AudioConverterNew(&thruFormat, &drawFormat, &audioConverter), "couldn't setup AudioConverter");
		
		self->_dcFilter = new DCRejectionFilter[thruFormat.NumberChannels()];
        
		UInt32 maxFPS;
		size = sizeof(maxFPS);
		XThrowIfError(AudioUnitGetProperty(self->_rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
        
        drawABL = (AudioBufferList*) malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
        drawABL->mNumberBuffers = 2;
        for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
        {
            drawABL->mBuffers[i].mData = (SInt32*) calloc(maxFPS, sizeof(SInt32));
            drawABL->mBuffers[i].mDataByteSize = maxFPS * sizeof(SInt32);
            drawABL->mBuffers[i].mNumberChannels = 1;
        }
        
		size = sizeof(thruFormat);
		XThrowIfError(AudioUnitGetProperty(self->_rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &thruFormat, &size), "couldn't get the remote I/O unit's output client format");
		
		unitIsRunning = 1;
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		unitIsRunning = 0;
		if (self->_dcFilter) delete[] self->_dcFilter;
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
		if (self->_dcFilter) delete[] self->_dcFilter;
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
        
        YZZSensorController *THIS = (__bridge YZZSensorController*)inClientData;
        
        if (inInterruption == kAudioSessionEndInterruption) {
            // make sure we are again the active session
            XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active");
            XThrowIfError(AudioOutputUnitStart(THIS->_rioUnit), "couldn't start unit");
        }
        
        if (inInterruption == kAudioSessionBeginInterruption) {
            XThrowIfError(AudioOutputUnitStop(THIS->_rioUnit), "couldn't stop unit");
        }
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
}

#pragma mark -RIO Render Callback
static OSStatus	PerformThru(void						*inRefCon,
							AudioUnitRenderActionFlags 	*ioActionFlags,
							const AudioTimeStamp 		*inTimeStamp,
							UInt32 						inBusNumber,
							UInt32 						inNumberFrames,
							AudioBufferList 			*ioData)
{
    
	YZZSensorController *THIS = (__bridge YZZSensorController *)inRefCon;
	OSStatus err = AudioUnitRender(THIS->_rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
	
	// Remove DC component
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
		THIS->_dcFilter[i].InplaceFilter((Float32*)(ioData->mBuffers[i].mData), inNumberFrames);
	
    
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
    
    
    if (THIS->capture_data_active!=false && THIS->micCaptureBuffer!=nil) {
        for (int i=0; i<inNumberFrames; i++) {
            if (THIS->thresholdDetected==false) {
                THIS->micCaptureBuffer->push((float)data_ptr[2]);
                data_ptr += 4;
            }
        }
    }
    
    SilenceData(ioData);
    
	return err;
}

@end
