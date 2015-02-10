//
//  CRImageScrollerController.h
//  CollaboRead
//
//  Created by Hannah Clark on 2/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRImageScrollBar.h"

@interface CRImageScrollBarController : UIViewController
-(void)setPartitions:(NSUInteger)partitions andHighlights:(NSArray *)highlights;
-(void)setWidth:(CGFloat)width;
@property (nonatomic, strong) CRImageScrollBar *view;
@end

@protocol CRImageScrollerDelegate <NSObject>

@required
-(void)imageScroller:(CRImageScrollBarController *)imageScroller didChangePosition:(NSUInteger)newIndex;
-(void)imageScroller:(CRImageScrollBarController *)imageScroller didStopAtPosition:(NSUInteger)newIndex;
@end