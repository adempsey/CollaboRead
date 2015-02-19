//
//  CRUndoStack.m
//  CollaboRead
//
//  Created by Hannah Clark on 1/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRUndoStack.h"
#import "CRAnswer.h"
#import "CRAnswerLine.h"

@interface CRUndoStack ()

@property (nonatomic, strong) NSMutableDictionary *stacks;

@end

@implementation CRUndoStack

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.stacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype) initWithAnswer:(CRAnswer *)answer
{
    self = [super init];
    if (self) {
        self.stacks = [[NSMutableDictionary alloc] init];
        [answer.drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswerLine *line = obj;
            [self addLayer:line.data forSlice:line.sliceID ofScan:line.scanID];
        }];
    }
    return self;
}

-(void)addLayer:(NSArray *)layer forSlice:(NSString *)sliceID ofScan:(NSString *)scanID
{
    if (self.stacks[scanID]) {
        if (self.stacks[scanID][sliceID]) {
            [self.stacks[scanID][sliceID] insertObject:layer atIndex:0];
        }
        else {
            self.stacks[scanID][sliceID] = [[NSMutableArray alloc] initWithObjects:layer, nil];
        }
    }
    else {
        self.stacks[scanID] = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSMutableArray alloc] initWithObjects:layer, nil], sliceID, nil];
    }
}

-(NSArray *)removeLayerForSlice:(NSString *)sliceID ofScan:(NSString *)scanID
{
    if (self.stacks[scanID]) {
        if (self.stacks[scanID][sliceID]) {
            if ([self.stacks[scanID][sliceID] count] > 0) {
                [self.stacks[scanID][sliceID] removeObjectAtIndex:0];
            }
            if ([self.stacks[scanID][sliceID] count] > 0) {
                return self.stacks[scanID][sliceID][0];
            }
        }
    }
    return nil;
}

-(NSArray *)layerForSlice:(NSString *)sliceID ofScan:(NSString *)scanID
{
    if (self.stacks[scanID]) {
        if (self.stacks[scanID][sliceID]) {
            if ([self.stacks[scanID][sliceID] count] > 0) {
                return self.stacks[scanID][sliceID][0];
            }
        }
    }
    return nil;
}

-(CRAnswer *)answersFromStackForOwners:(NSArray *)owners
{
    NSMutableArray *answerLines = [[NSMutableArray alloc] init];
    [self.stacks.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *scan = obj;
        [((NSDictionary *)self.stacks[scan]).allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *slice = obj;
            if([self.stacks[scan][slice] count] > 0) {
                CRAnswerLine *line = [[CRAnswerLine alloc] initWithPoints:self.stacks[scan][slice][0] forSlice:slice ofScan:scan];
                [answerLines addObject:line];
            }
        }];
    }];
    return [[CRAnswer alloc] initWithData:answerLines submissionDate:[NSDate dateWithTimeIntervalSinceNow:0] owners:owners answerID:@"replace_this"];
}

@end
