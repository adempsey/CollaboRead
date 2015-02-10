//
//  CRImageScroller.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRImageScrollBar.h"

@implementation CRImageScrollBar


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // DrawHighlights
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect slider = CGRectMake(self.scrollOffset, 0, self.frame.size.width/self.partitions, self.frame.size.height);
    CGContextAddRect(context, slider);
    CGContextStrokePath(context);
    
}


@end
