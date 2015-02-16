//
//  CRSideBarViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/12/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRSideBarViewController.h"
#import "CRViewSizeMacros.h"
#import "CRColors.h"

#define kSIDE_BAR_ORIGIN_X_SHOWN ((self.side == CR_SIDE_BAR_SIDE_LEFT) ? (CR_LANDSCAPE_FRAME).origin.x : (CR_LANDSCAPE_FRAME).size.width - self.width)
#define kSIDE_BAR_ORIGIN_X_HIDDEN ((self.side == CR_SIDE_BAR_SIDE_LEFT) ? ((CR_LANDSCAPE_FRAME).origin.x - self.width) : (CR_LANDSCAPE_FRAME).size.width)
#define kSIDE_BAR_DEFAULT_WIDTH 200.0

#define kSIDE_BAR_BACKGROUND_VIEW_FRAME CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

#define kSIDE_BAR_SLIDE_ANIMATION_LENGTH 0.25

@interface CRSideBarViewController ()

@property (nonatomic, readwrite, strong) UIView *backgroundView;

@end

@implementation CRSideBarViewController

- (instancetype)init
{
	if (self = [super init]) {
		self.width = kSIDE_BAR_DEFAULT_WIDTH;
		self.side = CR_SIDE_BAR_SIDE_LEFT;
		self.visible = YES;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor clearColor];

	[self resetFrame];

	self.backgroundView = [[UIView alloc] initWithFrame:kSIDE_BAR_BACKGROUND_VIEW_FRAME];
	self.backgroundView.backgroundColor = CR_COLOR_PRIMARY;
	self.backgroundView.alpha = 0.9;
	[self.view addSubview:self.backgroundView];
}

- (void)resetFrame
{
	CGRect screenBounds = CR_LANDSCAPE_FRAME;
	CGFloat viewOriginY = CR_TOP_BAR_HEIGHT;
	
	self.view.frame = CGRectMake(self.visible ? kSIDE_BAR_ORIGIN_X_SHOWN : kSIDE_BAR_ORIGIN_X_HIDDEN,
								 viewOriginY,
								 self.width,
								 screenBounds.size.height - viewOriginY);
	
	self.backgroundView.frame = kSIDE_BAR_BACKGROUND_VIEW_FRAME;
}

- (void)setSide:(NSUInteger)side
{
	_side = side;
	[self resetFrame];
}

- (void)setWidth:(CGFloat)width
{
	_width = width;
	[self resetFrame];
}

- (void)setVisible:(BOOL)visible
{
	_visible = visible;
	CGRect frame = self.view.frame;
	CGFloat originXDestination = self.visible ? kSIDE_BAR_ORIGIN_X_SHOWN : kSIDE_BAR_ORIGIN_X_HIDDEN;
	frame.origin.x = originXDestination;
	self.view.frame = frame;
}

- (void)setToggleButton:(id)toggleButton
{
	_toggleButton = toggleButton;
	
	if ([toggleButton isKindOfClass:[UIButton class]]) {
		[_toggleButton addTarget:self action:@selector(toggleAnimated) forControlEvents:UIControlEventTouchUpInside];
		
	} else if ([toggleButton isKindOfClass:[UIBarButtonItem class]]) {
		UIBarButtonItem *barButtonItem = toggleButton;
		[barButtonItem setTarget:self];
		[barButtonItem setAction:@selector(toggleAnimated)];
		_toggleButton = barButtonItem;
	}
}

- (void)toggleAnimated
{
	CGRect frame = self.view.frame;
	CGFloat originXDestination = self.visible ? kSIDE_BAR_ORIGIN_X_HIDDEN : kSIDE_BAR_ORIGIN_X_SHOWN;
	frame.origin.x = originXDestination;

	[UIView animateWithDuration:kSIDE_BAR_SLIDE_ANIMATION_LENGTH animations:^{
		self.view.frame = frame;
	} completion:^(BOOL finished) {
		self.visible = !self.visible;
	}];
}

@end
