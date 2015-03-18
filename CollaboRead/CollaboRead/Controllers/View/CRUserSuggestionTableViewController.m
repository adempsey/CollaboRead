//
//  CRUserSuggestionTableViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 3/17/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRUserSuggestionTableViewController.h"
#import "CRUserAutoCompletionService.h"
#import "CRAPIClientService.h"

@interface CRUserSuggestionTableViewController ()

/*!
 @brief List of suggested names as strings
 */
@property (nonatomic, strong) NSArray *suggestionList;
/*!
 @brief CRUsers available to suggest as autocompletions
 */
@property (nonatomic, strong) NSArray *users;


@end

@implementation CRUserSuggestionTableViewController

- (void)loadView {
    [super loadView];
    super.tableView.backgroundColor = [UIColor whiteColor];
    [super.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SuggestionCell"];
    self.tableView = super.tableView;
    self.view = super.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.suggestionList = [[NSArray alloc] init];
    self.prefix = @"";
    [[CRAPIClientService sharedInstance] retrieveUsersWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            self.users = users;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//Setting available users also adjusts names available for autocompletions in the user autocompletion service
- (void) setUsers:(NSArray *)users {
    _users = users;
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [names addObject:((CRUser *)obj).name];
    }];
    [[CRUserAutoCompletionService sharedInstance] insertList:names];
}

//Setting prefix should change list of names suggested
- (void)setPrefix:(NSString *)prefix {
    self.suggestionList = [[CRUserAutoCompletionService sharedInstance] itemsWithPrefix:prefix];
    _prefix = prefix;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggestionList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuggestionCell"];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = self.suggestionList[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = self.suggestionList[indexPath.row];
    [self.users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((CRUser *)obj).name.lowercaseString isEqualToString: name]) {
            [self.delegate suggestionSelected:obj];
            *stop = YES;
        }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
