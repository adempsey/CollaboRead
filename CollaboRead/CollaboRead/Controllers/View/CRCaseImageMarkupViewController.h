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

/*!
 @class CRCaseImageMarkupViewController
 
 @discussion View Controller for display and markup of case images
 */
@interface CRCaseImageMarkupViewController : UIViewController <UIGestureRecognizerDelegate>

/*!
 @brief The maximum size and closest origin allowed for the image
 */
@property (nonatomic, assign) CGRect maxFrame;

/*!
 @brief All past iterations of drawings on the images of the case
 */
@property(nonatomic, strong) CRUndoStack *undoStack;

/*!
 @brief Case to show images from
 */
@property(nonatomic, strong) CRCase *caseChosen;

@property (nonatomic, readwrite, strong) NSString *lectureID;

/*!
 @brief Currently active markup tool
 */
@property(nonatomic, assign) NSUInteger selectedTool;

/*!
 Draws answer on the drawing view
 @param ans
 List of CRAnswerPoints making up the answer
 @param r
 Red component of color for drawing
 @param g
 Green component of color for drawing
 @param b
 Blue component of color for drawing
 */
- (void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b;

/*!
 Performs action of clearing drawing and adding an empty layer to the undoStack
 */
- (void)clearDrawing;

/*!
 Revert to previous drawing layer from undoStack
 */
- (void)undoEdit;

/*!
 Draws answers on colors corresponding by index in a view that will not allow editting
 @param answers
 List of CRAnswerLines to draw
 @param colors
 Colors to draw answers in. It is an unchecked runtime error for it to have a different length from answers
 */
- (void)drawPermanentAnswers:(NSArray *)answers inColors:(NSArray *)colors;

/*!
 Completely zooms out current image in an animated manner
 */
- (void)zoomOut;
/*!
 Zooms the image to the specified scale, within minimum and maximum allowable zooms (1x to 3x) without animation delay
 @param scale
 New zoom scale for the image
 */
- (void)zoomImageToScale:(CGFloat)scale;
/*!
 Pans image to a new translation from default zoom origin
 @param translation
 New translation from default zoom origin to pan to
 */
- (void)panZoom:(CGPoint)translation;

/*!
 Swaps the image shown for markup
 @param scanIndex
 Index of scan in current case to find image in
 @param sliceIndex
 Index of slice within specified scan to display image of
 */
- (void)swapImageToScan:(NSUInteger)scanIndex slice:(NSUInteger)sliceIndex;

@end
