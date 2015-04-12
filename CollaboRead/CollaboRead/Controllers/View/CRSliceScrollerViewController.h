//
//  CRSliceScrollerViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 4/12/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface CRSliceScrollerViewController : UIViewController <UIGestureRecognizerDelegate, iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, readwrite, weak) id delegate;
@property (nonatomic, readwrite, strong) NSArray *slices;
@property (nonatomic, readwrite, strong) NSArray *highlights;

- (void)reloadData;
- (void)scrollWithGesture:(UIPanGestureRecognizer*)gestureRecognizer;

@end


@protocol CRSliceScrollerDelegate <NSObject>
@required

- (void)sliceScroller:(CRSliceScrollerViewController*)sliceScroller didChangeSelectedIndex:(NSInteger)index;

@end