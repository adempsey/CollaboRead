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
#import "CRSubmitButton.h"
#import "CRAddCollaboratorsViewController.h"
#import "CRErrorAlertService.h"
#import "CRAccountService.h"
#import "CRCollaboratorList.h"
#import "CRColors.h"

#define kCR_SIDE_BAR_TOGGLE_SHOW @"Show Patient Info"
#define kCR_SIDE_BAR_TOGGLE_HIDE @"Hide Patient Info"

#define kCR_COLLABORATOR_TOGGLE_SHOW @"Show Collaborators"
#define kCR_COLLABORATOR_TOGGLE_HIDE @"Hide Collaborators"

@interface CRStudentImageViewController ()

@property (nonatomic, readwrite, strong) UIBarButtonItem *togglePatientInfoButton;
@property (nonatomic, readwrite, strong) CRPatientInfoViewController *patientInfoViewController;
@property (nonatomic, readwrite, strong) CRSubmitButton *submitButton;
@property (nonatomic, readwrite, strong) CRAddCollaboratorsViewController *collaboratorsView;
@property (nonatomic, readwrite, strong) UIButton *toggleCollaborators;

@end

@implementation CRStudentImageViewController

//Set up student specific view elements
- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect frame = CR_LANDSCAPE_FRAME; //Use iOS version appropriate bounds

	self.togglePatientInfoButton= [[UIBarButtonItem alloc] initWithTitle:kCR_SIDE_BAR_TOGGLE_HIDE
																   style:UIBarButtonItemStylePlain
																  target:nil
																  action:nil];
	self.togglePatientInfoButton.possibleTitles = [NSSet setWithArray:@[kCR_SIDE_BAR_TOGGLE_HIDE, kCR_SIDE_BAR_TOGGLE_SHOW]];
	self.navigationItem.rightBarButtonItem = self.togglePatientInfoButton;

	self.patientInfoViewController = [[CRPatientInfoViewController alloc] initWithPatientInfo:self.patientInfo];
	self.patientInfoViewController.delegate = self;
	self.patientInfoViewController.toggleButton = self.togglePatientInfoButton;
    [self.view addSubview:self.patientInfoViewController.view];

	self.submitButton = [[CRSubmitButton alloc] init];
	[self.submitButton setFrame:CGRectMake(frame.size.width - 205, frame.size.height - 70, 180.0, 40.0)];
	[self.submitButton addTarget:self action:@selector(submitAnswer:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([self userHasPreviouslySubmittedAnswer]) {
		self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_RESUBMIT;
	}
	
	[self.view addSubview:self.submitButton];
    
    self.toggleCollaborators = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 205, frame.size.height - 140, 180.0, 40.0)];
    [self.toggleCollaborators setTitle:kCR_COLLABORATOR_TOGGLE_SHOW forState:UIControlStateNormal];
    [self.toggleCollaborators setTitleColor:CR_COLOR_TINT forState:UIControlStateNormal];
    [self.toggleCollaborators addTarget:self action:@selector(toggleCollaborators:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleCollaborators];
    
    self.collaboratorsView = [[CRAddCollaboratorsViewController alloc] init];
    [self.collaboratorsView setViewFrame:CGRectMake(self.toggleCollaborators.frame.origin.x, self.toggleCollaborators.frame.origin.y, 0, 0)];
    self.collaboratorsView.view.hidden = YES;
    [self.view addSubview:self.collaboratorsView.view];
}

//Perform action of submitting answer, provide user status update
-(void)submitAnswer:(UIButton *)submitButton
{
	self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_PENDING;
#warning Add support here for multiple answer owners
	NSArray *students = @[[CRAccountService sharedInstance].user.userID];
//    NSArray *students = [[CRCollaboratorList sharedInstance] collaboratorIds];

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

-(void)toggleCollaborators:(UIButton *)sender {
    BOOL show =[sender.currentTitle isEqualToString:kCR_COLLABORATOR_TOGGLE_SHOW];
    if (show) {
        self.collaboratorsView.view.hidden = NO;
    }
    CGRect frame = CGRectMake(self.toggleCollaborators.frame.origin.x, self.toggleCollaborators.frame.origin.y, 0, 0);
    if (show) {
        frame = CGRectMake((self.view.frame.size.width - 300)/2, (self.view.frame.size.height - 400)/2, 300, 400);
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.collaboratorsView setViewFrame:frame];
    } completion:^(BOOL finished) {
        NSString* newTitle = kCR_COLLABORATOR_TOGGLE_HIDE;
        if (!show) {
            newTitle = kCR_COLLABORATOR_TOGGLE_SHOW;
            self.collaboratorsView.view.hidden = YES;
        }
        [self.toggleCollaborators setTitle: newTitle forState:UIControlStateNormal];
    }];
}

- (BOOL)userHasPreviouslySubmittedAnswer
{
	BOOL __block hasSubmitted = NO;
	
	[self.caseChosen.answers enumerateObjectsUsingBlock:^(id answerObj, NSUInteger idx, BOOL *stop) {
		if ([answerObj isKindOfClass:[CRAnswer class]]) {
			CRAnswer *answer = (CRAnswer*)answerObj;
			
			if ([answer.owners containsObject:[CRAccountService sharedInstance].user.userID]) {
				hasSubmitted = YES;
				*stop = YES;
			}
		}
	}];
	return hasSubmitted;
}

#pragma mark - CRSideBarViewController Delegate Methods

- (void)CRSideBarViewController:(CRSideBarViewController *)sideBarViewController didChangeVisibility:(BOOL)visible
{
	self.togglePatientInfoButton.title = visible ? kCR_SIDE_BAR_TOGGLE_HIDE : kCR_SIDE_BAR_TOGGLE_SHOW;
}

@end
