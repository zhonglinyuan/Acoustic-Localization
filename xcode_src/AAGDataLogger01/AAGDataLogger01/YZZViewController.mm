//
//  YZZViewController.m
//  AAGDataLogger01
//
//  Created by Kai Zou on 2012-09-17.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import "YZZViewController.h"
#import "AudioUnit/AudioUnit.h"
#import "CAXException.h"
#include "CAHostTimeBase.h"

//#import "CoreAudio/PublicUtility/CAHostTimeBase.h"
//#include ""

//#define ACCEL_UPDATE_PERIOD 1.0/500.0
//#define GYRO_UPDATE_PERIOD  1.0/500.0
//#define INTERRUPT_TIMER_TRIGGER_PERIOD 1.0/3000.0

@interface YZZViewController ()
@property (nonatomic) BOOL readingSensors;
@property (strong, nonatomic) NSFileManager *myFM;
@property (strong, nonatomic) NSFileHandle *myAudioFH;
@property (strong, nonatomic) NSFileHandle *myAccelFH;
@property (strong, nonatomic) NSFileHandle *myGyroFH;
@property (strong, nonatomic) NSString *myAudioFilePath;
@property (strong, nonatomic) NSString *myAccelFilePath;
@property (strong, nonatomic) NSString *myGyroFilePath;

//sensor handlers
@property (strong, nonatomic) CMMotionManager *motionManager;
//@property (weak, nonatomic) CMAccelerometerData *accelerometerData;
//@property (weak, nonatomic) CMGyroData *gyroData;

@end

@implementation YZZViewController {
    BOOL readingSensor;
    
    struct AccelDataStruct {
        double accelX, accelY, accelZ;
        double accelTime;
    };
    struct AccelDataStruct myAData[DATA_BUFF_STRUCT_SIZE];
    int accelArrayCounter;
    
    struct GyroDataStruct {
        double gyroX, gyroY, gyroZ;
        double gyroTime;
    };
    struct GyroDataStruct myGData[DATA_BUFF_STRUCT_SIZE];
    int gyroArrayCounter;
}

@synthesize readingSensors = _readingSensors;

@synthesize myAudioFH = _myAudioFH;
@synthesize myAccelFH = _myAccelFH;
@synthesize myGyroFH = _myGyroFH;
@synthesize myFM = _myFM;

@synthesize myAudioFilePath = _myAudioFilePath;
@synthesize myAccelFilePath = _myAccelFilePath;
@synthesize myGyroFilePath = _myGyroFilePath;

@synthesize myDisplay = _myDisplay;
//@synthesize triggerSensorReadTimer = _triggerSensorReadTimer;
@synthesize	rioUnit;
@synthesize unitHasBeenCreated;
@synthesize unitIsRunning;

@synthesize inputProc;
@synthesize dcFilter;

-(void) readSensors {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0;
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:
         ^(CMAccelerometerData *accelerometerData, NSError *error){
             if (error) {
                 [self.motionManager stopAccelerometerUpdates];
             } else {
                 myAData[accelArrayCounter].accelX = self.motionManager.accelerometerData.acceleration.x;
                 myAData[accelArrayCounter].accelY = self.motionManager.accelerometerData.acceleration.y;
                 myAData[accelArrayCounter].accelZ = self.motionManager.accelerometerData.acceleration.z;
                 myAData[accelArrayCounter].accelTime = self.motionManager.accelerometerData.timestamp;
                 accelArrayCounter++;
             }
         }];
    
        NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
        self.motionManager.gyroUpdateInterval = (double) 0.01001;
        [self.motionManager startGyroUpdatesToQueue:queue2 withHandler:
         ^(CMGyroData *gyroData, NSError *error) {
             if (error) {
                 [self.motionManager stopGyroUpdates];
             } else {
                 myGData[gyroArrayCounter].gyroX = gyroData.rotationRate.x;
                 myGData[gyroArrayCounter].gyroY = gyroData.rotationRate.y;
                 myGData[gyroArrayCounter].gyroZ = gyroData.rotationRate.z;
                 myGData[gyroArrayCounter].gyroTime = gyroData.timestamp;
                 gyroArrayCounter++;

             }
         }];
    
    
}


