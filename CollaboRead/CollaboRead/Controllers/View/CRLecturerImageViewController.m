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
#include "CRUser.h"
#include "CRAnswerLine.h"
#include "CRScan.h"
#include "CRSlice.h"

#define studentColors @[@{@"red":@0, @"green": @255, @"blue" : @0}, \
                        @{@"red":@0, @"green": @0, @"blue" : @255}, \
                        @{@"red":@255, @"green": @255, @"blue" : @0}, \
                        @{@"red":@255, @"green": @0, @"blue" : @255}, \
                        @{@"red":@0, @"green": @255, @"blue" : @255}, \
                        @{@"red":@255, @"green": @150, @"blue" : @100}, \
                        @{@"red":@175, @"green": @255, @"blue" : @50}, \
                        @{@"red":@175, @"green": @255, @"blue" : @255}, \
                        @{@"red":@175, @"green": @100, @"blue" : @255}, \
                        @{@"red":@175, @"green": @255, @"blue" : @200}, \
                        @{@"red":@255, @"green": @50, @"blue" : @100}, \
                        @{@"red":@150, @"green": @150, @"blue" : @255}, \
                        @{@"red":@255, @"green": @200, @"blue" : @255}, \
                        @{@"red":@0, @"green": @150, @"blue" : @150}, \
                        @{@"red":@150, @"green": @100, @"blue" : @100}]

@interface CRLecturerImageViewController ()
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) NSArray *allStudents;
@property (nonatomic, strong) NSArray *selectedAnswers;
@property (nonatomic, strong) NSArray *selectedColors;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentAnswerTableButton;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentRefreshAnswerTableButton;

@property (nonatomic, readwrite, strong) CRStudentAnswerTableViewController *studentAnswerViewController;

@end

@implementation CRLecturerImageViewController

-(void)drawStudentAnswers
{
    [self clearDrawing];
    NSString *scanID = ((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID;
    NSString *sliceID = ((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).sliceID;
    [self.selectedAnswers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* color = self.selectedColors[idx];
        [((CRAnswer *)obj).drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswerLine *line = obj;
            if ([line.scanID isEqualToString: scanID] && [line.sliceID isEqualToString:sliceID]) {
                [self drawAnswer:line.data inRed: [color[@"red"] floatValue] Green:[color[@"green"] floatValue] Blue:[color[@"blue"] floatValue]];
                *stop = true;
            }
        }];

        
    }];
    [self drawAnswer:self.currentDrawing inRed: self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //CGFloat topBarHeight = self.navigationController.navigationBar.frame.size.height +
    //[UIApplication sharedApplication].statusBarFrame.size.height;
	self.view.autoresizesSubviews = NO;

	// Should pass array of CRUsers that have submitted answers
	// This workflow will need to be adjusted in the future, since this list will change as students submit answers
    [self loadStudents];
	self.studentAnswerViewController.delegate = self;
	[self.view addSubview:self.studentAnswerViewController.view];
    self.studentAnswerViewController.indexPath = self.indexPath;
    self.studentAnswerViewController.lecturerID = self.lecturerID;
    self.studentAnswerViewController.allUsers = self.allUsers;

	self.toggleStudentAnswerTableButton = [[UIBarButtonItem alloc] initWithTitle:@"Answers"
																					   style:UIBarButtonItemStylePlain
																					  target:self.studentAnswerViewController
																					  action:@selector(toggleTable)];
	self.navigationItem.rightBarButtonItem = self.toggleStudentAnswerTableButton;
    [self.view setNeedsDisplay];
}


- (void) loadStudents
{
    NSMutableArray *allStudents = [[NSMutableArray alloc] init];;
    NSArray *answers = self.caseChosen.answers;
    
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [allStudents addObject:((CRAnswer *)obj).owners];
    }];
    self.allStudents = allStudents;
    self.studentAnswerViewController = [[CRStudentAnswerTableViewController alloc] initWithStudents:self.allStudents];

}

#pragma mark - CRStudentAnswerTable Delegate Methods
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeStudentSelection:(NSArray *)students
{
    [self clearDrawing];
    [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    NSMutableArray *selectedAnswers = [[NSMutableArray alloc] init];;
	NSMutableArray *colors = [[NSMutableArray alloc] init];
    [students enumerateObjectsUsingBlock:^(id obj, NSUInteger ansIdx, BOOL *stop) {
        NSArray *currOwners = obj;
        [self.caseChosen.answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswer *currAnswer = obj;
            if ([currAnswer.owners isEqualToArray:currOwners]){
                [selectedAnswers addObject:currAnswer];
                [colors addObject:studentColors[ansIdx % 15]];
            }
        }];
    }];
    self.selectedAnswers = selectedAnswers;
    self.selectedColors = colors;
    [self drawStudentAnswers];
}

-(void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTableView didRefresh:(CRCase *)refreshedCase{
    self.caseChosen.answers = refreshedCase.answers;
}

-(void) scansMenuViewControllerDidSelectScan:(NSString *)scanId
{
    [super scansMenuViewControllerDidSelectScan:scanId];
    [self drawStudentAnswers];
}

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
    [super toolPanelViewController:toolPanelViewController didSelectTool:tool];
    [self drawStudentAnswers];
}

@end
