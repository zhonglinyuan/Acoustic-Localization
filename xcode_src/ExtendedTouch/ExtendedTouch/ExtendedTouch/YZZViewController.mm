#import "YZZViewController.h"

@interface YZZViewController ()
@property (strong, nonatomic) YZZSensorManager *sensorManager;
@property (strong, nonatomic) YZZLocationManager *locationManager;
@end

@implementation YZZViewController {
    
}
@synthesize Location1Button = _Location1Button;
@synthesize Location2Button = _Location2Button;
@synthesize myDisplay = _myDisplay;
@synthesize location1Indicator = _location1Indicator;
@synthesize location2Indicator = _location2Indicator;
@synthesize locationIndicators = _locationIndicators;
@synthesize startButton = _startButton;
@synthesize mainButton = _mainButton;
@synthesize sensorManager = _sensorManager;
@synthesize locationManager = _locationManager;
@synthesize arrayColors = _arrayColors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sensorManager = [[YZZSensorManager alloc]init];
    self.locationManager = [[YZZLocationManager alloc]initWithNumberOfLocations:NUMBER_OF_LOCATION_TEMPLATES];
    
    self.arrayColors = [[NSMutableArray alloc]init];
    [self.arrayColors addObject:[UIColor blackColor]];
    [self.arrayColors addObject:[UIColor blueColor]];
    [self.arrayColors addObject:[UIColor redColor]];
    
    self.locationIndicators = [[NSMutableArray alloc]init];
    [self.locationIndicators addObject:self.myDisplay];
    [self.locationIndicators addObject:self.location1Indicator];
    [self.locationIndicators addObject:self.location2Indicator];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.emailButton.enabled = false;
    self.emailButton.alpha = 0;
}

- (IBAction)mainButtonPressed:(UIButton *)sender {
//    [Location1Button sendActionsForControlEvents:UIControlEventTouchUpInside];
//    self.Location1Button.tag = 1;
//    self.Location2Button.tag = 2;
    if([sender.currentTitle isEqualToString:@"Stop"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self StopTestingButton:nil];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainButton setTitle:@"Start" forState:UIControlStateNormal];
            self.mainButton.enabled = true;
            self.mainButton.alpha = 1;
            self.location1Indicator.text = @"";
            self.location2Indicator.text = @"";
            [self.location1Indicator setBackgroundColor:[UIColor blackColor]];
            [self.location2Indicator setBackgroundColor:[UIColor blackColor]];
            self.myDisplay.text = @"Please Place Your Device on a Horizontal Surface and then Press Start";
            [self.myDisplay setBackgroundColor:[UIColor blackColor]];
        });
    
        return;
    }
    self.mainButton.enabled = false;
    self.mainButton.alpha = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self LocationButtonPressed:self.Location1Button];
        NSLog(@"------------------- location 1 pressed -----------------");

        [self LocationButtonPressed:self.Location2Button];
        NSLog(@"------------------- location 2 pressed -----------------");

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.mainButton.enabled = true;
            self.mainButton.alpha = 1;
        });
        [self StartTesting:self.startButton];
        NSLog(@"------------------- start pressed -----------------");
        });

    //    if ([self.sensorManager getCapture_Data_Active] == true) {
//        return;
//    }
    
}

- (IBAction)LocationButtonPressed:(UIButton *)sender {
    NSLog(@"button pressed was %d", sender.tag);
    if ([self.sensorManager getCapture_Data_Active] == true) {
        return;
    }
    
    //implied else clause, this is where data gets collected
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sensorManager setCapture_Data_Active:true];
        
        dispatch_async(dispatch_get_main_queue(),^{
            self.myDisplay.backgroundColor = [UIColor blackColor];
            self.myDisplay.text = @"Please Wait...";
        });
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sensorManager determineAccelThreshold];
        });
        
        dispatch_async(dispatch_get_main_queue(),^{
            if (sender.tag == 1)
            {
                self.myDisplay.backgroundColor = [UIColor blackColor];
                self.myDisplay.text = @"Please Tap at a Location of Your Choice (Location 1)";
            }
            else if(sender.tag == 2)
            {
                self.myDisplay.backgroundColor = [UIColor blackColor];
                self.myDisplay.text = @"Please Tap at Another Location of Your Choice (Location 2)";
            }
        });
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sensorManager captureDataAtLocation:[self.locationManager getLocationObject:sender.tag]];
        });
        
        dispatch_async(dispatch_get_main_queue(),^{
            NSLog(@"Location %d Stored", sender.tag);
            self.myDisplay.text = [NSString stringWithFormat:@"Location %d Stored", sender.tag];
            self.myDisplay.backgroundColor = [UIColor blackColor];
            
            for (int i=1; i<NUMBER_OF_LOCATION_TEMPLATES; i++) {
                UILabel *locLabel = [self.locationIndicators objectAtIndex:(i)];
                if ([locLabel tag] == sender.tag) {
                    locLabel.backgroundColor = [self.arrayColors objectAtIndex:sender.tag];
                    if (sender.tag == 1)
                    {
                         self.location1Indicator.text = @"Location 1";
                    }
                    else if(sender.tag == 2)
                    {
                         self.location2Indicator.text = @"Location 2";
                    }
                }
            }
            
        });
    });
    NSLog(@"button pressed was %d done", sender.tag);
}

