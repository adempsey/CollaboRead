//
//  CRLecturerImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRLecturerImageViewController.h"
#include "CRAPIClientService.h"
#include "CRAnswerPoint.h"

@interface CRLecturerImageViewController ()

@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *hideButton;

@property (nonatomic, readwrite, strong) CRStudentAnswerTableViewController *studentAnswerViewController;

-(void)showAnswers:(UIButton *)showButton;
-(void)hideAnswers:(UIButton *)hideButton;

@end

@implementation CRLecturerImageViewController

//draw student answers, with instructor answer on top
-(void)showAnswers:(UIButton *)sender
{
    [self.hideButton setSelected:NO];
    [self.showButton setSelected:YES];
    [self clearDrawing];
    if ([self.undoStack count] > 0) {
        [self drawAnswer:self.undoStack[0]];
    }
    [[CRAPIClientService sharedInstance] retrieveCaseSetWithID:self.caseGroup block:^(CRCaseSet *caseSet)
     {
         //update case to get new answers
         self.caseChosen = caseSet.cases[self.caseId];
         [self drawStudentAnswers];
     }]; //UNCOMMENT WHEN FIXED
}

//Redraw only instructor answer
-(void)hideAnswers:(UIButton *)sender
{
    [self.showButton setSelected:NO];
    [self.hideButton setSelected:YES];
    [self clearDrawing];
	if ([self.undoStack count] > 0) {
		[self drawAnswer:self.undoStack[0]];
	}
}

-(void)drawStudentAnswers
{
    NSArray *answers = self.caseChosen.answers;
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *ansLine = [[NSMutableArray alloc] init];
        [((CRAnswer *)obj).answerData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ansLine addObject:[[CRAnswerPoint alloc] initFromJSONDict:obj]];
        }];
		[self drawAnswer:ansLine];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat topBarHeight = self.navigationController.navigationBar.frame.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.showButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [self.showButton setFrame:CGRectMake(self.view.frame.size.width - 220, topBarHeight + 20, 200, 50)];
    [self.showButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.showButton setTitle:@"Show Student Answers" forState:UIControlStateNormal];
    [self.showButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.view addSubview:self.showButton];
    [self.showButton addTarget:self action:@selector(showAnswers:) forControlEvents:UIControlEventTouchUpInside];
    
    self.hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [self.hideButton setFrame:CGRectMake(self.view.frame.size.width - 220, topBarHeight + 90, 200, 50)];
    [self.hideButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.hideButton setTitle:@"Hide Student Answers" forState:UIControlStateNormal];
    [self.hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.hideButton setSelected:YES];
    [self.view addSubview:self.hideButton];
    [self.hideButton addTarget:self action:@selector(hideAnswers:) forControlEvents:UIControlEventTouchUpInside];

	self.view.autoresizesSubviews = NO;

	// Should pass array of CRUsers that have submitted answers
	// This workflow will need to be adjusted in the future, since this list will change as students submit answers
	self.studentAnswerViewController = [[CRStudentAnswerTableViewController alloc] initWithStudents:nil];
	self.studentAnswerViewController.delegate = self;
	[self.view addSubview:self.studentAnswerViewController.view];

	UIBarButtonItem *toggleStudentAnswerTableButton = [[UIBarButtonItem alloc] initWithTitle:@"Answers"
																					   style:UIBarButtonItemStylePlain
																					  target:self.studentAnswerViewController
																					  action:@selector(toggleTable)];

	self.navigationItem.rightBarButtonItem = toggleStudentAnswerTableButton;

}

#pragma mark - CRStudentAnswerTable Delegate Methods

- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeStudentSelection:(NSArray *)students
{

}

@end
