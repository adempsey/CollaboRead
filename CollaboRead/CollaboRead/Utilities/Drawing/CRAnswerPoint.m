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
#import "NSDictionary+CRAdditions.h"
#import "CRCaseKeys.h"

#define kXCoordKey @"x"
#define kYCoordKey @"y"
#define kEndKey @"isEnd"

@implementation CRAnswerPoint

-(id)initFromJSONDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.coordinate = CGPointMake([dict[kXCoordKey] floatValue], [dict[kYCoordKey] floatValue]);
        self.isEndPoint = [dict[kEndKey] boolValue];
    }
    return self;
}

-(id)initWithPoint:(CGPoint)point end:(BOOL)end{
    self = [super init];
    if (self) {
        self.coordinate = point;
        self.isEndPoint = end;
    }
    return self;
}

//Equality is defined as points at the same location
-(BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CRAnswerPoint class]] &&
            ((CRAnswerPoint *)object).coordinate.x == self.coordinate.x &&
            ((CRAnswerPoint *)object).coordinate.y == self.coordinate.y;
}

//A 20 px square centered on the point is the "touch range"
-(BOOL)isInTouchRange:(id)object
{
    return [object isKindOfClass:[CRAnswerPoint class]] &&
    ((CRAnswerPoint *)object).coordinate.x <= self.coordinate.x + 10 &&
    ((CRAnswerPoint *)object).coordinate.x >= self.coordinate.x - 10 &&
    ((CRAnswerPoint *)object).coordinate.y <= self.coordinate.y + 10 &&
     ((CRAnswerPoint *)object).coordinate.y >= self.coordinate.y - 10;
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[CRAnswerPoint alloc] initWithPoint:self.coordinate end:self.isEndPoint];
}

-(NSDictionary *)jsonDictFromPoint
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:self.coordinate.x], kXCoordKey, [NSNumber numberWithFloat:self.coordinate.y], kYCoordKey, [NSNumber numberWithFloat: self.isEndPoint], kEndKey,nil];
}

- (NSString*)jsonString
{
	return [self jsonDictFromPoint].jsonString;
}

@end
