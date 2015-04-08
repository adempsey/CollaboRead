//
//  CRStudentAnswerTableViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/3/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRSideBarViewController.h"

/*!
 @class CRStudentAnswerTableViewController
 @discussion A side bar to display and adjust visibility of answer submissions
 */
@interface CRStudentAnswerTableViewController : CRSideBarViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, weak) id delegate;

/*!
 @brief A list of the CRAnswers submitted to the case
 */
@property (nonatomic, readwrite, strong) NSArray *answerList;

/*!
 @brief Scan to list answers for
 */
@property (nonatomic, readwrite, strong) NSString *scanId;

/*!
 Initializes controller with an answerList
 
 @param answerList
 Array of CRAnswers to set answerList property to
 @param scanId
 String to set scanId property to
 */
- (instancetype)initWithAnswerList:(NSArray*)answerList andScanID:(NSString *)scanId;

@end

@protocol CRStudentAnswerTableViewDelegate <NSObject>

/*!
 Called when the selection of answers in the table is updated
 @param studentAnswerTableViewController
 View controller whose selection was updated
 @param answers
 Currently selected answers
 */
@required
- (void)studentAnswerTableView:(CRStudentAnswerTableViewController*)studentAnswerTableView didChangeAnswerSelection:(NSArray*)answers;

@end
