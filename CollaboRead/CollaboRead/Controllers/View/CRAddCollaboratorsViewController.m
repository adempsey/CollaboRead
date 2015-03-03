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
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *enterField;

-(void)addStudent;

@end

@implementation CRAddCollaboratorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collaborators = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc]init];//TODO:change to w/frame
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = NO; //TODO:test to see if still need to implement methods to prevent selection
}

-(void)addStudent {
    NSString *studentEmail = self.enterField.text;
    [_collaborators addObject: studentEmail];
    
}

-(NSArray *)collaborators {
    return (NSArray *)_collaborators;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collaborators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollabCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CollabCell"];
    }
    
    cell.textLabel.text = self.collaborators[indexPath.row];
    return cell;
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
