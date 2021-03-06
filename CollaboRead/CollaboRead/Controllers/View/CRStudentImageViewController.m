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
#import "CRAnswerLine.h"
#import "CRScan.h"

#define kCR_COLLABORATOR_TOGGLE_SHOW @"Show Collaborators"
#define kCR_COLLABORATOR_TOGGLE_HIDE @"Hide Collaborators"

@interface CRStudentImageViewController ()
/*!
 @brief Button that triggers toggling of collaborators panel
 */
@property (nonatomic, readwrite, strong) UIBarButtonItem *toggleCollaboratorsButton;
/*!
 @brief Button to trigger answer submission
 */
@property (nonatomic, readwrite, strong) CRSubmitButton *submitButton;
/*!
 @brief View controller to handle group creation
 */
@property (nonatomic, readwrite, strong) CRAddCollaboratorsViewController *collaboratorsView;
/*!
 Method to submit student answer
 @param submitButton
 Button that triggered method
 */
-(void)submitAnswer:(UIButton *)submitButton;
/*!
 Method to determine if an answer was already submitted for the scan shown
 @return Yes if there was an answer already submitted, no otherwise
 */
- (BOOL)userHasPreviouslySubmittedAnswer;
@end

@implementation CRStudentImageViewController

- (void)loadView {
    [super loadView];
    
    CGRect frame = CR_LANDSCAPE_FRAME; //Use iOS version appropriate bounds
    
    self.toggleCollaboratorsButton= [[UIBarButtonItem alloc] initWithTitle:kCR_COLLABORATOR_TOGGLE_SHOW
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
    self.toggleCollaboratorsButton.possibleTitles = [NSSet setWithArray:@[kCR_COLLABORATOR_TOGGLE_SHOW, kCR_COLLABORATOR_TOGGLE_HIDE]];
    self.navigationItem.rightBarButtonItem = self.toggleCollaboratorsButton;
    
    
    self.submitButton = [[CRSubmitButton alloc] init];
    [self.submitButton setFrame:CGRectMake(frame.size.width - 205, frame.size.height - 70, 180.0, 40.0)];
    [self.submitButton addTarget:self action:@selector(submitAnswer:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self userHasPreviouslySubmittedAnswer]) {
        self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_RESUBMIT;
    }
    
    [super.view addSubview:self.submitButton];
    
    self.collaboratorsView = [[CRAddCollaboratorsViewController alloc] init];
    self.collaboratorsView.delegate = self;
    self.collaboratorsView.toggleButton = self.toggleCollaboratorsButton;
    self.collaboratorsView.visible = NO;
    self.collaboratorsView.side = CR_SIDE_BAR_SIDE_RIGHT;
    [self addChildViewController:self.collaboratorsView];
    [super.view addSubview:self.collaboratorsView.view];
    self.view = super.view;
}

- (void)setScanIndex:(NSUInteger)scanIndex {
    [super setScanIndex:scanIndex];
    if (self.view) {
        self.submitButton.buttonState = [self userHasPreviouslySubmittedAnswer] ?CR_SUBMIT_BUTTON_STATE_RESUBMIT : CR_SUBMIT_BUTTON_STATE_SUBMIT;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)submitAnswer:(UIButton *)submitButton
{
	self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_PENDING;
    NSArray *students = [[CRCollaboratorList sharedInstance] collaboratorIds];

    //Prepare and send answer
	CRAnswer *answer = [self.imageMarkup.undoStack answersFromStackForOwners:students inGroup:[CRCollaboratorList sharedInstance].groupName];

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
    NSString *scanId = ((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID;
	[self.caseChosen.answers enumerateObjectsUsingBlock:^(id answerObj, NSUInteger idx, BOOL *stop) {
		if ([answerObj isKindOfClass:[CRAnswer class]]) {
			CRAnswer *answer = (CRAnswer*)answerObj;
			
            if ([answer.owners containsObject:[CRAccountService sharedInstance].user.userID]) {
                [answer.drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([((CRAnswerLine *)obj).scanID isEqualToString:scanId]) {
                        hasSubmitted = YES;
                        *stop = YES;
                    }
                }];
				*stop = YES;
			}
		}
	}];
	return hasSubmitted;
}

#pragma mark - CRSideBarViewController Delegate Methods

- (void)CRSideBarViewController:(CRSideBarViewController *)sideBarViewController didChangeVisibility:(BOOL)visible
{
    //Changing add collaborator view visiblity should change the toggle button's title
	self.toggleCollaboratorsButton.title = visible ? kCR_COLLABORATOR_TOGGLE_HIDE : kCR_COLLABORATOR_TOGGLE_SHOW;
}

@end
