//
//  CRCaseImageMarkupViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 3/18/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUndoStack.h"
#import "CRCase.h"

@interface CRCaseImageMarkupViewController : UIViewController <UIGestureRecognizerDelegate>
//The following define drawing color used by user
@property (nonatomic, assign) CGFloat lineRedComp;
@property (nonatomic, assign) CGFloat lineBlueComp;
@property (nonatomic, assign) CGFloat lineGreenComp;

@property (nonatomic, assign) CGRect maxFrame;

@property(nonatomic, strong) CRUndoStack *undoStack;//All past iterations of a drawing on the image


@property(nonatomic, strong) CRCase *caseChosen;

@property(nonatomic, assign) NSUInteger selectedTool;

//Draws answer indicated by array in specified color (Floats on scale of 0 - 255)
- (void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b;

//Clears all drawings from screen without affecting any stored information
- (void)clearDrawing;
- (void)undoEdit;

- (void)drawPermenantAnswers:(NSArray *)answers inColors:(NSArray *)colors;

- (void)zoomOut;
- (void)zoomImageToScale:(CGFloat)scale;
- (void)panZoom:(CGPoint)translation;

- (void)swapImageToScan:(NSUInteger)scanIndex Slice:(NSUInteger)sliceIndex;

@end
