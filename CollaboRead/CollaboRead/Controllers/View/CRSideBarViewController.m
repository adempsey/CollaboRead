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

-(instancetype) init {
    if (self = [super init]) {
        _width = kSIDE_BAR_DEFAULT_WIDTH;
        _side = CR_SIDE_BAR_SIDE_LEFT;
        _visible = YES;
    }
    return self;
}

-(void)loadView {
    //Setters for those properties call reset frame which references the view, so must not be used here
    CGRect screenBounds = CR_LANDSCAPE_FRAME;
    CGFloat viewOriginY = CR_TOP_BAR_HEIGHT;
    CGRect viewFrame = CGRectMake(kSIDE_BAR_ORIGIN_X_SHOWN,
                                  viewOriginY,
                                  self.width,
                                  screenBounds.size.height - viewOriginY);
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    view.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
    self.backgroundView.backgroundColor = CR_COLOR_PRIMARY;
    self.backgroundView.alpha = 0.9;
    [view addSubview:self.backgroundView];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

//View needs to be adjusted after changing frame settings
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
    [self resetFrame];
	if ([self.delegate respondsToSelector:@selector(CRSideBarViewController:didChangeVisibility:)]) {
		[self.delegate CRSideBarViewController:self didChangeVisibility:visible];
	}
}

//Setting the toggle button should set its action to toggle the bar
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
    [UIView animateWithDuration:kSIDE_BAR_SLIDE_ANIMATION_LENGTH animations:^{
		self.visible = !self.visible;
	} completion:nil];
}

@end
