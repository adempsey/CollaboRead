//
//  CRDrawingPreserver.h
//  CollaboRead
//
//  Created by Hannah Clark on 11/14/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRDrawingPreserver : NSObject

+(CRDrawingPreserver *) sharedInstance;

-(NSMutableArray *)drawingHistoryForCaseID:(NSString *)caseID;

-(void)setDrawingHistory:(NSArray *)drawing forCaseID:(NSString *)caseID;

@end
