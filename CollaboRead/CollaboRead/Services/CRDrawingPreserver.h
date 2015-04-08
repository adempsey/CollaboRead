//
//  CRDrawingPreserver.h
//  CollaboRead
//
//  Preserves drawings on images during a single session
//  REPLACE WITH BETTER VERSION LATER
//
//  Created by Hannah Clark on 11/14/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRUndoStack.h"

/*!
 @class CRDrawingPreserver
 
 @discussion Preserves undo stack for each case over a user session
 */
@interface CRDrawingPreserver : NSObject

+ (CRDrawingPreserver *) sharedInstance;

/*!
 Retrieves undo stack for a given case
 
 @param caseID
 Case to retrieve undo stack for
 
 @return
 Undo stack of the case, nil if no undo stack was saved for that case
 */
- (CRUndoStack *)drawingHistoryForCaseID:(NSString *)caseID;

/*!
 Sets or updats undo stack for a given case
 
 @param caseID
 Case to retrieve undo stack for
 
 @param drawing
 Undo stack of the case
 */
- (void)setDrawingHistory:(CRUndoStack *)drawing forCaseID:(NSString *)caseID;

/*!
 Clears all undo stacks, to be called upon user logout
 */
- (void)clearDrawings;

@end
