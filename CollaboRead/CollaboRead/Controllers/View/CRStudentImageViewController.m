//
//  CRStudentImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRStudentImageViewController.h"
#import "CRAPIClientService.h"
#import "CRUser.h"
#import "CRUserKeys.h"
#import "CRAnswerPoint.h"
@interface CRStudentImageViewController ()

-(void)submitAnswer:(UIButton *)submitButton;

@end

@implementation CRStudentImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [submitButton setFrame:CGRectMake(self.view.frame.size.width - 170, self.view.frame.size.height - 70, 150, 50)];
    [submitButton setBackgroundColor:[UIColor lightGrayColor]];
    [submitButton setTitle:@"Submit Answer" forState:UIControlStateNormal];//Change to setting images?
    [self.view addSubview:submitButton];
    [submitButton addTarget:self action:@selector(submitAnswer:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)submitAnswer:(UIButton *)submitButton
{
    NSArray *students = [[NSArray alloc]initWithObjects:self.user.userID, nil];;
    
    NSMutableArray *answerPts = [[NSMutableArray alloc] init];
    [self.undoStack[0] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [answerPts addObject:[(CRAnswerPoint *)obj jsonDictFromPoint]];
    }];
    
	CRAnswer *answer = [[CRAnswer alloc] initWithData:answerPts submissionDate:nil owners:students];

	[[CRAPIClientService sharedInstance] submitAnswer:answer forCase:self.caseId inSet:self.caseGroup block:^(CRCaseSet *block) {

	}];
}

@end
