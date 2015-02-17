//
//  CRImageScroller.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRImageScrollBar.h"

@implementation CRImageScrollBar

-(instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(180, 180, 500, 50);
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // DrawHighlights
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 5);
    [self.highlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger partition = [((NSNumber *)obj) unsignedIntegerValue];
        CGFloat x = (partition + 0.5) * self.frame.size.width/self.partitions;
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, self.frame.size.height);
    }];
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:.9].CGColor);
    CGRect slider = CGRectMake(self.scrollOffset, 0, self.frame.size.width/self.partitions, self.frame.size.height);
    CGContextFillRect(context, slider);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:.9].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextAddRect(context, slider);
    
    CGContextStrokePath(context);
}

-(void)setScrollOffset:(CGFloat)scrollOffset {
    _scrollOffset = scrollOffset;
    /*if (self.partitions < 2) {
        _scrollOffset = 0;
    } else if (scrollOffset > self.frame.size.width - self.frame.size.width/self.partitions) {
        _scrollOffset = self.frame.size.width/(self.partitions - 1);
    }*/
    [self setNeedsDisplay];
}
-(void)setPartitions:(NSUInteger)partitions {
    _partitions = partitions;
    [self setNeedsDisplay];
}
-(void)setHighlights:(NSArray *)highlights {
    _highlights = highlights;
    [self setNeedsDisplay];
}


@end
