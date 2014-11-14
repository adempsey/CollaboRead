//
//  CRStudentAnswerTableViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/3/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRCase.h"

@interface CRStudentAnswerTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, weak) id delegate;

@property (nonatomic, readwrite, strong) NSArray *students;

@property (nonatomic, readwrite, strong) NSArray *submittedStudents;

@property (nonatomic, readwrite, strong) NSArray *allUsers;

@property (nonatomic, readwrite, strong) NSString *lecturerID;

@property (nonatomic, readwrite, strong) NSIndexPath *indexPath;

- (instancetype)initWithStudents:(NSArray*)students;
- (void)toggleTable;

@end

@protocol CRStudentAnswerTableViewDelegate <NSObject>

@required
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController*)studentAnswerTableView didChangeStudentSelection:(NSArray*)selectedStudents ;


@required
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController*)studentAnswerTableView didRefresh:(CRCase*)refreshedCase ;


@end
