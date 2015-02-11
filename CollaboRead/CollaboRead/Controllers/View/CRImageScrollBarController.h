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

@property (nonatomic, strong) CRImageScrollBar *view;
@property (nonatomic, weak) id delegate;
@end

@protocol CRImageScrollBarControllerDelegate <NSObject>

@required
-(void)imageScroller:(CRImageScrollBarController *)imageScroller didChangePosition:(NSUInteger)newIndex;
-(void)imageScroller:(CRImageScrollBarController *)imageScroller didStopAtPosition:(NSUInteger)newIndex;
@end