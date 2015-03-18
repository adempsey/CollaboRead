//
//  CRImageController.m
//  CollaboRead
//
//  Allows drawing a path in red over a preloaded image. Image should be loaded using loadAndScaleImage:
//  only.
//
//  Created by Andrew Dempsey on 10/8/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRImageController.h"
#import "CRAnswerPoint.h"
#import "CRUser.h"
#import "CRAnswer.h"
#import "CRScan.h"
#import "CRSlice.h"
#import "CRAPIClientService.h"
#import "CRViewSizeMacros.h"
#import "CRDrawingPreserver.h"
#import "CRUserKeys.h"
#import "CRCarouselCell.h"
#import "CRColors.h"
#import "CRAnswerLine.h"
#import "CRAccountService.h"


#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 50
#define BUTTON_SPACE 20
#define kCAROUSEL_HEIGHT kCR_CAROUSEL_CELL_HEIGHT + 20
#define kPATIENT_INFO_DIMENSION (CR_LANDSCAPE_FRAME).size.height/3

//TODO: CASECHOSEN MAY NEED CUSTOM SETTER
@interface CRImageController ()

@property (nonatomic, readwrite, strong) CRToolPanelViewController *toolPanelViewController;
@property (nonatomic, readwrite, strong) UITextView *patientInfo;

@property (nonatomic, assign) NSInteger pastScroll;

@property (nonatomic, readwrite, strong) UIButton *toggleButton;

- (void)toggleScansMenu;
- (void)togglePatientInfo;

- (void)scrollTouch:(UIPanGestureRecognizer *)gestureRecognizer;
@end

@implementation CRImageController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		self.toggleButton = [[UIButton alloc] init];
	}
	return self;
}

-(void)loadView {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = self.caseChosen.name;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    UIView *view = [[UIView alloc] init];
    
    self.scrollBar = [[iCarousel alloc] init];
    self.scrollBar.dataSource = self;
    self.scrollBar.delegate = self;
    self.scrollBar.type = iCarouselTypeLinear;
    self.scrollBar.frame = CGRectMake(CR_TOP_BAR_HEIGHT, 0, kCR_CAROUSEL_CELL_HEIGHT, kCAROUSEL_HEIGHT + 20);
    self.scrollBar.backgroundColor = [UIColor blackColor];
    self.scrollBar.clipsToBounds = YES;
    
    self.imageMarkup = [[CRCaseImageMarkupViewController alloc] init];
    self.imageMarkup.caseChosen = self.caseChosen;
    self.imageMarkup.maxFrame = CGRectMake(kToolPanelTableViewWidth, CR_TOP_BAR_HEIGHT, (CR_LANDSCAPE_FRAME).size.width - 2 * kToolPanelTableViewWidth, (CR_LANDSCAPE_FRAME).size.height - (CR_TOP_BAR_HEIGHT) - kCR_CAROUSEL_CELL_HEIGHT - 20);
    self.imageMarkup.selectedTool = kCR_PANEL_TOOL_PEN;
    [self addChildViewController:self.imageMarkup];
    
    //Create tool panel and it's accompanying views
    self.toolPanelViewController = [[CRToolPanelViewController alloc] init];
    self.toolPanelViewController.delegate = self;
    [self addChildViewController:self.toolPanelViewController];
    
    CGRect frame = CR_LANDSCAPE_FRAME; //Frame adjusted based on iOS 7 or 8
    
    //TODO:confirm that no toggling toolbar is ok
    /*self.toggleButton.frame = CGRectMake((kToolPanelTableViewWidth - 60.0)/2,
     frame.size.height - 60.0 - 10.0,
     60.0,
     60.0);
     UIImage *toggleButtonImage = [UIImage imageNamed:@"CRToolPanelToggle.png"];
     [self.toggleButton setImage:toggleButtonImage forState:UIControlStateNormal];
     [self.toggleButton addTarget:self action:@selector(toggleToolPanel) forControlEvents:UIControlEventTouchUpInside];*/
    
    self.scansMenuController = [[CRScansMenuViewController alloc] initWithScans:self.caseChosen.scans];
    self.scansMenuController.delegate = self;
    self.scansMenuController.highlights = [[NSArray alloc] init];
    [self.scansMenuController setViewFrame:CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0)];
    self.scansMenuController.view.hidden = YES;
    [self addChildViewController:self.scansMenuController];
    
    self.patientInfo = [[UITextView alloc] initWithFrame:CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0)];
    self.patientInfo.text = self.caseChosen.patientInfo;
    self.patientInfo.editable = NO;
    self.patientInfo.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.patientInfo.textColor = [UIColor whiteColor];
    self.patientInfo.font = [self.patientInfo.font fontWithSize:17.0];
    self.patientInfo.backgroundColor = CR_COLOR_PRIMARY;
    self.patientInfo.layer.borderColor = CR_COLOR_TINT.CGColor;
    self.patientInfo.layer.borderWidth = 3.0;
    self.patientInfo.hidden = YES;
    
    [view addSubview:self.imageMarkup.view];
    [view addSubview:self.scrollBar];
    [view addSubview:self.patientInfo];
    [view addSubview:self.scansMenuController.view];
    [view addSubview:self.toolPanelViewController.view];
    //TODO:confirm that no toggling toolbar is ok
    //[self.view addSubview:self.toggleButton];
    
    UIPanGestureRecognizer *scrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTouch:)];
    scrollGesture.minimumNumberOfTouches = 2;
    scrollGesture.maximumNumberOfTouches = 2;
    [view addGestureRecognizer:scrollGesture];
    
    self.view = view;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    //This caused layout issues when strictly in viewWillAppear, so it needs to be here, too
    [self.imageMarkup swapImageToScan:self.scanIndex Slice:self.sliceIndex];
    self.scrollBar.frame = CGRectMake(self.imageMarkup.view.frame.origin.x, self.imageMarkup.view.frame.origin.y + self.imageMarkup.view.frame.size.height, self.imageMarkup.view.frame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
    self.scrollBar.bounds = self.scrollBar.frame;
}

