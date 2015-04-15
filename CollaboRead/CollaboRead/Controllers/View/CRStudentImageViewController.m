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
#import "CRDrawingPreserver.h"
#import "CRNotifications.h"

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

@end

@implementation CRStudentImageViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.submitButton = [[CRSubmitButton alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousAnswerFound:) name:CR_NOTIFICATION_PREVIOUS_ANSWER_FOUND object:nil];
    }
    return self;
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.submitButton.buttonState = [[[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseChosen.caseID] answerSubmittedForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID] ? CR_SUBMIT_BUTTON_STATE_RESUBMIT : CR_SUBMIT_BUTTON_STATE_SUBMIT;
}

- (void)setScanIndex:(NSUInteger)scanIndex {
    [super setScanIndex:scanIndex];
    self.submitButton.buttonState = [[[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseChosen.caseID] answerSubmittedForScan:((CRScan *)self.caseChosen.scans[scanIndex]).scanID] ? CR_SUBMIT_BUTTON_STATE_RESUBMIT : CR_SUBMIT_BUTTON_STATE_SUBMIT;
}

- (void)previousAnswerFound:(NSNotification*)notification
{
    self.submitButton.buttonState = [[[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseChosen.caseID] answerSubmittedForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID] ? CR_SUBMIT_BUTTON_STATE_RESUBMIT : CR_SUBMIT_BUTTON_STATE_SUBMIT;
}

- (void)submitAnswer:(UIButton *)submitButton
{
	self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_PENDING;

    //Prepare and send answer
	CRAnswer *answer = [self.imageMarkup.undoStack answersFromStack];

    [[CRAPIClientService sharedInstance] submitAnswer:answer block:^(CRLecture *block, NSError *error) {//Provide submission success feedback
		if (!error) {
			self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_SUCCESS;
            [[[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseChosen.caseID] submitAnswerForScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID];
		} else {
            self.submitButton.buttonState = CR_SUBMIT_BUTTON_STATE_SUBMIT;
			UIAlertController *alertController = [[CRErrorAlertService sharedInstance] networkErrorAlertForItem:@"case" completionBlock:nil];
			[self presentViewController:alertController animated:YES completion:nil];
		}
	}];
}

#pragma mark - CRSideBarViewController Delegate Methods

- (void)CRSideBarViewController:(CRSideBarViewController *)sideBarViewController didChangeVisibility:(BOOL)visible
{
    //Changing add collaborator view visiblity should change the toggle button's title
	self.toggleCollaboratorsButton.title = visible ? kCR_COLLABORATOR_TOGGLE_HIDE : kCR_COLLABORATOR_TOGGLE_SHOW;
}

@end
