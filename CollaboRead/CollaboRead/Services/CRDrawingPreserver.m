//
//  CRDrawingPreserver.m
//  CollaboRead
//
//  Created by Hannah Clark on 11/14/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRDrawingPreserver.h"

@interface CRDrawingPreserver ()

@property (nonatomic, strong) NSMutableDictionary *drawings;

@end

@implementation CRDrawingPreserver

+(CRDrawingPreserver *) sharedInstance
{
    static CRDrawingPreserver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.drawings = [[NSMutableDictionary alloc] init];
    });
    return sharedInstance;
}

-(NSMutableArray *)drawingHistoryForCaseID:(NSString *)caseID
{
    return [self.drawings objectForKey:caseID];
}

-(void)setDrawingHistory:(NSArray *)drawing forCaseID:(NSString *)caseID
{
    [self.drawings setObject:drawing forKey:caseID];
}

@end
