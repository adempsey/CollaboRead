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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)submitAnswer:(UIButton *)submitButton
{
    CRUser *params = self.user;
    NSString *userID = params.userID;
    NSString *caseID = [NSString stringWithFormat: @"%ld", (long)self.caseId];
    NSString *setID = [NSString stringWithFormat: @"%ld", (long)self.caseGroup];
    NSArray *students = [[NSArray alloc]initWithObjects:userID, nil];;
    NSString *answers = [NSString stringWithFormat: @"%ld", (long)self.undoStack[0]];
    [[CRAPIClientService sharedInstance] submitAnswer:answers fromStudents:students forCase:caseID inSet:setID block:^(NSDictionary *block){
    
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
