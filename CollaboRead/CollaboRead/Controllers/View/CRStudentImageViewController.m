//
//  CRStudentImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CRStudentImageViewController.h"
#import "CRAPIClientService.h"
#import "CRUser.h"
#import "CRUserKeys.h"
#import "CRAnswerPoint.h"
#import "CRAnswerLine.h"
#import "CRColors.h"
#import "CRViewSizeMacros.h"
#import "CRPatientInfoViewController.h"
@interface CRStudentImageViewController ()

-(void)submitAnswer:(UIButton *)submitButton;
@property (nonatomic, strong) UIBarButtonItem *togglePatientInfoButton;
@property (nonatomic, readwrite, strong) CRPatientInfoViewController *patientInfoViewController;

@end

@implementation CRStudentImageViewController

//Set up student specific view elements
- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    CGRect frame = LANDSCAPE_FRAME; //Use iOS version appropriate bounds
    [submitButton setFrame:CGRectMake(frame.size.width - 170, frame.size.height - 70, 150, 50)];
	submitButton.backgroundColor = CR_COLOR_PRIMARY;
	submitButton.titleLabel.textColor = [UIColor whiteColor];
    [submitButton setTitle:@"Submit Answer" forState:UIControlStateNormal];//Change to setting images?
	[submitButton addTarget:self action:@selector(submitAnswer:) forControlEvents:UIControlEventTouchUpInside];
	submitButton.layer.borderWidth = 2.0;
	submitButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.patientInfoViewController = [[CRPatientInfoViewController alloc] initWithPatientInfo:self.patientInfo];
    [self.view addSubview:self.patientInfoViewController.view];
    self.togglePatientInfoButton= [[UIBarButtonItem alloc] initWithTitle:@"Patient Info"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self.patientInfoViewController
                                                                          action:@selector(toggleTable)];
    self.navigationItem.rightBarButtonItem = self.togglePatientInfoButton;
    [self.view addSubview:submitButton];
    [self.view setNeedsDisplay];
}

//Perform action of submitting answer, provide user status update
-(void)submitAnswer:(UIButton *)submitButton
{
    //Show attempt to submit
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((submitButton.frame.size.width - 50.0)/2,
																										   (submitButton.frame.size.height - 50.0)/2,
																										   50.0,
																										   50.0)];
    submitButton.userInteractionEnabled = NO; //Disallow repeated submissions
	[submitButton setTitle:@"" forState:UIControlStateNormal];
	
	[activityIndicator startAnimating];
	[submitButton addSubview:activityIndicator];

    NSArray *students = [[NSArray alloc]initWithObjects:self.user.userID, nil];

    //Prepare and send answer
	CRAnswerLine *ansDraw = [[CRAnswerLine alloc] initWithPoints:self.undoStack[0] forSlice: @"more blah" ofScan: @"blah"];
#warning this is not a real id
	CRAnswer *answer = [[CRAnswer alloc] initWithData:@[ansDraw] submissionDate:nil owners:students answerID:@"idk"];

    [[CRAPIClientService sharedInstance] submitAnswer:answer forCase:self.caseId inSet:self.caseGroup block:^(CRCaseSet *block) {//Provide submission success feedback
		NSString *unicodeCheckMark = @"\u2713";
		[submitButton setTitle:unicodeCheckMark forState:UIControlStateNormal];
		[activityIndicator removeFromSuperview];
	}];
}

@end
