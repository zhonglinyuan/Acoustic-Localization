//
//  YZZViewController.m
//  EngineTester
//
//  Created by Kai Zou on 2013-01-25.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZViewController.h"

#define TEMPLATE_CLIQUE_SIZE 3

@interface YZZViewController ()
@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;

@property (strong, nonatomic) NSFileManager *myFileManager;

@property (strong, nonatomic) YZZExtendedTouchEngine *engine;
@property (strong, nonatomic) YZZTapRecording *detect_tap;

@property (strong, nonatomic) NSMutableArray *savedTapRecordings;

@property (strong, nonatomic) NSMutableArray *colors;


@property (strong, nonatomic) NSMutableArray *musicNotes;
@property (strong, nonatomic) AVAudioPlayer *noteC;
@property (strong, nonatomic) AVAudioPlayer *noteD;
@property (strong, nonatomic) AVAudioPlayer *noteE;
@property (strong, nonatomic) AVAudioPlayer *noteF;
@property (strong, nonatomic) AVAudioPlayer *noteG;
@property (strong, nonatomic) AVAudioPlayer *noteA;
@property (strong, nonatomic) AVAudioPlayer *noteB;
@property (strong, nonatomic) AVAudioPlayer *noteH;

@end

@implementation YZZViewController {
    bool run_continuous_mode;
    YZZTapRecording *recordedTap;
    bool environment_setup;
    int numberOfLabels;
    
//    UInt32 *mNotes;
}

@synthesize engine = _engine;
@synthesize detect_tap = _detect_tap;
@synthesize savedTapRecordings = _savedTapRecordings;

@synthesize serverip = _serverip;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

@synthesize numOfLoc = _numOfLoc;
@synthesize numPerLoc = _numPerLoc;

@synthesize musicNotes = _musicNotes;
@synthesize noteC = _noteC;
@synthesize noteD = _noteD;
@synthesize noteE = _noteE;
@synthesize noteF = _noteF;
@synthesize noteG = _noteG;
@synthesize noteA = _noteA;
@synthesize noteB = _noteB;
@synthesize noteH = _noteH;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self->numberOfLabels = 0;
    
    self.myFileManager = [NSFileManager defaultManager];
    
    self.savedTapRecordings = [[NSMutableArray alloc] init];
    
    //boolean used for continuous detection mode
    self->run_continuous_mode = false;
    self->environment_setup = false;
    
//    int Start_stop = 0;
    int continuous = 1;
//    self.engine = [[YZZExtendedTouchEngine alloc] initWithSensorMode:Start_stop];
    self.engine = [[YZZExtendedTouchEngine alloc] initWithSensorMode:continuous];

    self.colors = [NSMutableArray array];
    float INCREMENT = 0.01;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:1.0];
        [self.colors addObject:color];
    }
    
    NSString *noteCPath = [[NSBundle mainBundle] pathForResource:@"PianoC" ofType:@"wav"];
    NSURL *noteCURL = [NSURL fileURLWithPath:noteCPath];
    NSString *noteDPath = [[NSBundle mainBundle] pathForResource:@"PianoD" ofType:@"wav"];
    NSURL *noteDURL = [NSURL fileURLWithPath:noteDPath];
    NSString *noteEPath = [[NSBundle mainBundle] pathForResource:@"PianoE" ofType:@"wav"];
    NSURL *noteEURL = [NSURL fileURLWithPath:noteEPath];
    NSString *noteFPath = [[NSBundle mainBundle] pathForResource:@"PianoF" ofType:@"wav"];
    NSURL *noteFURL = [NSURL fileURLWithPath:noteFPath];
    NSString *noteGPath = [[NSBundle mainBundle] pathForResource:@"PianoG" ofType:@"wav"];
    NSURL *noteGURL = [NSURL fileURLWithPath:noteGPath];
    NSString *noteAPath = [[NSBundle mainBundle] pathForResource:@"PianoA" ofType:@"wav"];
    NSURL *noteAURL = [NSURL fileURLWithPath:noteAPath];
    NSString *noteBPath = [[NSBundle mainBundle] pathForResource:@"PianoB" ofType:@"wav"];
    NSURL *noteBURL = [NSURL fileURLWithPath:noteBPath];
    NSString *noteHPath = [[NSBundle mainBundle] pathForResource:@"PianoH" ofType:@"wav"];
    NSURL *noteHURL = [NSURL fileURLWithPath:noteHPath];
    
    self.noteC = [[AVAudioPlayer alloc]initWithContentsOfURL:noteCURL error:nil];
    self.noteD = [[AVAudioPlayer alloc]initWithContentsOfURL:noteDURL error:nil];
    self.noteE = [[AVAudioPlayer alloc]initWithContentsOfURL:noteEURL error:nil];
    self.noteF = [[AVAudioPlayer alloc]initWithContentsOfURL:noteFURL error:nil];
    self.noteG = [[AVAudioPlayer alloc]initWithContentsOfURL:noteGURL error:nil];
    self.noteA = [[AVAudioPlayer alloc]initWithContentsOfURL:noteAURL error:nil];
    self.noteB = [[AVAudioPlayer alloc]initWithContentsOfURL:noteBURL error:nil];
    self.noteH = [[AVAudioPlayer alloc]initWithContentsOfURL:noteHURL error:nil];
    
    self.musicNotes = [[NSMutableArray alloc] initWithObjects:self.noteC, self.noteD, self.noteE, self.noteF, self.noteG, self.noteA, self.noteB, self.noteH, nil];
    
    [self.noteC prepareToPlay];
    [self.noteD prepareToPlay];
    [self.noteE prepareToPlay];
    [self.noteF prepareToPlay];
    [self.noteG prepareToPlay];
    [self.noteA prepareToPlay];
    [self.noteB prepareToPlay];
    [self.noteH prepareToPlay];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(micBufferFull) name:@"micBufferFull" object:nil];
}

