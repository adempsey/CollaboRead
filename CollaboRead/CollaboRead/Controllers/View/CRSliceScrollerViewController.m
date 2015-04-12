//
//  CRSliceScrollerViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 4/12/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRSliceScrollerViewController.h"
#import "CRViewSizeMacros.h"
#import "CRCarouselCell.h"
#import "CRScan.h"
#import "CRSlice.h"

#define kCAROUSEL_HEIGHT kCR_CAROUSEL_CELL_HEIGHT + 20

@interface CRSliceScrollerViewController ()

@property (nonatomic, readwrite, strong) iCarousel *carousel;
@property (nonatomic, readwrite, assign) NSInteger pastScroll;
@property (nonatomic, readwrite, assign) NSInteger sliceIndex;

@end

@implementation CRSliceScrollerViewController

- (instancetype)init
{
	if (self = [super init]) {
		self.carousel = [[iCarousel alloc] init];
		self.carousel.dataSource = self;
		self.carousel.delegate = self;
		
		self.view = self.carousel;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.carousel.type = iCarouselTypeLinear;
	self.carousel.backgroundColor = [UIColor blackColor];
	self.carousel.clipsToBounds = YES;
}

- (void)setSlices:(NSArray *)slices
{
	_slices = slices;
	[self reloadData];
}

- (void)setHighlights:(NSArray *)highlights
{
	_highlights = highlights;
	[self.carousel reloadData];
}

- (void)reloadData
{
	self.sliceIndex = 0;
	[self.carousel reloadData];
	self.carousel.scrollOffset = 0.0;
}

#pragma mark - UIGestureRecognizer Delegate Methods

- (void)scrollWithGesture:(UIPanGestureRecognizer*)gestureRecognizer
{
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		self.pastScroll = 0;
	}
	NSInteger translation = self.pastScroll - ([gestureRecognizer translationInView:self.view].x);
	[self.carousel scrollByOffset:translation/10 duration:0];
	if(self.carousel.scrollOffset < 0) {
		self.carousel.scrollOffset = 0;
	} else if (self.carousel.scrollOffset >= [self numberOfItemsInCarousel:self.carousel]) {
		self.carousel.scrollOffset = [self numberOfItemsInCarousel:self.carousel] - 1;
	}
	self.pastScroll = [gestureRecognizer translationInView:self.view].x;
	//Change location of scrollbar, it handles change of image
}

#pragma mark - iCarousel Data Source Methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
	return self.slices.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
	CRCarouselCell *cView = (CRCarouselCell *)view;
	if (cView == nil) {
		cView = [[CRCarouselCell alloc] init];
	}
	[cView setImage:((CRSlice*)self.slices[index]).image];
	
	CRSlice *slice = self.slices[index];
	if ([self.highlights containsObject:slice.sliceID]) {
		cView.isHighlighted = YES;
	} else {
		cView.isHighlighted = NO;
	}
	return cView;
}

#pragma mark - iCarousel Delegate Methods

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
	self.sliceIndex = carousel.currentItemIndex; //Changing item index changes image shown
	[self.delegate sliceScroller:self didChangeSelectedIndex:self.sliceIndex];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
	if (option == iCarouselOptionWrap) {
		return 0.0;
	}
	return value;
}

@end
