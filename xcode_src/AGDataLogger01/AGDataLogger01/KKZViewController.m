//
//  KKZViewController.m
//  AGDataLogger01
//
//  Created by Kai Zou on 2012-09-16.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import "KKZViewController.h"
#define ACCEL_UPDATE_PERIOD 1.0/1000.0
#define GYRO_UPDATE_PERIOD  1.0/1000.0
#define INTERRUPT_TIMER_TRIGGER_PERIOD 1.0/2000.0

@interface KKZViewController ()
//interrupt timer trigger
@property (retain) NSTimer *sensorRefreshTimer;
//sensor handlers
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) CMAccelerometerData *accelerometerData;
@property (weak, nonatomic) CMGyroData *gyroData;
//file handlers
@property (strong, nonatomic) NSFileManager *fileMgr;
@property (strong, nonatomic) NSFileHandle *fileHandler;
@property (strong, nonatomic) NSString *filePath;
@end

@implementation KKZViewController {
    BOOL readingSensor;
    NSTimeInterval initialTimeInSeconds, currentTimeInSeconds, timeInSeconds, prevTimeInSeconds, deltaTimeInterval;
    NSMutableString *sensorValues;
    int interruptTimerCounter;
}
@synthesize messageLabel=_messageLabel;
@synthesize fileMgr = _fileMgr;
@synthesize fileHandler = _fileHandler;

- (void)viewDidLoad
{
    [super viewDidLoad];
	//set initial values
    readingSensor = NO;
    initialTimeInSeconds = [[NSDate date]timeIntervalSince1970];
    currentTimeInSeconds = initialTimeInSeconds;
    timeInSeconds = currentTimeInSeconds-initialTimeInSeconds;
    prevTimeInSeconds = timeInSeconds;
    sensorValues = [[NSMutableString alloc]init];
    interruptTimerCounter=0;
    //setup motionManager and enable accel and gyro
    self.motionManager = [[CMMotionManager alloc]init];
    if (self.motionManager.accelerometerAvailable && self.motionManager.gyroAvailable) {
        self.motionManager.accelerometerUpdateInterval=ACCEL_UPDATE_PERIOD;
        self.motionManager.gyroUpdateInterval=GYRO_UPDATE_PERIOD;
        [self.motionManager startAccelerometerUpdates];
        [self.motionManager startGyroUpdates];
    }
    //check if log file exists, create if necessary
    [self setFileMgr:[NSFileManager defaultManager]];
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.filePath = [myPathList objectAtIndex:0];
    self.filePath = [self.filePath stringByAppendingPathComponent:@"sensorLog.txt"];
    if (![self.fileMgr fileExistsAtPath:self.filePath]) {
        if ([self.fileMgr createFileAtPath:self.filePath contents:nil attributes:nil]) {
            NSLog(@"success creating file");
        }
    }
    self.fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
    NSLog(@"view loaded");
}

- (void)viewDidUnload
{
    [self.fileHandler closeFile];
    [self setMessageLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)buttonPressed:(UIButton *)sender {
    if (sender.tag==1) { //start sensor logger pressed
        if (!readingSensor && self.motionManager.accelerometerAvailable && self.motionManager.gyroAvailable) {
            self.fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
            initialTimeInSeconds = [[NSDate date]timeIntervalSince1970];
            self.sensorRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:INTERRUPT_TIMER_TRIGGER_PERIOD target:self selector:@selector(readSensors) userInfo:nil repeats:YES];
            [self.sensorRefreshTimer fire];
            readingSensor = YES;
            self.messageLabel.text = @"Logging Started";
            NSLog(@"Start Sensor Logger pressed");
        }
    } else if (sender.tag==2) { //stop sensor logger pressed
        if (readingSensor && self.motionManager.accelerometerAvailable && self.motionManager.gyroAvailable) {
            [self.sensorRefreshTimer invalidate];
            //[self.fileHandler writeData:[sensorValues dataUsingEncoding:NSUTF8StringEncoding]];
            [self.fileHandler closeFile];
            readingSensor=NO;
            self.messageLabel.text = @"Logging Stopped";
            NSLog(@"Stop Sensor Logger pressed, interruptTimerCounter:%d",interruptTimerCounter);
        }
    } else if (sender.tag==3) { //clear log file pressed
        if (!readingSensor) {
            [self.fileHandler closeFile];
            [self.fileMgr removeItemAtPath:self.filePath error:nil];
            [self.fileMgr createFileAtPath:self.filePath contents:nil attributes:nil];
            self.fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
            self.messageLabel.text = @"Log Cleared";
            NSLog(@"Clear Log File pressed");
        }
    } else if (sender.tag==4) { //email log file pressed
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil && [mailClass canSendMail]) {
            if (!readingSensor) {
                NSLog(@"Email Log File pressed");
                [self displayComposerSheet];
            }
        } else {
            NSLog(@"MFMailComposeViewController class not found");
        }
    }
    
}

-(void)readSensors {
    self.accelerometerData = self.motionManager.accelerometerData;
    self.gyroData = self.motionManager.gyroData;
    currentTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    timeInSeconds = currentTimeInSeconds-initialTimeInSeconds;
    deltaTimeInterval = timeInSeconds - prevTimeInSeconds;
    //for sensor value string
    //[sensorValues appendFormat:@"t:%f Ax:%f Ay:%f Az:%f Gx:%f Gy:%f Gz:%f td:%f\n", timeInSeconds, self.accelerometerData.acceleration.x, self.accelerometerData.acceleration.y, self.accelerometerData.acceleration.z, self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.z, deltaTimeInterval];
    
    NSString *sensorReadValueString = [[NSString alloc]initWithFormat:@"t:%f Ax:%f Ay:%f Az:%f Gx:%f Gy:%f Gz:%f td:%f\n", timeInSeconds, self.accelerometerData.acceleration.x, self.accelerometerData.acceleration.y, self.accelerometerData.acceleration.z, self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.z, deltaTimeInterval];
    [self.fileHandler writeData:[sensorReadValueString dataUsingEncoding:NSUTF8StringEncoding]];
    
    prevTimeInSeconds = timeInSeconds;
    interruptTimerCounter++;
}

#pragma mark -
#pragma mark Compose Mail

-(void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
    picker.mailComposeDelegate = self;
    
    NSTimeInterval thisTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *subject = [[NSString alloc] initWithFormat:@"sensor data collected %f",thisTimeInSeconds];
    [picker setSubject:subject];
    NSArray *toRecipients = [NSArray arrayWithObjects:@"kaizou898@gmail.com", @"maxzly@gmail.com", @"keiby.zhou@gmail.com", nil];
    //NSArray *toRecipients = [NSArray arrayWithObjects:@"kaizou898@gmail.com", nil];
    [picker setToRecipients:toRecipients];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.filePath];
    NSString *fileToSend = [[NSString alloc]initWithFormat:@"sensorData_%f.txt", thisTimeInSeconds];
    [picker addAttachmentData:myData mimeType:@"text/plain" fileName:fileToSend];
    
    NSString *emailBody = @"sensor data attached. time is in seconds";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	self.messageLabel.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			self.messageLabel.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			self.messageLabel.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			self.messageLabel.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			self.messageLabel.text = @"Result: failed";
			break;
		default:
			self.messageLabel.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}
@end
