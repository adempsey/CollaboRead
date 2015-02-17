//
//  CRStudentImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRStudentImageViewController.h"
#import "CRAPIClientService.h"
#import "CRViewSizeMacros.h"
#import "CRPatientInfoViewController.h"
#import "CRSubmitButton.h"
#import "CRErrorAlertService.h"

@interface CRStudentImageViewController ()

@property (nonatomic, strong) UIBarButtonItem *togglePatientInfoButton;
@property (nonatomic, readwrite, strong) CRPatientInfoViewController *patientInfoViewController;
@property (nonatomic, readwrite, strong) CRSubmitButton *submitButton;

@end

@implementation CRStudentImageViewController

//Set up student specific view elements
- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect frame = CR_LANDSCAPE_FRAME; //Use iOS version appropriate bounds

	self.togglePatientInfoButton= [[UIBarButtonItem alloc] initWithTitle:@"Patient Info"
																   style:UIBarButtonItemStylePlain
																  target:nil
																  action:nil];
	self.navigationItem.rightBarButtonItem = self.togglePatientInfoButton;

	self.patientInfoViewController = [[CRPatientInfoViewController alloc] initWithPatientInfo:self.patientInfo];
	self.patientInfoViewController.toggleButton = self.togglePatientInfoButton;
    [self.view addSubview:self.patientInfoViewController.view];

	self.submitButton = [[CRSubmitButton alloc] init];
	[self.submitButton setFrame:CGRectMake(frame.size.width - 205, frame.size.height - 70, 180.0, 40.0)];
	[self.submitButton addTarget:self action:@selector(submitAnswer:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([self userHasPreviouslySubmittedAnswer]) {
		self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_RESUBMIT;
	}
	
	[self.view addSubview:self.submitButton];
}

//Perform action of submitting answer, provide user status update
-(void)submitAnswer:(UIButton *)submitButton
{
	self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_PENDING;
    NSArray *students = [[NSArray alloc]initWithObjects:self.user.userID, nil];

    //Prepare and send answer
	CRAnswer *answer = [self.undoStack answersFromStackForOwners:students];

    [[CRAPIClientService sharedInstance] submitAnswer:answer forCase:self.caseChosen.caseID inSet:self.caseGroup block:^(CRCaseSet *block, NSError *error) {//Provide submission success feedback
		if (!error) {
			self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_SUCCESS;
		} else {
			UIAlertController *alertController = [[CRErrorAlertService sharedInstance] networkErrorAlertForItem:@"case" completionBlock:^(UIAlertAction *action) {
				if (self != self.navigationController.viewControllers[0]) {
					[self.navigationController popViewControllerAnimated:YES];
				} else if (self.presentingViewController) {
					[self dismissViewControllerAnimated:YES completion:nil];
				}
			}];
			[self presentViewController:alertController animated:YES completion:nil];
		}
	}];
}

- (BOOL)userHasPreviouslySubmittedAnswer
{
	BOOL __block hasSubmitted = NO;
	
	[self.caseChosen.answers enumerateObjectsUsingBlock:^(id answerObj, NSUInteger idx, BOOL *stop) {
		if ([answerObj isKindOfClass:[CRAnswer class]]) {
			CRAnswer *answer = (CRAnswer*)answerObj;
			
			if ([answer.owners containsObject:self.user.userID]) {
				hasSubmitted = YES;
				*stop = YES;
			}
		}
	}];
	return hasSubmitted;
}

@end