- (void) micBufferFull {
    dispatch_async(dispatch_get_main_queue(),^{
        self.labelGuess.text = @"waiting for tap";
    });
}
- (IBAction)autoPressed:(UIButton *)sender {
    // if user clicked auto, we should:
    // 1. stop previous game
    // 2. unregister all locations
    // 3. calibrate environment
    // 4. register templates acoording to # of loc and # per loc
    // 5. enter guess mode
    
    // stop previous game
    [self stopGuessButtonPressed:nil];
    [NSThread sleepForTimeInterval:1];
    // unregister all locations
    [self unregAllButtonPressed:nil];
    // calibrate environment
    [self envSetupButton:nil];
    // register template
    int numberOfLocation = [self.numOfLoc.text intValue];
    int numberOfTemplatesPerLocation = [self.numPerLoc.text intValue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < numberOfLocation; i++) {
            [self registerLocationForTemplateNum:numberOfTemplatesPerLocation];
        }
        [self stopGuessButtonPressed:nil];
        [self guessButton:nil];
    });
    // enter guess mode
}

- (void)registerLocationForTemplateNum:(int) TemplatePerLoc
{
    if ([self.engine isRecordingNextTap]==true) { //already running tap detection, return
        NSLog(@"something's already running1");
        return;
    }
    if (self->environment_setup==false) {
        self.labelGuess.text = @"do env setup first";
        return;
    }
    
    //register a new label first
    __block int labelID = self->numberOfLabels;
    if ([self.engine registerLabel:labelID]) {
        NSLog(@"Label%d reg success", self->numberOfLabels);
    }
    __block int tapID = 0; //initialize tapID to zero
    
    self->run_continuous_mode = true;
        
        while (self->run_continuous_mode == true && tapID < TemplatePerLoc ) {
            
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //IMPORTANT: record sensor taprecording using sync thread
                
                bool tapEventDetected = false;
                self->recordedTap = [self.engine sync_startRecordNextTap:&tapEventDetected];
                
                //IMPORTANT: register the taprecording (this will be used as a template)
                //           remember you can only register a taprecording if a label is registered first!
                if (tapEventDetected==true && [self->recordedTap recordingIsGood]) {
                    [self->recordedTap preprocessData];
                    
                    bool regsuccess = [self.engine registerTap:self->recordedTap WithTap:tapID andLabel:labelID];
                    
                    if (regsuccess) {
                        NSLog(@"L%d reg success %d", labelID, tapID);
                        NSNumber *num = [[NSNumber alloc]initWithInt:labelID];
                        [self performSelectorInBackground:@selector(playSound:) withObject:num];
                    }
                    else NSLog(@"L%d reg failed, did you register the label number first?", labelID);
                    
                    dispatch_sync(dispatch_get_main_queue(),^{
                        self.labelGuess.text = [[NSString alloc]initWithFormat:@"L%d reg %d", labelID, tapID];
                        self.guessOutputLabel.text = [[NSString alloc]initWithFormat:@"%d", tapID];
                    });
                    tapID++; //increment for next tapID
                    [NSThread sleepForTimeInterval:0.3];
                }
            });
        } //end for
    self->numberOfLabels++; //increment for next label
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)confidenceIsChanged:(UISlider *)sender {
    self.engine.confidenceThreashold = sender.value;
    self.confidenceLabel.text = [NSString stringWithFormat:@"Confidence: %.2f",sender.value];
}