//TODO:confirm that no toggling toolbar is ok
/*- (void)toggleToolPanel {
	CGFloat buttonAlpha = self.toolPanelViewController.toolPanelIsVisible ? 0.5: 1.0;
	[self.toolPanelViewController toggleToolPanel];

	[UIView animateWithDuration:0.25 animations:^{
		self.toggleButton.alpha = buttonAlpha;
	}];
}*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageMarkup swapImageToScan:self.scanIndex Slice:self.sliceIndex];
    self.scrollBar.frame = CGRectMake(self.imageMarkup.view.frame.origin.x, self.imageMarkup.view.frame.origin.y + self.imageMarkup.view.frame.size.height, self.imageMarkup.view.frame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
    self.scrollBar.bounds = self.scrollBar.frame;
}

#pragma mark - Gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO;
    }
    return YES;
}

-(void)scrollTouch:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.pastScroll = 0;
    }
    NSInteger translation = self.pastScroll - ([gestureRecognizer translationInView:self.view].x);
    [self.scrollBar scrollByOffset:translation/10 duration:0];
    self.pastScroll = [gestureRecognizer translationInView:self.view].x;
}

#pragma mark - View Toggle Methods

-(void)toggleScansMenu
{
    CGRect frame = CR_LANDSCAPE_FRAME;
    if (self.scansMenuController.view.hidden) {
        self.scansMenuController.view.hidden = NO;
        CGFloat size = self.toolPanelViewController.view.frame.size.height * 0.75;
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - size - self.scrollBar.frame.size.height, size, size);
        [UIView animateWithDuration:0.25 animations:^{
            [self.scansMenuController setViewFrame: frame];
        } completion:^(BOOL finished) {}];
    }
    else {
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0);
    
        [UIView animateWithDuration:0.25 animations:^{
            [self.scansMenuController setViewFrame: frame];
        } completion:^(BOOL finished) {
            self.scansMenuController.view.hidden = YES;
        }];
    }
}
- (void)togglePatientInfo {
    CGRect frame = CR_LANDSCAPE_FRAME;
    if (self.patientInfo.hidden) {
        self.patientInfo.hidden = NO;
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - (kPATIENT_INFO_DIMENSION) - self.scrollBar.frame.size.height, kPATIENT_INFO_DIMENSION, kPATIENT_INFO_DIMENSION);
        [UIView animateWithDuration:0.25 animations:^{
            [self.patientInfo setFrame: frame];
        } completion:^(BOOL finished) {}];
    } else {
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0);
        [UIView animateWithDuration:0.25 animations:^{
            [self.patientInfo setFrame: frame];
        } completion:^(BOOL finished) {
            self.patientInfo.hidden = YES;
        }];
    }
}

#pragma mark - CRToolPanelViewController Delegate Methods

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
	switch (tool) {
		case kCR_PANEL_TOOL_PEN:
		case kCR_PANEL_TOOL_ERASER:
        case kCR_PANEL_TOOL_POINTER:
			self.imageMarkup.selectedTool = tool;
			break;
		case kCR_PANEL_TOOL_UNDO:
			[self.imageMarkup undoEdit];
			break;
		case kCR_PANEL_TOOL_CLEAR:
			[self.imageMarkup clearDrawing];
            break;
        case kCR_PANEL_TOOL_SCANS:
            [self toggleScansMenu];
            self.imageMarkup.selectedTool = tool;
            break;
        case kCR_PANEL_TOOL_PATIENT_INFO:
            [self togglePatientInfo];
            self.imageMarkup.selectedTool = tool;
            break;
        default:
            break;
	}
}

-(void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didDeselectTool:(NSInteger)tool
{
    switch (tool) {
        case kCR_PANEL_TOOL_SCANS:
            [self toggleScansMenu];
            break;
        case kCR_PANEL_TOOL_PATIENT_INFO:
            [self togglePatientInfo];
        default:
            break;
    }
}

#pragma mark - CRScansMenuViewController Delegate Methods
-(void) scansMenuViewControllerDidSelectScan:(NSString *)scanId
{
    [self.caseChosen.scans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((CRScan *)obj).scanID isEqualToString:scanId]) {
            if (idx != self.scanIndex) {
                self.scanIndex = idx;
                self.sliceIndex = 0;
                [self.scrollBar reloadData];
                [self.imageMarkup swapImageToScan:self.scanIndex Slice:self.sliceIndex];
                self.scrollBar.frame = CGRectMake(self.imageMarkup.view.frame.origin.x, self.imageMarkup.view.frame.origin.y + self.imageMarkup.view.frame.size.height, self.imageMarkup.view.frame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
                self.scrollBar.bounds = self.scrollBar.frame;
            }
            *stop = true;
        }
    }];
}

#pragma mark - iCarousel Data Source Methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return ((CRScan *)self.caseChosen.scans[self.scanIndex]).slices.count;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    CRCarouselCell *cView = (CRCarouselCell *)view;
    if (cView == nil) {
        cView = [[CRCarouselCell alloc] init];
    }
    [cView setImage:((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[index]).image];
    return cView;
}

#pragma mark - iCarousel Delegate Methods

-(void) carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    self.sliceIndex = carousel.currentItemIndex;
    [self.imageMarkup swapImageToScan:self.scanIndex Slice:self.sliceIndex];
    self.scrollBar.frame = CGRectMake(self.imageMarkup.view.frame.origin.x, self.imageMarkup.view.frame.origin.y + self.imageMarkup.view.frame.size.height, self.imageMarkup.view.frame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
    self.scrollBar.bounds = self.scrollBar.frame;
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return 0.0;
    }
    return value;
}


@end
