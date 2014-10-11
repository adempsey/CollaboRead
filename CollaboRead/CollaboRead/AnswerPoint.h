//
//  AnswerPoint.h
//  CollaboRead
//
//  Holds a point in a line of an answer drawing.
//
//  Created by Hannah Clark on 10/11/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnswerPoint : NSObject
@property (nonatomic, assign) CGPoint coordinate;
@property (nonatomic, assign) BOOL isEndPoint;

-(id)initWithPoint:(CGPoint)point end:(BOOL)end;

@end
