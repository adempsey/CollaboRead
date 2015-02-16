//
//  CRSubmitButton.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/7/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CRSubmitButton.h"
#import "CRColors.h"

#define kTITLE_SUBMIT @"Submit Answer"
#define kTITLE_SUCCESS @"\u2713"
#define kTITLE_RESUBMIT @"Resubmit Answer"

#define kTITLE_LABEL_FONT_SIZE 16.0

#define kACTIVITY_INDICATOR_SIZE 50.0
#define kACTIVITY_INDICATOR_FRAME CGRectMake((self.bounds.size.width - kACTIVITY_INDICATOR_SIZE)/2, (self.bounds.size.height - kACTIVITY_INDICATOR_SIZE)/2, kACTIVITY_INDICATOR_SIZE, kACTIVITY_INDICATOR_SIZE)

@interface CRSubmitButton ()

/*!
 @brief The activity indicator should be shown when an answer is in the process
 of being submitted and the result is still pending.
 */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation CRSubmitButton

- (instancetype)init
{
	if (self = [super init]) {
		self.backgroundColor = CR_COLOR_PRIMARY;

		self.titleLabel.font = [UIFont systemFontOfSize:kTITLE_LABEL_FONT_SIZE];

		self.layer.borderWidth = 1.0;
		self.layer.borderColor = [[UIColor whiteColor] CGColor];
		
		self.buttonState = CR_SUBMIT_BUTTON_STATE_SUBMIT;
		
		CGRect activityIndicatorFrame = kACTIVITY_INDICATOR_FRAME;
		self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:activityIndicatorFrame];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.activityIndicator.frame = kACTIVITY_INDICATOR_FRAME;
}

- (void)setButtonState:(NSUInteger)buttonState
{
	switch (buttonState) {
		case CR_SUBMIT_BUTTON_STATE_SUBMIT: {
			self.userInteractionEnabled = YES;
			[self setTitle:kTITLE_SUBMIT forState:UIControlStateNormal];
			_buttonState = buttonState;
			break;
		}
		case CR_SUBMIT_BUTTON_STATE_PENDING: {
			self.userInteractionEnabled = NO;
			[self setTitle:@"" forState:UIControlStateNormal];
			[self.activityIndicator startAnimating];
			[self addSubview:self.activityIndicator];
			_buttonState = buttonState;
			break;
		}
		case CR_SUBMIT_BUTTON_STATE_SUCCESS: {
			self.userInteractionEnabled = NO;
			[self setTitle:kTITLE_SUCCESS forState:UIControlStateNormal];
			[self.activityIndicator removeFromSuperview];
			[self.activityIndicator stopAnimating];
			
			[UIView animateWithDuration:3.0 animations:^{
				// first step is just to delay further animations
				self.titleLabel.alpha = 0.99;
			} completion:^(BOOL finished) {
				// fade out success indicator
				[UIView animateWithDuration:.25 animations:^{
					self.titleLabel.alpha = 0.0;
				} completion:^(BOOL finished) {
					[self setTitle:kTITLE_RESUBMIT forState:UIControlStateNormal];
					// Fade in resubmit label
					[UIView animateWithDuration:0.25 animations:^{
						self.titleLabel.alpha = 1.0;
					} completion:^(BOOL finished) {
						self.buttonState = CR_SUBMIT_BUTTON_STATE_RESUBMIT;
					}];
				}];
			}];
			
			break;
		}
		case CR_SUBMIT_BUTTON_STATE_RESUBMIT: {
			self.userInteractionEnabled = YES;
			[self setTitle:kTITLE_RESUBMIT forState:UIControlStateNormal];
			_buttonState = CR_SUBMIT_BUTTON_STATE_RESUBMIT;
			break;
		}
		default:
			_buttonState = buttonState;
			break;
	}
}

@end
