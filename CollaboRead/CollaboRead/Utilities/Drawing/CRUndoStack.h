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

@interface CRUndoStack : NSObject


-(instancetype)initWithAnswer:(CRAnswer *)answer;
-(void)addLayer:(NSArray *)layer forSlice:(NSString *)sliceID ofScan:(NSString *)scanID;
-(NSArray *)removeLayerForSlice:(NSString *)sliceID ofScan:(NSString *)scanID; //Removes highest array on the stack for the given scan and slice, returns the new highest array
-(NSArray *)layerForSlice:(NSString *)sliceID ofScan:(NSString *)scanID;
-(CRAnswer *)answersFromStackForOwners:(NSArray *)owners;

@end
