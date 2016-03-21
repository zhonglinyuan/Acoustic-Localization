//
//  YZZViewController.h
//  EngineTester
//
//  Created by Kai Zou on 2013-01-25.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZZExtendedTouchEngine.h"
#import "YZZSensorController.h"

@interface YZZViewController : UIViewController <NSStreamDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelGuess;
@property (strong, nonatomic) IBOutlet UILabel *guessOutputLabel;

- (IBAction)recordTemplateButton:(UIButton *)sender;

- (IBAction)guessButton:(id)sender;
- (IBAction)stopGuessButtonPressed:(id)sender;
- (IBAction)unregAllButtonPressed:(id)sender;

- (IBAction)showLabelxcorrButtonPressed:(id)sender;

- (IBAction)envSetupButton:(id)sender;

// network
- (void)initNetworkCommunicationtoIP:(NSString *) ip;
- (void)sendfloat:(float *)myMicData withlength:(int)myMicDataLength;
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;

@property (strong, atomic) NSInputStream *inputStream;
@property (strong, atomic) NSOutputStream *outputStream;
@property (weak, nonatomic) IBOutlet UITextField *serverip;

//- (IBAction)clearAllFilesButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *setupTextField;
@property (strong, nonatomic) IBOutlet UITextField *actualLocTextField;
- (IBAction)inputDoneEditing:(id)sender;
- (IBAction)setupNumberEntered:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numOfLoc;
@property (weak, nonatomic) IBOutlet UITextField *numPerLoc;

- (void)registerLocationForTemplateNum:(int) TemplatePerLoc;

@end
