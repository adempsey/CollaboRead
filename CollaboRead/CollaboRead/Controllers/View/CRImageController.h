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

@property (nonatomic, strong) CRUser *user;
@property (nonatomic, strong) CRCase *caseChosen;
@property (nonatomic, strong) NSString *caseId;
@property (nonatomic, strong) NSString *caseGroup;
@property(nonatomic, strong) NSMutableArray *undoStack;


//Loads the image to be drawn over into the view and scales it to fit the screen.
-(void)loadAndScaleImage:(UIImage *)img;

-(void)drawAnswer:(NSArray *)ans;
-(void)clearDrawing;

@end

