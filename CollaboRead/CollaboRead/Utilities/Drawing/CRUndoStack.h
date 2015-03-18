//
//  CRUndoStack.h
//  CollaboRead
//
//  A representation of an "undo stack" for the case, where a level of drawings are
//  represented as an array of CRAnswerPoints
//
//  Created by Hannah Clark on 1/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRAnswer.h"

/*!
 @class CRUndoStack
 
 @discussion A representation of an "undo stack" for the case, where a level of drawings are represented as an array of CRAnswerPoints
 */
@interface CRUndoStack : NSObject

/*!
 Initializes CRAnswerLine object with data from an already submitted answer
 
 @param answer
 The CRAnswer whose data should be converted into an undostack
 */
-(instancetype)initWithAnswer:(CRAnswer *)answer;

/*!
 Adds a new drawing to the top of the stack for a specified image in the case
 
 @param layer
 Array of CRAnswerPoint objects of the drawing layer to add
 @param sliceID
 Corresponding slice's ID number
 @param scanID
 Corresponding scan's ID number
 */
-(void)addLayer:(NSArray *)layer forSlice:(NSString *)sliceID ofScan:(NSString *)scanID;
/*!
 Permanently removes a drawing layer from the top of the stack for a specified image in the case
 
 @param sliceID
 Corresponding slice's ID number
 @param scanID
 Corresponding scan's ID number
 
 @return
 Array of CRAnswerPoint objects that is now on the top of the stack
 */
-(NSArray *)removeLayerForSlice:(NSString *)sliceID ofScan:(NSString *)scanID; //Removes highest array on the stack for the given scan and slice, returns the new highest array
/*!
 Gets the drawing on the top of the stack for a specified image in the case
 
 @param sliceID
 Corresponding slice's ID number
 @param scanID
 Corresponding scan's ID number
 @return
 Array of CRAnswerPoint objects that is on the top of the stack
 */
-(NSArray *)layerForSlice:(NSString *)sliceID ofScan:(NSString *)scanID;

/*!
 Returns a CRAnswer from the drawings on top of the stack, the provided owners, and given group
 
 @param owners
 Owners of the created answer
 @param group
 Group name for the owners of the answer
 
 @return
 CRAnswer whose owners are owners, answerName is group, and answer lines are constructed from the top of the undo stack for each image.
 */
-(CRAnswer *)answersFromStackForOwners:(NSArray *)owners inGroup:(NSString *)group;

@end