- (IBAction)StopTestingButton:(UIButton *)sender {
    NSLog(@"stop button pressed");
    if ([self.sensorManager getCapture_Data_Active]==true) {
        NSLog(@"first stop");
        [self.sensorManager setCapture_Data_Active:false];
        [self.sensorManager clearThreshold];
       // self.myDisplay.text = [NSString stringWithFormat:@"stopped"];
       // self.myDisplay.backgroundColor = [UIColor greenColor];
    } else {
       // self.myDisplay.text = [NSString stringWithFormat:@"already stopped"];
        //self.myDisplay.backgroundColor = [UIColor greenColor];
    }
}

- (IBAction)StartTesting:(UIButton *)sender {
    //    [NSThread detachNewThreadSelector:@selector(BackgroundCaptureThread) toTarget:self withObject:nil];
    NSLog(@"button pressed was %d", sender.tag);
    
    if ([self.sensorManager getCapture_Data_Active]==true) { //already running tap detection, return
        return;
    }
    //implied else clause
    [self.sensorManager setCapture_Data_Active:true];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while ([self.sensorManager getCapture_Data_Active]==true) {
            NSLog(@"AAA");
            
            dispatch_async(dispatch_get_main_queue(),^{
                self.myDisplay.backgroundColor = [UIColor blackColor];
                self.myDisplay.text = @"Tap Either Locations and I'll Guess";
            });
            
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.sensorManager captureDataAtLocation:[self.locationManager getLocationObject:sender.tag]];
                                //[self setupDataFilesAndEmailer];
            });//end synchronous dispatch
            
            //crosscorrelation happens here
            int theLocation = [self.locationManager crosscorrelateAllLocations];
            NSLog(@"detected location is %d",theLocation);
                        //break;
            
            if ([self.sensorManager getCapture_Data_Active]==true) {
                dispatch_async(dispatch_get_main_queue(),^{ //printing detection result
                    for (int i=1; i<NUMBER_OF_LOCATION_TEMPLATES; i++) {
                        UILabel *locLabel = [self.locationIndicators objectAtIndex:(i)];
                        if ([locLabel tag] == theLocation) {
                            self.myDisplay.text = [NSString stringWithFormat:@"You Tapped at Location %d", theLocation];
                            self.myDisplay.backgroundColor = [self.arrayColors objectAtIndex:theLocation];
                        }
                    }
                });
                [NSThread sleepForTimeInterval:1]; //delay added to display to user
            }
            NSLog(@"CCC");
        }
        NSLog(@"exit continuous test mode");
/*        if ([self.sensorManager getCapture_Data_Active] == false) {
            dispatch_async(dispatch_get_main_queue(),^{
                self.myDisplay.text = [NSString stringWithFormat:@"stopped"];
                self.myDisplay.backgroundColor = [UIColor greenColor];
            });
        }*/
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark email button

- (IBAction)EmailResultButton:(UIButton *)sender {
    NSLog(@"email button pressed");
    [self setupDataFilesAndEmailer];
}

- (void) setupDataFilesAndEmailer {
    NSLog(@"setupDataFilesAndEmailer called");
    [self.locationManager writeAllLocationBuffersToFiles];
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        [self displayComposerSheet];
    }
}

#pragma mark Compose Mail

-(void)displayComposerSheet {
    NSLog(@"displayComposerSheet function");
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
    picker.mailComposeDelegate = self;
    
    NSTimeInterval thisTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *fileName=[[NSString alloc]initWithFormat:@"SimpleTap"];
    NSString *subject = [[NSString alloc] initWithFormat:@"Mic Cross Corr %f %@",thisTimeInSeconds,fileName];
    [picker setSubject:subject];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"keiby.zhou@gmail.com", nil];//@"maxzly@gmail.com", @"keiby.zhou@gmail.com", nil];
    
    [picker setToRecipients:toRecipients];
    
    //attach the necessary files
    [self.locationManager addFilesAsAttachmentsWithComposer:picker andFileName:fileName withTimeStamp:thisTimeInSeconds];
    
    NSString *emailBody = @"Data used for mic cross correlation";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
