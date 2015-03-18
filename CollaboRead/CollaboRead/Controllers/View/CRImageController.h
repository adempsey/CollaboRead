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

@interface CRImageController : UIViewController <CRToolPanelViewControllerDelegate, CRScansMenuViewControllerDelegate, iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate>


@property (nonatomic, strong) CRCase *caseChosen;//Case information

@property (nonatomic, assign) NSUInteger scanIndex;
@property (nonatomic, assign) NSUInteger sliceIndex;
@property (nonatomic, strong) NSString *caseGroup;//Identifier for submitting/getting case information

@property (nonatomic, strong) CRScansMenuViewController *scansMenuController;
@property (nonatomic, strong) iCarousel *scrollBar;
@property (nonatomic, strong) CRCaseImageMarkupViewController *imageMarkup;

@property (nonatomic, strong) NSString *lecturerID;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