- (IBAction)recordTemplateButton:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self registerLocationForTemplateNum:5];
        [self stopGuessButtonPressed:nil];
    });
}

- (IBAction)stopGuessButtonPressed:(id)sender {
    NSLog(@"stop button pressed");
    if (self->run_continuous_mode==true) {
        NSLog(@"first stop");
        self->run_continuous_mode=false;
        [self.engine stopRecordingNextTap]; //IMPORTANT: have to tell the engine to stop!
//        self.labelGuess.backgroundColor = [UIColor whiteColor];
        self.labelGuess.text = [NSString stringWithFormat:@"stopped"];
    } else {
        self.labelGuess.text = [NSString stringWithFormat:@"already stopped"];
//        self.labelGuess.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)unregAllButtonPressed:(id)sender {
    for (int label_id=0; label_id<self->numberOfLabels; label_id++) {
        YZZLabel *label = [self.engine getLabelFromAllLabelsListWithID:label_id];
        for (int tap_id=0; tap_id<[label getNumberOfTapRecordings]; tap_id++) {
            [self.engine unregisterTapWithTapID:tap_id andLabel:label_id];
        }
        [self.engine unregisterLabel:label_id];
    }
    self->numberOfLabels = 0;
    self.labelGuess.text = [NSString stringWithFormat:@"unreged all"];
//    self.labelGuess.backgroundColor = [UIColor whiteColor];
}

- (IBAction)showLabelxcorrButtonPressed:(id)sender {
//    was going to use this function for debug...
}

- (IBAction)envSetupButton:(id)sender {
//    if (self->environment_setup==false) {
        self.labelGuess.backgroundColor = [UIColor yellowColor];
        self.labelGuess.text = @"env setup";
        [self.engine sync_performEnvironmentCalibration];
        self.labelGuess.backgroundColor = [UIColor greenColor];
        self.labelGuess.text = @"env setup done";
        self->environment_setup = true;
//    }
}


-(void) playSound:(NSNumber *)num {
        
    AVAudioPlayer *sound;
    int i = [num intValue];
    if (i >=0 && i <=7) {
        sound = [self.musicNotes objectAtIndex:i];
        [sound stop];
        [sound setCurrentTime:0];
        [sound play];
    }
}

- (IBAction)guessButton:(id)sender {
 
    
//    NSNumber
//    NSMutableArray *musicNotes = [[NSMutableArray alloc]initWithObjects:audioEffect1, audioEffect2, audioEffect3, audioEffect4, audioEffect5, audioEffect6, nil];
    
    NSLog(@"guessButton pressed");
    //IMPORTANT:safety check
    if ([self.engine isRecordingNextTap]==true) { //already running tap detection, return
        NSLog(@"something's already running3");
        return;
    }
    //implied else clause
    
    self->run_continuous_mode = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self->run_continuous_mode == true) {
            
            bool tapEventDetected = false;
            self.detect_tap = [self.engine sync_startRecordNextTap:&tapEventDetected];

            NSTimeInterval startTime1 = [[NSDate date] timeIntervalSince1970];
            
            float *myMicData = self.detect_tap->SensorFifo[0]->getDataLinear();
            int myMicDataLength = self.detect_tap->SensorFifo[0]->length();
            [self sendfloat:myMicData withlength:myMicDataLength];
            free(myMicData);

            dispatch_async(dispatch_get_main_queue(),^{
                if (self->run_continuous_mode==true) {
                    self.labelGuess.text = @"processing";
                }
            });
            
            int guessedlocation=-2;
            if (tapEventDetected==true &&[self.detect_tap recordingIsGood]) {
                [self.detect_tap preprocessData];
                guessedlocation = [self.engine returnFFTCrossCorrBestAverageMatchWithMultipleRecordings:self.detect_tap];
                                    
                    for (int i=0; i<self->numberOfLabels; i++) {
                        if (guessedlocation == i) {
                            dispatch_async(dispatch_get_main_queue(),^{
                            NSNumber *num = [[NSNumber alloc]initWithInt:i];
                            [self performSelectorInBackground:@selector(playSound:) withObject:num];
                            self.guessOutputLabel.text = [[NSString alloc] initWithFormat:@"L%d", guessedlocation];
                            self.labelGuess.text = [[NSString alloc] initWithFormat:@"L%d", guessedlocation];
                                
                            });
                        }
                    }
                    
                NSLog(@"guessed location=%d",guessedlocation);
            }
            NSTimeInterval timeAfterXcorr = [[NSDate date] timeIntervalSince1970];
            float timeDeltaTotal=timeAfterXcorr-startTime1;
            NSLog(@"timeDeltaTotal:%f", timeDeltaTotal);
           
            //IMPORTANT: this is only for writing the collected data to file
            if ([self.actualLocTextField.text length]!=0 && [self.setupTextField.text length]!=0 && guessedlocation!=-2) {
                int setupNumber = [self.setupTextField.text intValue];
                int actual_label = [self.actualLocTextField.text intValue];
                //IMPORTANT: infered location of -1 means this is a template file
                [self.detect_tap writeAllBuffersToFileForSetup:setupNumber UsingLabel:actual_label andInferredLocation:guessedlocation];
                NSLog(@"done writing to file");
            }
            
        }
    });
    


}

