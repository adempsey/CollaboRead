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

/*!
 @brief A list of the answers submitted to the case to use for displaying the names of groups/students.
 */
@property (nonatomic, readwrite, strong) NSArray *answerList;

- (instancetype)initWithAnswerList:(NSArray*)answerList;

@end

@protocol CRStudentAnswerTableViewDelegate <NSObject>

@required
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController*)studentAnswerTableView didChangeAnswerSelection:(NSArray*)answers;

@end
