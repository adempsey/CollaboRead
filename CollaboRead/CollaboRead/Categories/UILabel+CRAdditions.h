//
//  UILabel+CRAdditions.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/8/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CRAdditions)

/*!
 Changes label's text with an animated transition
 @param text
 Text to change to
 */
- (void)animateTransitionToText:(NSString*)text;
/*!
 Changes visibility of label with a fade effect
 @param visibile
 Whether label should be visible or hidden
 */
- (void)fadeToVisibility:(BOOL)visibile;
/*!
 Changes visibility of label with a fade effect
 @param visibile
 Whether label should be visible or hidden
 @param block
 Actions to perform after fade is complete
 */
- (void)fadeToVisibility:(BOOL)visibile completion:(void (^)())block;

@end
