//
//  CRStudentImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRStudentImageViewController.h"

@interface CRStudentImageViewController ()

-(void)submitAnswer:(UIButton *)submitButton;

@end

@implementation CRStudentImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [submitButton setFrame:CGRectMake(self.view.frame.size.width - 170, self.view.frame.size.height - 70, 50, 150)];
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
    //API call
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
