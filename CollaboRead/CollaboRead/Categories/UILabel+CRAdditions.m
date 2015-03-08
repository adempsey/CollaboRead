//
//  UILabel+CRAdditions.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/8/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "UILabel+CRAdditions.h"

#define kANIMATION_LENGTH .25

@implementation UILabel (CRAdditions)

- (void)animateTransitionToText:(NSString*)text
{
	if (!self.hidden) {
		[self fadeToVisibility:NO completion:^{
			self.text = text;
			[self fadeToVisibility:YES];
		}];
	} else {
		self.text = text;
		[self fadeToVisibility:YES];
	}
}

- (void)fadeToVisibility:(BOOL)visibile
{
	[self fadeToVisibility:visibile completion:nil];
}

- (void)fadeToVisibility:(BOOL)visibile completion:(void (^)())block
{
	if (self.hidden && visibile) {
		self.alpha = 0.0;
		self.hidden = NO;
	}
	[UIView animateWithDuration:kANIMATION_LENGTH animations:^{
		self.alpha = visibile ? 1.0 : 0.0;
	} completion:^(BOOL finished) {
		if (!visibile) {
			self.hidden = YES;
			if (block) {
				block();
			}
		}
	}];
}

@end
