//
//  CRAddCollaboratorsViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRAddCollaboratorsViewController.h"

@interface CRAddCollaboratorsViewController ()

@property (nonatomic, strong) NSMutableArray *collaborators;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITextField *enterField;

-(void)addStudent;

@end

@implementation CRAddCollaboratorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
