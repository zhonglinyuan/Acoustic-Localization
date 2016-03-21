//
//  SimpleTapViewController.m
//  SimpleTap
//
//  Created by ZhongLin Yuan on 2012-11-14.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//
#import "SimpleTapViewController.h"

@interface SimpleTapViewController ()
@property (strong, nonatomic) YZZSensorManager *sensorManager;
@property (strong, nonatomic) YZZLocationManager *locationManager;
@end

@implementation SimpleTapViewController {
    int predictedLocation;
}
@synthesize Location1Button = _Location1Button;
@synthesize Location2Button = _Location2Button;
@synthesize myDisplay = _myDisplay;
@synthesize location1Indicator = _location1Indicator;
@synthesize location2Indicator = _location2Indicator;
@synthesize locationIndicators = _locationIndicators;

@synthesize sensorManager = _sensorManager;
@synthesize locationManager = _locationManager;
@synthesize arrayColors = _arrayColors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->predictedLocation = 0;
    
    self.sensorManager = [[YZZSensorManager alloc]init];
    self.locationManager = [[YZZLocationManager alloc]initWithNumberOfLocations:NUMBER_OF_LOCATION_TEMPLATES];
    
    self.arrayColors = [[NSMutableArray alloc]init];
    [self.arrayColors addObject:[UIColor greenColor]];
    [self.arrayColors addObject:[UIColor blueColor]];
    [self.arrayColors addObject:[UIColor redColor]];
    
    self.locationIndicators = [[NSMutableArray alloc]init];
    [self.locationIndicators addObject:self.myDisplay];
    [self.locationIndicators addObject:self.location1Indicator];
    [self.locationIndicators addObject:self.location2Indicator];
    
    self.emailButton.enabled = false;
    self.emailButton.alpha = 0;
}

- (IBAction)LocationButtonPressed:(UIButton *)sender {
    NSLog(@"button pressed was %d", sender.tag);
    if ([self.sensorManager getCapture_Data_Active] == true) {
        return;
    }
    
    //implied else clause, this is where data gets collected
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sensorManager setCapture_Data_Active:true];
        
        dispatch_async(dispatch_get_main_queue(),^{
            self.myDisplay.backgroundColor = [UIColor yellowColor];
            self.myDisplay.text = @"hold on";
        });
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sensorManager determineAccelThreshold];
        });
        
        dispatch_async(dispatch_get_main_queue(),^{
            self.myDisplay.backgroundColor = [UIColor greenColor];
            self.myDisplay.text = @"please tap";
        });
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sensorManager captureDataAtLocation:[self.locationManager getLocationObject:sender.tag]];
        });
        
        dispatch_async(dispatch_get_main_queue(),^{
            NSLog(@"Location %d Stored", sender.tag);
            self.myDisplay.text = [NSString stringWithFormat:@"Location %d Stored", sender.tag];
            self.myDisplay.backgroundColor = [UIColor greenColor];
                        
            for (int i=1; i<NUMBER_OF_LOCATION_TEMPLATES; i++) {
                UILabel *locLabel = [self.locationIndicators objectAtIndex:(i)];
                if ([locLabel tag] == sender.tag) {
                    locLabel.backgroundColor = [self.arrayColors objectAtIndex:sender.tag];
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
        self.myDisplay.text = [NSString stringWithFormat:@"stopped"];
        self.myDisplay.backgroundColor = [UIColor greenColor];
    } else {
        self.myDisplay.text = [NSString stringWithFormat:@"already stopped"];
        self.myDisplay.backgroundColor = [UIColor greenColor];
    }
}

- (IBAction)StartTesting:(UIButton *)sender {
    //    [NSThread detachNewThreadSelector:@selector(BackgroundCaptureThread) toTarget:self withObject:nil];
    NSLog(@"button pressed was %d", sender.tag);
    
    if ([self.sensorManager getCapture_Data_Active]==true) { //already running tap detection, return
        return;
    }
    //implied else clause
    [self.sensorManager setEmailSent:true];
    [self.sensorManager setCapture_Data_Active:true];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while ([self.sensorManager getCapture_Data_Active]==true) {
            NSLog(@"AAA");
            
            dispatch_async(dispatch_get_main_queue(),^{
                self.myDisplay.backgroundColor = [UIColor greenColor];
                self.myDisplay.text = @"waiting for tap";
            });
            
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.sensorManager captureDataAtLocation:[self.locationManager getLocationObject:sender.tag]];
                printf("HELLOWORLD\n\n");
            });//end synchronous dispatch
            
            //crosscorrelation happens here
            int theLocation = [self.locationManager crosscorrelateAllLocations];
            NSLog(@"detected location is %d",theLocation);
//            break;
            
            if ([self.sensorManager getCapture_Data_Active]==true) {
                dispatch_async(dispatch_get_main_queue(),^{ //printing detection result
                    for (int i=1; i<NUMBER_OF_LOCATION_TEMPLATES; i++) {
                        UILabel *locLabel = [self.locationIndicators objectAtIndex:(i)];
                        if ([locLabel tag] == theLocation) {
                            self.myDisplay.text = [NSString stringWithFormat:@"location %d detected", theLocation];
                            self.myDisplay.backgroundColor = [self.arrayColors objectAtIndex:theLocation];
                            self->predictedLocation = theLocation;
                        }
                    }
                });
                [NSThread sleepForTimeInterval:0.5]; //delay added to display to user
            }
            NSLog(@"CCC");

            dispatch_sync(dispatch_get_main_queue(),^{
                if ([[self.actualTappedLocationField text] length]!=0) {
                    [self setupDataFilesAndEmailer];
                }
            });

        }
        NSLog(@"exit continuous test mode");
        if ([self.sensorManager getCapture_Data_Active] == false) {
            dispatch_async(dispatch_get_main_queue(),^{
                self.myDisplay.text = [NSString stringWithFormat:@"stopped"];
                self.myDisplay.backgroundColor = [UIColor greenColor];
            });
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inputDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark email button

- (IBAction)EmailResultButton:(UIButton *)sender {
    NSLog(@"email button pressed");
    [self setupDataFilesAndEmailer];
}

- (void) setupDataFilesAndEmailer {
    [self.sensorManager setEmailSent:false];
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
    //[self.locationManager addFilesAsAttachmentsWithComposer:picker andFileName:fileName withTimeStamp:thisTimeInSeconds];
    
    NSString *actualLocation = [self.actualTappedLocationField text];
    
    [self.locationManager addFilesAsAttachmentsWithComposer:picker andFileName:fileName withTimeStamp:thisTimeInSeconds withActualTappedLocation:[actualLocation intValue] withPredictedTappedLocation:self->predictedLocation];

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
    [self.sensorManager setEmailSent:true];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
