//
//  CRImageController.h
//  CollaboRead
//
//  Allows drawing a path in red over a preloaded image. Image should be loaded using loadAndScaleImage:
//  only.
//
//  Created by Andrew Dempsey on 10/8/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CRCase.h"
#import "CRToolPanelViewController.h"
#import "CRScansMenuViewController.h"
#import "CRUndoStack.h"
#import "iCarousel.h"
#import "CRCaseImageMarkupViewController.h"
#import "CRSliceScrollerViewController.h"

/*!
 @class CRImageController
 
 @discussion View Controller for analysis of cases
 */
@interface CRImageController : UIViewController <CRToolPanelViewControllerDelegate, CRScansMenuViewControllerDelegate, CRSliceScrollerDelegate, UIGestureRecognizerDelegate>

/*!
 @brief Case to display for analysis
 */
@property (nonatomic, strong) CRCase *caseChosen;
/*!
 @brief Index of scan in case currently being viewed
 */
@property (nonatomic, assign) NSUInteger scanIndex;
/*!
 @brief Index of slice in scan currently being viewed
 */
@property (nonatomic, assign) NSUInteger sliceIndex;
/*!
 @brief Identifier of caseSet for use when submitting/retrieving answers
 */
@property (nonatomic, strong) NSString *lectureID;
/*!
 @brief View controller to handle swaping between scans
 */
@property (nonatomic, strong) CRScansMenuViewController *scansMenuController;
/*!
 @brief Scrollbar to handle scrolling through slices
 */
@property (nonatomic, strong) CRSliceScrollerViewController *sliceScroller;
/*!
 @brief Controller to handle displaying and drawing on image
 */
@property (nonatomic, strong) CRCaseImageMarkupViewController *imageMarkup;
/*!
 @brief Lecturer who owns case
 */
@property (nonatomic, strong) NSString *lecturerID;
/*!
 @brief Indexpath to find case within all of the lecturers case sets
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

