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

@interface CRImageController : UIViewController <CRToolPanelViewControllerDelegate>

//The following define drawing color used by user
@property (nonatomic, assign) CGFloat lineRedComp;
@property (nonatomic, assign) CGFloat lineBlueComp;
@property (nonatomic, assign) CGFloat lineGreenComp;

@property (nonatomic, strong) CRUser *user;
@property (nonatomic, strong) CRCase *caseChosen;//Case information
@property (nonatomic, strong) NSString *caseId;//Identifier for submitting/getting answers
@property (nonatomic, strong) NSString *caseGroup;//Identifier for submitting/getting case information
@property(nonatomic, strong) NSMutableArray *undoStack;//All past iterations of a drawing on the image
@property (nonatomic, strong) NSArray *allUsers; //Used for LecturerImageViewController subclass
@property (nonatomic, strong) NSString *lecturerID;//Lecturer who own's case
@property (nonatomic, strong) NSIndexPath *indexPath;//

//Loads the image to be drawn over into the view and scales it to fit the screen.
-(void)loadAndScaleImage:(UIImage *)img;

//Draws answer indicated by array in specified color (Floats on scale of 0 - 255)
-(void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b;

//Clears all drawings from screen without affecting any stored information
-(void)clearDrawing;

@end