-(IBAction)buttonPressed:(UIButton *)sender {
    //global_readingSensors = 0;
    if (sender.tag==1) {
        if (!self.readingSensors) {
            accelArrayCounter=0;
            gyroArrayCounter=0;
            audioArrayCounter=0;
//            initialTimeInNanos = CAHostTimeBase::GetCurrentTimeInNanos();
            
            XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
            XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
            
            [self readSensors];
            
//            [self.triggerSensorReadTimer fire];
            self.readingSensors = YES;
            self.myDisplay.text = @"Start logging pressed";
            NSLog(@"Start AAG Logging");
        }
    } else if (sender.tag==2) {
        if (self.readingSensors) {
            XThrowIfError(AudioOutputUnitStop(rioUnit), "couldn't stop remote i/o unit");
            XThrowIfError(AudioSessionSetActive(false), "couldn't set audio session inactive\n");
            NSLog(@"audio unit stopped");
            [self.motionManager stopAccelerometerUpdates];
            [self.motionManager stopGyroUpdates];
            self.readingSensors = NO;

            self.myAudioFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myAudioFilePath];
            self.myAccelFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myAccelFilePath];
            self.myGyroFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myGyroFilePath];
            
            //create string with accel and gyro data and write it to file
            for (int i=0; i<accelArrayCounter; i++) {
                NSString *accelString = [[NSString alloc]initWithFormat:@"Ax:%f Ay:%f Az:%f accelClock:%f\n"
                                      , myAData[i].accelX
                                      , myAData[i].accelY
                                      , myAData[i].accelZ
                                      , myAData[i].accelTime];
                [self.myAccelFH writeData:[accelString dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            for (int i=0; i<gyroArrayCounter; i++) {
                NSString *gyroString = [[NSString alloc]initWithFormat:@"Gx:%f Gy:%f Gz:%f gyroClock:%f\n"
                                        , myGData[i].gyroX
                                        , myGData[i].gyroY
                                        , myGData[i].gyroZ
                                        , myGData[i].gyroTime];
//                if (myGData[i].gyroTime==0.0) {
//                    NSLog(@"asdf gyrodataTime:%f", myGData[i].gyroTime);
//                    assert(1==0);
//                }
                [self.myGyroFH writeData:[gyroString dataUsingEncoding:NSUTF8StringEncoding]];
            }

            //create string with audio data and write it to file
            for (int i=0; i<audioArrayCounter; i++) {
                for (int j=0; j<kMinDrawSamples; j++) {
//                    NSString *audioString = [[NSString alloc]initWithFormat:@"(Audio):%d (AudioDelta):%f (Mclock):%llu\n"
                    NSString *audioString = [[NSString alloc]initWithFormat:@"(Audio):%d (Mclock):%f\n"
                                         , myAudioData[i].audioValue[j]
//                                         , myAudioData[i].audioDeltaTime
                                         , myAudioData[i].audioTime];
                    [self.myAudioFH writeData:[audioString dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            
            [self.myAudioFH closeFile];
            [self.myAccelFH closeFile];
            [self.myGyroFH closeFile];

            self.myDisplay.text = @"Stop logging pressed";
            NSLog(@"Stop AAG Logging");
        }
    } else if (sender.tag==3) {
        if (!self.readingSensors) {
            [self.myAudioFH closeFile];
            [self.myAccelFH closeFile];
            [self.myGyroFH closeFile];
            
            [self.myFM removeItemAtPath:self.myAudioFilePath error:nil];
            [self.myFM removeItemAtPath:self.myAccelFilePath error:nil];
            [self.myFM removeItemAtPath:self.myGyroFilePath error:nil];
            
            [self.myFM createFileAtPath:self.myAudioFilePath contents:nil attributes:nil];
            [self.myFM createFileAtPath:self.myAccelFilePath contents:nil attributes:nil];
            [self.myFM createFileAtPath:self.myGyroFilePath contents:nil attributes:nil];
            
            self.myAudioFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myAudioFilePath];
            self.myAccelFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myAccelFilePath];
            self.myGyroFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myGyroFilePath];
            self.myDisplay.text = @"Log Cleared";
            NSLog(@"Clear Log File pressed");
        }
    } else if (sender.tag==4) {
        BOOL txtFieldsFilled=NO;
        if ([self.xCoorTxtField.text length]>0 && [self.yCoorTxtField.text length]>0 && [self.surfaceTypeTxtField.text length]>0 && [self.numTapsTxtField.text length]>0) {
            txtFieldsFilled = YES;
        }
        
        if (!self.readingSensors && [self.myFM fileExistsAtPath:self.myAudioFilePath] && [self.myFM fileExistsAtPath:self.myAccelFilePath] && [self.myFM fileExistsAtPath:self.myGyroFilePath] && txtFieldsFilled)
        {
            //NSRegularExpression *regexTableTags = [NSRegularExpression regularExpressionWithPattern:@"^[pn]\\d+$" options:NSRegularExpressionCaseInsensitive error:nil];
            //if (regexTableTags == nil) {
            //    NSLog(@"error when creating regex");
            //}
            
            UIAlertView *alert;
            
            NSString *searchString = self.xCoorTxtField.text;
            NSString *regexString = @"^[pn]\\d+$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self matches %@", regexString];
            BOOL xfield_isStringValid = [predicate evaluateWithObject:searchString];
            if (xfield_isStringValid==NO ) {
                alert = [[UIAlertView alloc] initWithTitle:@"x corr error" message:@"x corr format error" delegate:self cancelButtonTitle:@"okay" otherButtonTitles:nil];
                [alert show];
            }
            
            searchString = self.yCoorTxtField.text;
            BOOL yfield_isStringValid = [predicate evaluateWithObject:searchString];
            if (yfield_isStringValid==NO ) {
                alert = [[UIAlertView alloc] initWithTitle:@"y corr error" message:@"y corr format error" delegate:self cancelButtonTitle:@"okay" otherButtonTitles:nil];
                [alert show];
            }
            
            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
            if (mailClass != nil && xfield_isStringValid==YES && yfield_isStringValid==YES) {
                NSLog(@"testadf");
                [self displayComposerSheet];
            }
            NSLog(@"Email log pressed");
        } else if (txtFieldsFilled==NO) {
            self.myDisplay.text = @"please complete the tag fields";
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //set initial values
    self.readingSensors = NO;
    initialTimeInNanos = CAHostTimeBase::GetCurrentTime();
    
    //setup motionManager and enable accel and gyro
    self.motionManager = [[CMMotionManager alloc]init];
//    if (self.motionManager.accelerometerAvailable && self.motionManager.gyroAvailable) {
//        self.motionManager.accelerometerUpdateInterval=ACCEL_UPDATE_PERIOD;
//        self.motionManager.gyroUpdateInterval=GYRO_UPDATE_PERIOD;
//        [self.motionManager startAccelerometerUpdates];
//        [self.motionManager startGyroUpdates];
//    } else {
//        NSLog(@"issue: accel and gyro not found");
//    }

    //setup log file
    self.myFM = [NSFileManager defaultManager];
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.myAudioFilePath = [myPathList objectAtIndex:0];
    self.myAccelFilePath = [myPathList objectAtIndex:0];
    self.myGyroFilePath = [myPathList objectAtIndex:0];
    
    self.myAudioFilePath = [self.myAudioFilePath stringByAppendingPathComponent:@"AudioDataLogger01.txt"];
    self.myAccelFilePath = [self.myAccelFilePath stringByAppendingPathComponent:@"AccelDataLogger01.txt"];
    self.myGyroFilePath = [self.myGyroFilePath stringByAppendingPathComponent:@"GyroDataLogger01.txt"];
    
    if (![self.myFM fileExistsAtPath:self.myAudioFilePath]) {
        [self.myFM createFileAtPath:self.myAudioFilePath contents:nil attributes:nil];
        NSLog(@"create success:%@",self.myAudioFilePath);
    }
    self.myAudioFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myAudioFilePath];
    
    if (![self.myFM fileExistsAtPath:self.myAccelFilePath]) {
        [self.myFM createFileAtPath:self.myAccelFilePath contents:nil attributes:nil];
        NSLog(@"create success:%@",self.myAccelFilePath);
    }
    self.myAccelFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myAccelFilePath];
    
    if (![self.myFM fileExistsAtPath:self.myGyroFilePath]) {
        [self.myFM createFileAtPath:self.myGyroFilePath contents:nil attributes:nil];
        NSLog(@"create success:%@",self.myGyroFilePath);
    }
    self.myGyroFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myGyroFilePath];
    
    //setup audio data
    BOOL initAudioDataSuccess = [self initializeAudioData];
    if (!initAudioDataSuccess) {
        NSLog(@"error during initializeAudioData");
    }
    NSLog(@"view loaded");
}

