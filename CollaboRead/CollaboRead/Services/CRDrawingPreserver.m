//
//  CRDrawingPreserver.m
//  CollaboRead
//
//  Created by Hannah Clark on 11/14/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRDrawingPreserver.h"


@interface CRDrawingPreserver ()

/*!
 @brief Holds undo stacks mapped to case ids
 */
@property (nonatomic, strong) NSMutableDictionary *drawings;
@end

@implementation CRDrawingPreserver

+ (CRDrawingPreserver *) sharedInstance
{
    static CRDrawingPreserver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.drawings = [[NSMutableDictionary alloc] init];
    });
    return sharedInstance;
}

- (CRUndoStack *)drawingHistoryForCaseID:(NSString *)caseID
{
    return [self.drawings objectForKey:caseID];
}

- (void)setDrawingHistory:(CRUndoStack *)drawing forCaseID:(NSString *)caseID
{
    [self.drawings setObject:drawing forKey:caseID];
}

- (void)clearDrawings
{
	self.drawings = nil;
	self.drawings = [[NSMutableDictionary alloc] init];
}

@end
