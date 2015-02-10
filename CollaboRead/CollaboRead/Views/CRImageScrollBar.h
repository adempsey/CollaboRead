//
//  CRImageScroller.h
//  CollaboRead
//
//  Created by Hannah Clark on 2/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRImageScrollBar : UIView
@property (nonatomic, assign) CGFloat scrollOffset;
@property (nonatomic, assign) NSUInteger partitions;
@property (nonatomic, strong) NSArray *highlights;
@end