- (void)viewDidUnload
{
    [self setXCoorTxtField:nil];
    [self setYCoorTxtField:nil];
    [self setSurfaceTypeTxtField:nil];
    [self setNumTapsTxtField:nil];
    [self setXCoorTxtField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setMyDisplay:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    if (audioArrayCounter < DATA_BUFF_STRUCT_SIZE) {
//        for (int i=0;i<kMinDrawSamples;i++) {
        for (int i=0;i<inNumberFrames; i++) {
            myAudioData[audioArrayCounter].audioValue[i] = data_ptr[2];
//            NSLog(@"%d %llu", myAudioData[audioArrayCounter].audioValue[i], CAHostTimeBase::ConvertToNanos(*clockTime)-initialTimeInNanos);
            data_ptr += 4;
        }
//        myAudioData[audioArrayCounter].audioTime = CAHostTimeBase::ConvertToNanos(*clockTime) - initialTimeInNanos;
        myAudioData[audioArrayCounter].audioTime = (CAHostTimeBase::ConvertToNanos(*clockTime))/pow(10, 9);
        audioArrayCounter++;
    } else {
        NSLog(@"audioArrayCounter FULL");
        assert(1==0);
    }

//    drawBufferIdx += inNumberFrames;
    
	return err;
}

#pragma mark -
#pragma mark Compose Mail

-(void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
    picker.mailComposeDelegate = self;
    
    NSTimeInterval thisTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *fileName=[[NSString alloc]initWithFormat:@"x%@_y%@_%@_%@_%@"
                        , self.xCoorTxtField.text
                        , self.yCoorTxtField.text
                        , self.surfaceTypeTxtField.text
                        , self.numTapsTxtField.text
                        , self.tapTypeTxtField.text];
    NSString *subject = [[NSString alloc] initWithFormat:@"sensor data collected %f %@",thisTimeInSeconds,fileName];
    [picker setSubject:subject];
//    NSArray *toRecipients = [NSArray arrayWithObjects:@"kaizou898@gmail.com", @"maxzly@gmail.com", @"keiby.zhou@gmail.com", nil];
        NSArray *toRecipients = [NSArray arrayWithObjects:@"keiby.zhou@gmail.com", nil];
//    NSArray *toRecipients = [NSArray arrayWithObjects:@"kaizou898@gmail.com", nil];
    [picker setToRecipients:toRecipients];

    //attaching audio data text file
    NSData *myAudioNSData = [NSData dataWithContentsOfFile:self.myAudioFilePath];
    
    
    NSString *fileAudioToSend = [[NSString alloc]initWithFormat:@"%@_%f_AUDIO.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myAudioNSData mimeType:@"text/plain" fileName:fileAudioToSend];

    //attaching accelgyro data text file
    NSData *myAccelNSData = [NSData dataWithContentsOfFile:self.myAccelFilePath];
    NSString *fileAccelToSend = [[NSString alloc]initWithFormat:@"%@_%f_ACCEL.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myAccelNSData mimeType:@"text/plain" fileName:fileAccelToSend];

    NSData *myGyroNSData = [NSData dataWithContentsOfFile:self.myGyroFilePath];
    NSString *fileGyroToSend = [[NSString alloc]initWithFormat:@"%@_%f_GYRO.txt", fileName, thisTimeInSeconds];
    [picker addAttachmentData:myGyroNSData mimeType:@"text/plain" fileName:fileGyroToSend];
    
    
    NSString *emailBody = @"sensor data attached. time is in seconds";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
}

- (IBAction)inputDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backGroundTapped:(id)sender {
    [self.xCoorTxtField resignFirstResponder];
    [self.yCoorTxtField resignFirstResponder];
    [self.surfaceTypeTxtField resignFirstResponder];
    [self.numTapsTxtField resignFirstResponder];
    [self.tapTypeTxtField resignFirstResponder];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	//self.messageLabel.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			self.myDisplay.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			self.myDisplay.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			self.myDisplay.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			self.myDisplay.text = @"Result: failed";
			break;
		default:
			self.myDisplay.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


@end
