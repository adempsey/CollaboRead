//
//  CRAddCollaboratorsViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRAddCollaboratorsViewController.h"
#import "CRColors.h"
#import "CRCollaboratorList.h"
#define ELEMENT_PADDING 10
#define ELEMENT_HEIGHT 30
#define BUTTON_WIDTH 100

@interface CRAddCollaboratorsViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *enterField;
@property (nonatomic, strong) UIButton *validateButton;

@property (nonatomic, readwrite, strong) UIActivityIndicatorView *activityIndicator;

-(void)addStudent;
-(void)validateButtonPressed:(UIButton *)sender;

@end

@implementation CRAddCollaboratorsViewController

-(void)setViewFrame:(CGRect)rect {
    self.view.frame = rect;
    self.tableView.frame = CGRectMake(0, ELEMENT_HEIGHT + 2 * ELEMENT_PADDING, self.view.frame.size.width, self.view.frame.size.height - (2 * ELEMENT_HEIGHT + 4 * ELEMENT_PADDING));
    
    self.enterField.frame = CGRectMake(ELEMENT_PADDING, ELEMENT_PADDING, self.view.frame.size.width - 2 * ELEMENT_PADDING, ELEMENT_HEIGHT);
    
    self.validateButton.frame = CGRectMake((self.view.frame.size.width - BUTTON_WIDTH)/2, self.tableView.frame.origin.y + self.tableView.frame.size.height + ELEMENT_PADDING, (self.view.frame.size.width - BUTTON_WIDTH) / 2, ELEMENT_HEIGHT);
    
    self.activityIndicator.frame = CGRectMake((self.view.frame.size.width - ELEMENT_HEIGHT)/2, self.validateButton.frame.origin.y, ELEMENT_HEIGHT, ELEMENT_HEIGHT);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = CR_COLOR_PRIMARY;
    self.view.layer.borderColor = (CR_COLOR_TINT).CGColor;
    self.view.layer.borderWidth = 3;
    self.tableView = [[UITableView alloc] init];//TODO:change to w/frame
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[[UIImageView alloc] initWithFrame:CGRectZero]]; //eliminate empty rows
    self.tableView.frame = CGRectMake(0, ELEMENT_HEIGHT + 2 * ELEMENT_PADDING, self.view.frame.size.width, self.view.frame.size.height - (2 * ELEMENT_HEIGHT + 4 * ELEMENT_PADDING));
    self.tableView.backgroundColor = CR_COLOR_PRIMARY;
    self.tableView.userInteractionEnabled = YES;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero]; //ios 7
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero]; //ios 8
    }
    [self.view addSubview:self.tableView];
    
    self.enterField = [[UITextField alloc] initWithFrame:CGRectMake(ELEMENT_PADDING, ELEMENT_PADDING, self.view.frame.size.width - 2 * ELEMENT_PADDING, ELEMENT_HEIGHT)];
    self.enterField.borderStyle = UITextBorderStyleRoundedRect;
    //self.enterField.backgroundColor = [UIColor whiteColor];
    self.enterField.placeholder = @"Username";
    self.enterField.returnKeyType = UIReturnKeyDone;
    self.enterField.keyboardType = UIKeyboardTypeEmailAddress;
    self.enterField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.enterField.delegate = self;
    [self.view addSubview:self.enterField];
    
    self.validateButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - BUTTON_WIDTH)/2, self.tableView.frame.origin.y + self.tableView.frame.size.height + ELEMENT_PADDING, (self.view.frame.size.width - BUTTON_WIDTH) / 2, ELEMENT_HEIGHT)];
    [self.validateButton setTitle:@"Validate" forState:UIControlStateNormal];
    [self.validateButton setTitleColor:CR_COLOR_TINT forState:UIControlStateNormal];
    [self.validateButton addTarget:self action:@selector(validateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.validateButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - ELEMENT_HEIGHT)/2, self.validateButton.frame.origin.y, ELEMENT_HEIGHT, ELEMENT_HEIGHT)];
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];
}

-(void)validateButtonPressed:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    self.validateButton.hidden = YES;
    [[CRCollaboratorList sharedInstance] verifyCollaborators:^{
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        self.validateButton.hidden = NO;
        [self.tableView reloadData];
    }];
}

-(void)addStudent {
    NSString *studentEmail = self.enterField.text;
    if (![self.enterField.text isEqualToString: @""]) {
        [[CRCollaboratorList sharedInstance] addCollaborator:studentEmail];
        [self.tableView reloadData];
        self.enterField.text = @"";
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.enterField]) {
        [self addStudent];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[CRCollaboratorList sharedInstance] collaboratorCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollabCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CollabCell"];
    }
    cell.backgroundColor = CR_COLOR_PRIMARY;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [[CRCollaboratorList sharedInstance] collaboratorForIndex:indexPath.row];
    cell.detailTextLabel.text = [[CRCollaboratorList sharedInstance] nameForCollaborator:cell.textLabel.text];
    cell.detailTextLabel.textColor = [cell.detailTextLabel.text isEqualToString:CR_INVALID_COLLABORATOR] ? CR_COLOR_ERROR : [UIColor whiteColor];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero]; //ios 8
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? NO : YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[CRCollaboratorList sharedInstance] removeCollaboratorAtIndex:indexPath.row];
        [tableView reloadData];
    }
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
