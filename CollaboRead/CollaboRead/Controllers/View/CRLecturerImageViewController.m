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
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userIDtemp;
@property (nonatomic, strong) CRAnswer *currentAnswer;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentAnswerTableButton;
@property (nonatomic, strong) UIBarButtonItem *toggleStudentRefreshAnswerTableButton;
@property (nonatomic, strong) NSArray *caseSets;

@property (nonatomic, readwrite, strong) CRStudentAnswerTableViewController *studentAnswerViewController;

@end

@implementation CRLecturerImageViewController

-(void)drawStudentAnswers
{
    NSArray *answers = self.caseChosen.answers;
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *ansLine = [[NSMutableArray alloc] init];
        [((CRAnswer *)obj).drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ansLine addObject:[[CRAnswerPoint alloc] initFromJSONDict:obj]];
        }];
        NSDictionary* color = studentColors[idx % 15];
        [self drawAnswer:ansLine inRed: [color[@"red"] floatValue] Green:[color[@"green"] floatValue] Blue:[color[@"blue"] floatValue]];
    }];
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
    NSMutableArray *allstudents = [[NSMutableArray alloc] init];;
    NSArray *answers = self.caseChosen.answers;
    
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [((CRAnswer *)obj).owners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            self.userID = obj;
            [self.allUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *temp = ((CRUser*) obj).userID;
                if ([self.userID isEqualToString:temp]){
                    [allstudents addObject:((CRUser*) obj)];
                }
            }];
            
        }];
    }];
    self.allStudents = [NSArray arrayWithArray:allstudents];
    self.studentAnswerViewController = [[CRStudentAnswerTableViewController alloc] initWithStudents:self.allStudents];

}

#pragma mark - CRStudentAnswerTable Delegate Methods
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTable didChangeStudentSelection:(NSArray *)students
{
    [self clearDrawing];
    //if ([self.undoStack count] > 0) {
    //    [self drawAnswer:self.undoStack[0] inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    //}
    NSArray *answers =self.caseChosen.answers;
    NSMutableArray *temp = [[NSMutableArray alloc] init];;
	NSMutableArray *colors = [[NSMutableArray alloc] init];
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger ansIdx, BOOL *stop) {
        self.currentAnswer = ((CRAnswer *)obj);
        [((CRAnswer *)obj).owners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            self.userIDtemp = obj;
            [students enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.userIDtemp isEqualToString:((CRUser*) obj).userID]){
                    [temp addObject:self.currentAnswer];
                    [colors addObject:studentColors[ansIdx % 15]];
                }
			}];
        }];
    }];
    NSArray *tempAnswers = [NSArray arrayWithArray:temp];
    [tempAnswers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *ansLine = [[NSMutableArray alloc] init];
        [((CRAnswer *)obj).drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ansLine addObject:[[CRAnswerPoint alloc] initFromJSONDict:obj]];
		}];

		NSDictionary *color = colors[idx];
        [self drawAnswer:ansLine inRed: [color[@"red"] floatValue] Green:[color[@"green"] floatValue] Blue:[color[@"blue"] floatValue]];
    }];
}

-(void)studentAnswerTableView:(CRStudentAnswerTableViewController *)studentAnswerTableView didRefresh:(CRCase *)refreshedCase{
    self.caseChosen.answers = refreshedCase.answers;
}


@end
