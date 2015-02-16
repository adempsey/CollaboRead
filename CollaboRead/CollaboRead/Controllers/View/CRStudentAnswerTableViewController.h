//
//  CRStudentAnswerTableViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/3/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRSideBarViewController.h"

@interface CRStudentAnswerTableViewController : CRSideBarViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, weak) id delegate;
@property (nonatomic, readwrite, strong) NSArray *students;
@property (nonatomic, readwrite, strong) NSArray *allUsers;

- (instancetype)initWithStudents:(NSArray*)students;

@end

@protocol CRStudentAnswerTableViewDelegate <NSObject>

@required
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController*)studentAnswerTableView didChangeStudentSelection:(NSArray*)selectedStudents;

@end
