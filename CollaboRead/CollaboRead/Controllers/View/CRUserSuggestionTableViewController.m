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

@property (nonatomic, strong) NSArray *suggestionList;
@property (nonatomic, strong) NSArray *users;


@end

@implementation CRUserSuggestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.suggestionList = [[NSArray alloc] init];
    self.prefix = @"";
    [[CRAPIClientService sharedInstance] retrieveUsersWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            self.users = users;
        }
    }];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SuggestionCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUsers:(NSArray *)users {
    _users = users;
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [names addObject:((CRUser *)obj).name];
    }];
    [[CRUserAutoCompletionService sharedInstance] insertList:names];
}

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
