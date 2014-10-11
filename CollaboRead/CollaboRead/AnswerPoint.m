//
//  AnswerPoint.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/11/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "AnswerPoint.h"

@implementation AnswerPoint


-(id)initWithPoint:(CGPoint)point end:(BOOL)end{
    self = [super init];
    if (self) {
        self.coordinate = point;
        self.isEndPoint = end;
    }
    return self;
}
@end
