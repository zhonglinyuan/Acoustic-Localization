//
//  AudioData3ViewController.m
//  AudioData3
//
//  Created by ZhongLin Yuan on 2012-09-13.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import "AudioData3ViewController.h"
#import "AudioUnit/AudioUnit.h"
#import "CAXException.h"

@interface AudioData3ViewController ()
@property (strong, nonatomic) NSFileManager *myFM;
@property (strong, nonatomic) NSFileHandle *myFH;
@property (strong, nonatomic) NSString *myFilePath;
@property (nonatomic) BOOL timerStarted;
@end

@implementation AudioData3ViewController
@synthesize myFH = _myFH;
@synthesize myFM = _myFM;
@synthesize myFilePath = _myFilePath;
@synthesize myDisplay = _myDisplay;
@synthesize myAudioDataReadingTimer = _myAudioDataReadingTimer;
@synthesize	rioUnit;
@synthesize unitHasBeenCreated;
@synthesize unitIsRunning;
@synthesize timerStarted = _timerStarted;

@synthesize	inputProc;

@synthesize	dcFilter;

- (IBAction)dataReadingStarted:(id)sender {
    if (!self.timerStarted)
    {
        if ([self initializeAudioData])
        {
            self.myDisplay.text = @"Started";
            self.myAudioDataReadingTimer = [NSTimer scheduledTimerWithTimeInterval:1/1000 target:self selector:@selector(logToFile) userInfo:NULL repeats:YES];
        }
        self.timerStarted = YES;
    }
}

- (IBAction)dataReadingStopped:(id)sender {
    if (self.timerStarted)
    {
        self.myDisplay.text = @"Stopped";
        [self.myAudioDataReadingTimer invalidate];
        [self.myFH closeFile];
        self.timerStarted = NO;
    }
}

- (IBAction)emailMyFile:(id)sender {
    if (!self.timerStarted && [self.myFM fileExistsAtPath:self.myFilePath])
    {
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil) {
            [self displayComposerSheet];
        }
    }
}

-(void)displayComposerSheet
{    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
    picker.mailComposeDelegate = self;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *subject = [[NSString alloc] initWithFormat:@"AudioData collected %f", timeInSeconds];
    [picker setSubject:subject];
    NSArray *myArray = [NSArray arrayWithObjects:@"kaizou898@gmail.com", @"keiby.zhou@gmail.com", @"maxzly@gmail.com", nil];
    [picker setToRecipients:myArray];
    NSString *myData = [[NSString alloc] initWithFormat:@"audiodata_%f.txt", timeInSeconds];
    [picker addAttachmentData:[NSData dataWithContentsOfFile:self.myFilePath] mimeType:@"text/plain" fileName:myData];
    
    NSString *emailBody = @"initail Audio data";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)logToFile
{
      int i;
      int max = kMinDrawSamples;
      SInt8 tempValue;
    Float64 timeStamp = *deltaTime;
    UInt32 frames = *numberOfFrames;
    UInt64 clock = *clockTime;
        for (i = 0; i < max; i++) {
            tempValue  = drawBuffers[0][i];
//            NSLog(@"%d %f %ld %lld", tempValue, timeStamp, frames, clock);
            NSString *myString = [[NSString alloc] initWithFormat:@"%d %f %ld %lld \n", tempValue, timeStamp, frames, clock];
            [self.myFH writeData:[myString dataUsingEncoding:NSUTF8StringEncoding]];
//            [self.myFH closeFile];
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
		
		XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        
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
        
		XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        
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
        
        AudioData3ViewController *THIS = (__bridge AudioData3ViewController*)inClientData;
        
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
	AudioData3ViewController *THIS = (__bridge AudioData3ViewController *)inRefCon;
	OSStatus err = AudioUnitRender(THIS->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
	
	// Remove DC component
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
		THIS->dcFilter[i].InplaceFilter((Float32*)(ioData->mBuffers[i].mData), inNumberFrames);
	
    // The draw buffer is used to hold a copy of the most recent PCM data to be drawn on the oscilloscope
/*    if (drawBufferLen != drawBufferLen_alloced)
    {
        int drawBuffer_i;
        
        // Allocate our draw buffer if needed
        if (drawBufferLen_alloced == 0)
            for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
                drawBuffers[drawBuffer_i] = NULL;
        
        // Fill the first element in the draw buffer with PCM data
        for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
        {
            drawBuffers[drawBuffer_i] = (SInt8 *)realloc(drawBuffers[drawBuffer_i], drawBufferLen);
            bzero(drawBuffers[drawBuffer_i], drawBufferLen);
        }
        
        drawBufferLen_alloced = drawBufferLen;
    } */
    
   if ( drawBufferLen_alloced == 0)
    {
        drawBuffers[0] = (SInt8 *)realloc(NULL, kMinDrawSamples);
        clockTime = (UInt64 *)realloc(NULL, 1);
        numberOfFrames = (UInt32 *)realloc(NULL, 1);
        deltaTime = (Float64 *)realloc(NULL, 1);
        bzero(clockTime, 1);
        bzero(numberOfFrames, 1);
        bzero(deltaTime, 1);
        bzero(drawBuffers[0], kMinDrawSamples);
        drawBufferLen_alloced++;
    }
    
    *clockTime = inTimeStamp->mHostTime;
    *deltaTime = inTimeStamp->mSampleTime;
    *numberOfFrames = inNumberFrames;
    
/*    int i;
    Float32 *audioPtr = (Float32 *)(ioData->mBuffers[0].mData);
    for (i=0; i<inNumberFrames; i++)
    {
        if ((i+drawBufferIdx) >= kMinDrawSamples)
        {
            drawBufferIdx = -i;
        }
        audioBuffers[0][i + drawBufferIdx] = audioPtr[2];
        audioPtr += 4;
    }
    drawBufferIdx += inNumberFrames;
*/
    
    //Convert the floating point audio data to integer (Q7.24)
    err = AudioConverterConvertComplexBuffer(THIS->audioConverter, inNumberFrames, ioData, THIS->drawABL);
    if (err) { printf("AudioConverterConvertComplexBuffer: error %d\n", (int)err); return err; }
    
    
    
    SInt8 *data_ptr = (SInt8 *)(THIS->drawABL->mBuffers[0].mData);
  
    int i;

    
     for (i=0; i<inNumberFrames; i++)
     {
//     if ((i+drawBufferIdx) >= drawBufferLen)
         if ((i+drawBufferIdx) >= kMinDrawSamples)
         {
             drawBufferIdx = -i;
         }
         drawBuffers[0][i + drawBufferIdx] = data_ptr[2];
         data_ptr += 4;
      }
      drawBufferIdx += inNumberFrames;
 
	return err;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.timerStarted = NO;
    self.myFM = [NSFileManager defaultManager];
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.myFilePath = [myPathList objectAtIndex:0];
    self.myFilePath = [self.myFilePath stringByAppendingPathComponent:@"AudioInput.txt"];
    if (![self.myFM fileExistsAtPath:self.myFilePath])
    {
        [self.myFM createFileAtPath:self.myFilePath contents:nil attributes:nil];
    }
    self.myFH = [NSFileHandle fileHandleForUpdatingAtPath:self.myFilePath];
    
}

- (void)viewDidUnload
{
    [self setMyDisplay:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
