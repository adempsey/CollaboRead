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

@interface CRDrawingPreserver : NSObject

+(CRDrawingPreserver *) sharedInstance;

//Gives the undoStack for image if found or nil otherwise
-(CRUndoStack *)drawingHistoryForCaseID:(NSString *)caseID;

//Adds or updates drawing history for a case
-(void)setDrawingHistory:(CRUndoStack *)drawing forCaseID:(NSString *)caseID;

@end
