//
//  CRAnswerPoint.m
//  CollaboRead
//
//  Holds a point in a line of an answer drawing.
//
//  Created by Hannah Clark on 10/11/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswerPoint.h"

@implementation CRAnswerPoint

-(id)initFromJSONDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSLog(@"x = %@", dict[@"x"]);
        self.coordinate = CGPointMake([dict[@"x"] floatValue], [dict[@"y"] floatValue]);
        self.isEndPoint = [dict[@"isEnd"] boolValue];
    }
    return self;
}

//Make a point with coordinate and endpoint boolean
-(id)initWithPoint:(CGPoint)point end:(BOOL)end{
    self = [super init];
    if (self) {
        self.coordinate = point;
        self.isEndPoint = end;
    }
    return self;
}

//Checks value equality of point and a passed object
-(BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CRAnswerPoint class]] &&
            ((CRAnswerPoint *)object).coordinate.x == self.coordinate.x &&
            ((CRAnswerPoint *)object).coordinate.y == self.coordinate.y;
}

//Checks if an object is a CRAnswerPoint within a given range of another
-(BOOL)isInTouchRange:(id)object
{
    return [object isKindOfClass:[CRAnswerPoint class]] &&
    ((CRAnswerPoint *)object).coordinate.x <= self.coordinate.x + 10 &&
    ((CRAnswerPoint *)object).coordinate.x >= self.coordinate.x - 10 &&
    ((CRAnswerPoint *)object).coordinate.y <= self.coordinate.y + 10 &&
     ((CRAnswerPoint *)object).coordinate.y >= self.coordinate.y - 10;
}

//Make a deep copy
-(id)copyWithZone:(NSZone *)zone
{
    return [[CRAnswerPoint alloc] initWithPoint:self.coordinate end:self.isEndPoint];
}

-(NSDictionary *)jsonDictFromPoint
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:self.coordinate.x], @"x", [NSNumber numberWithFloat:self.coordinate.y], @"y", [NSNumber numberWithFloat: self.isEndPoint], @"isEnd",nil];
}

@end
