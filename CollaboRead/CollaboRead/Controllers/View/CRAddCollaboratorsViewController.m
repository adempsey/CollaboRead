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
#import "CRUserSuggestionTableViewController.h"

#define ELEMENT_PADDING 10
#define ELEMENT_HEIGHT 30
#define BUTTON_WIDTH 100
#define kVIEW_WIDTH 230.0

@interface CRAddCollaboratorsViewController ()

/*!
 @brief Table view to display selected collaborators
 */
@property (nonatomic, strong) UITableView *tableView;
/*!
 @brief Text field to enter group name
 */
@property (nonatomic, strong) UITextField *groupName;
/*!
 @brief Text field to search for another group member name
 */
@property (nonatomic, strong) UITextField *enterField;
/*!
 @brief View controller for view to present autocompletion suggestions for entered names in table form
 */
@property (nonatomic, strong) CRUserSuggestionTableViewController *userSuggester;


@end

@implementation CRAddCollaboratorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.width = kVIEW_WIDTH;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = CR_COLOR_PRIMARY;
    self.view.layer.borderColor = (CR_COLOR_TINT).CGColor;
    self.view.layer.borderWidth = 3;
    
    
    self.groupName = [[UITextField alloc] initWithFrame:CGRectMake(ELEMENT_PADDING, ELEMENT_PADDING, self.view.frame.size.width - 2 * ELEMENT_PADDING, ELEMENT_HEIGHT)];
    self.groupName.borderStyle = UITextBorderStyleRoundedRect;
    self.groupName.placeholder = @"Group Name";
    self.groupName.text = [CRCollaboratorList sharedInstance].groupName;
    self.groupName.returnKeyType = UIReturnKeyDone;
    self.groupName.keyboardAppearance = UIKeyboardAppearanceDark;
    self.groupName.delegate = self;
    [self.view addSubview:self.groupName];
    
    self.enterField = [[UITextField alloc] initWithFrame:CGRectMake(ELEMENT_PADDING, ELEMENT_PADDING + self.groupName.frame.origin.y + self.groupName.frame.size.height, self.view.frame.size.width - 2 * ELEMENT_PADDING, ELEMENT_HEIGHT)];
    self.enterField.borderStyle = UITextBorderStyleRoundedRect;
    self.enterField.placeholder = @"Search for Collaborator";
    self.enterField.returnKeyType = UIReturnKeyDone;
    self.enterField.keyboardType = UIKeyboardTypeEmailAddress;
    self.enterField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.enterField.clearsOnBeginEditing = YES;
    self.enterField.delegate = self;
    [self.view addSubview:self.enterField];
    
    self.userSuggester = [[CRUserSuggestionTableViewController alloc] init];
    self.userSuggester.view.frame = CGRectMake(ELEMENT_PADDING, self.enterField.frame.origin.y + ELEMENT_HEIGHT, self.enterField.frame.size.width, self.enterField.frame.size.width);
    self.userSuggester.delegate = self;
    self.userSuggester.view.hidden = YES;
    [self addChildViewController:self.userSuggester];
    
    self.tableView = [[UITableView alloc] init];//TODO:change to w/frame
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[[UIImageView alloc] initWithFrame:CGRectZero]]; //eliminate empty rows
    self.tableView.frame = CGRectMake(0, ELEMENT_PADDING + self.enterField.frame.origin.y + self.enterField.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (2 * ELEMENT_HEIGHT + 4 * ELEMENT_PADDING));
    self.tableView.backgroundColor = CR_COLOR_PRIMARY;
    self.tableView.userInteractionEnabled = YES;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero]; //ios 7
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero]; //ios 8
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CollabCell"];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.userSuggester.view];
    
}

//Editting the text field needs to change the prefix for autocompletion
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.enterField]) {
        self.userSuggester.prefix = [self.enterField.text stringByReplacingCharactersInRange:range withString:string];
    }
    return YES;
}

//Beginning to edit the name entry field should clear it to match with cleared autocompletion suggestions
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.enterField]) {
        self.userSuggester.prefix = @"";
        self.userSuggester.view.hidden = NO;
    }
}

//End of editting may update visibility of suggestion view or have an updated group name to handle
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.enterField]) {
        self.userSuggester.view.hidden = YES;
    } else {
        [CRCollaboratorList sharedInstance].groupName = ![self.groupName.text isEqualToString:@""] ? self.groupName.text : nil;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source
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
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [[CRCollaboratorList sharedInstance] collaboratorNameForIndex:indexPath.row];
    cell.detailTextLabel.text = [[CRCollaboratorList sharedInstance] collaboratorEmailForIndex:indexPath.row];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero]; //ios 8
    }
    return cell;
}

//Cannot delete self from collaborators
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? NO : YES;
}

//Can delete other collaborators
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[CRCollaboratorList sharedInstance] removeCollaboratorAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

//What to do when a collaborator has been selected from autocompletion view
-(void)suggestionSelected:(CRUser *)user {
    [[CRCollaboratorList sharedInstance] addCollaborator:user];
    [self.tableView reloadData];
    [self textFieldShouldReturn:self.enterField];
}

@end
