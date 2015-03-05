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
#import "CRUser.h"
#import "CRToolPanelViewController.h"
#import "CRScansMenuViewController.h"
#import "CRUndoStack.h"
#import "iCarousel.h"

@interface CRImageController : UIViewController <CRToolPanelViewControllerDelegate, CRScansMenuViewControllerDelegate, iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate>

//The following define drawing color used by user
@property (nonatomic, assign) CGFloat lineRedComp;
@property (nonatomic, assign) CGFloat lineBlueComp;
@property (nonatomic, assign) CGFloat lineGreenComp;

@property (nonatomic, assign) CGRect imgFrame;
@property (nonatomic, assign) CGRect limFrame;
@property (nonatomic, assign) CGFloat currZoom;

@property (nonatomic, strong) CRCase *caseChosen;//Case information

@property (nonatomic, assign) NSUInteger scanIndex;
@property (nonatomic, assign) NSUInteger sliceIndex;
@property (nonatomic, strong) NSString *caseGroup;//Identifier for submitting/getting case information
@property(nonatomic, strong) CRUndoStack *undoStack;//All past iterations of a drawing on the image
@property (nonatomic, strong) NSMutableArray *currentDrawing;
@property (nonatomic, strong) NSString *lecturerID;//Lecturer who own's case
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *patientInfo;

@property (nonatomic, strong) UIView *limView;
@property (nonatomic, strong) CRScansMenuViewController *scansMenuController;
@property (nonatomic, strong) iCarousel *scrollBar;


//Loads the image to be drawn over into the view and scales it to fit the screen.
-(void)loadAndScaleImage:(UIImage *)img;

//Draws answer indicated by array in specified color (Floats on scale of 0 - 255)
-(void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b;

//Clears all drawings from screen without affecting any stored information
-(void)clearDrawing;

-(void)zoomOut;
-(void)zoomImageToScale:(CGFloat)scale;
-(void)panZoom:(CGPoint)translation;

@end

