//
//  CRLecturerImageViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/20/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRLecturerImageViewController.h"

@interface CRLecturerImageViewController ()

@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *hideButton;

-(void)showAnswers:(UIButton *)showButton;
-(void)hideAnswers:(UIButton *)hideButton;

@end

@implementation CRLecturerImageViewController

//draw student answers, with instructor answer on top
-(void)showAnswers:(UIButton *)sender
{
    [self.hideButton setSelected:NO];
    [self.showButton setSelected:YES];
}

//Redraw only instructor answer
-(void)hideAnswers:(UIButton *)sender
{
    [self.showButton setSelected:NO];
    [self.hideButton setSelected:YES];
    [self redrawAnswer];
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