#pragma mark filehandling

- (IBAction)inputDoneEditing:(UITextField *)sender {
    [sender resignFirstResponder];
    
    if (sender.tag == -1) {
        if ([@"" isEqualToString:sender.text]) {
        }
        else {
                [self initNetworkCommunicationtoIP:self.serverip.text]; 
        }
    }
}

- (IBAction)setupNumberEntered:(id)sender {
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *mainDir= [[NSString alloc]initWithString:[myPathList objectAtIndex:0]];
    
    int setupNumber = [self.setupTextField.text intValue];
    NSString *setupDir = [[NSString alloc]initWithFormat:@"%@/setup%d", mainDir, setupNumber];
    
    //only create new dir if doesn't exist
    if ([self.myFileManager fileExistsAtPath:setupDir isDirectory:NULL]==false) {
        [self.myFileManager createDirectoryAtPath:setupDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

/*
- (IBAction)clearAllFilesButton:(id)sender {
    
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *mainDir= [[NSString alloc]initWithString:[myPathList objectAtIndex:0]];
    NSArray *directoryContents = [self.myFileManager contentsOfDirectoryAtPath:mainDir error:nil];
    
//    for (int i=0; i<[directoryContents count]; i++) {
//        NSLog(@"%@", [directoryContents objectAtIndex:i]);
//    }
    
    for (int i=0; i<[directoryContents count]; i++) {
        NSString *completePath = [[NSString alloc] initWithFormat:@"%@/%@", mainDir, [directoryContents objectAtIndex:i]];
        [self.myFileManager removeItemAtPath:completePath error:nil];
    }
}
*/

#pragma mark NETWORKING_FUNCTIONS

- (void)sendfloat:(float *)myMicData withlength:(int)myMicDataLength {
    
    if ([@"" isEqualToString:self.serverip.text]) {
        return;
    }
    
    NSString *response = @"START\n";
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:(uint8_t *)[data bytes] maxLength:[data length]];
    
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < myMicDataLength; i++) {
        NSNumber *number = [[NSNumber alloc] initWithInt:(int)myMicData[i]];
        [tmp addObject:number];
    }
    
    NSString *tempStr = [tmp componentsJoinedByString:@" "];
    
    response  = tempStr;
    data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:(uint8_t *)[data bytes] maxLength:[data length]];
    
    response = @"\nEND\n";
    data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:(uint8_t *)[data bytes] maxLength:[data length]];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"stream event %i", streamEvent);
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == self.inputStream) {
                uint8_t buffer[1024];
                int len;
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            //[self messageReceived:output];
                        }
                    }
                }
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
        default:
            NSLog(@"Unknown event");
    }
    
}

- (void)initNetworkCommunicationtoIP:(NSString *)ip {
    CFReadStreamRef readStream =NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, 9001, &readStream, &writeStream);
    
    if (writeStream == nil)
        NSLog(@"writestrem is nil");
    self.inputStream = objc_unretainedObject(readStream);
    self.outputStream = ( NSOutputStream*)CFBridgingRelease(writeStream);
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
}

@end
