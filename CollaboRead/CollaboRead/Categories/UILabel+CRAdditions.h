//
//  UILabel+CRAdditions.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/8/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CRAdditions)

- (void)animateTransitionToText:(NSString*)text;
- (void)fadeToVisibility:(BOOL)visibile;
- (void)fadeToVisibility:(BOOL)visibile completion:(void (^)())block;

@end
