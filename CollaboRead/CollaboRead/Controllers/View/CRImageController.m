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

@interface CRImageController ()

/*!
 @brief View controller to handle tool selection
 */
@property (nonatomic, readwrite, strong) CRToolPanelViewController *toolPanelViewController;
/*!
 @brief Displays patient info for the case
 */
@property (nonatomic, readwrite, strong) UITextView *patientInfo;
/*!
 @brief Level of scroll from last change in position
 */
@property (nonatomic, assign) NSInteger pastScroll;
/*!
 Toggles the display of the scans menu
 */
- (void)toggleScansMenu;
/*!
 Toggles the display of the patient info
 */
- (void)togglePatientInfo;
/*!
 Handles touch to scroll through slices
 @param gestureRecognizer
 Gesture recognizer that triggered the method
 */
- (void)scrollTouch:(UIPanGestureRecognizer *)gestureRecognizer;
@end

@implementation CRImageController

-(void)loadView {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = self.caseChosen.name;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    UIView *view = [[UIView alloc] initWithFrame:CR_LANDSCAPE_FRAME];
    view.backgroundColor = [UIColor blackColor];
    
    self.scrollBar = [[iCarousel alloc] init];
    self.scrollBar.dataSource = self;
    self.scrollBar.delegate = self;
    self.scrollBar.type = iCarouselTypeLinear;
    self.scrollBar.frame = CGRectMake(CR_TOP_BAR_HEIGHT, 0, kCR_CAROUSEL_CELL_HEIGHT, kCAROUSEL_HEIGHT + 20);
    self.scrollBar.backgroundColor = [UIColor blackColor];
    self.scrollBar.clipsToBounds = YES;
    
    self.imageMarkup = [[CRCaseImageMarkupViewController alloc] init];
    self.imageMarkup.maxFrame = CGRectMake(kToolPanelTableViewWidth, CR_TOP_BAR_HEIGHT, (CR_LANDSCAPE_FRAME).size.width - 2 * kToolPanelTableViewWidth, (CR_LANDSCAPE_FRAME).size.height - (CR_TOP_BAR_HEIGHT) - kCR_CAROUSEL_CELL_HEIGHT - 20);
    self.imageMarkup.caseChosen = self.caseChosen;
    self.imageMarkup.selectedTool = kCR_PANEL_TOOL_PEN; //In loadview because needed for loading imageMarkup view
    [self addChildViewController:self.imageMarkup];
    
    //Create tool panel and it's accompanying views
    self.toolPanelViewController = [[CRToolPanelViewController alloc] init];
    self.toolPanelViewController.delegate = self;
    [self addChildViewController:self.toolPanelViewController];
    
    CGRect frame = CR_LANDSCAPE_FRAME; //Frame adjusted based on iOS 7 or 8
    
    self.scansMenuController = [[CRScansMenuViewController alloc] initWithScans:self.caseChosen.scans];
    self.scansMenuController.delegate = self;
    [self.scansMenuController setViewFrame:CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0) animated:NO completion:nil];
    self.scansMenuController.highlights = [[NSArray alloc] init];
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
    
    [view addSubview:self.imageMarkup.view];
    [view addSubview:self.scrollBar];
    [view addSubview:self.patientInfo];
    [view addSubview:self.scansMenuController.view];
    [view addSubview:self.toolPanelViewController.view];
    
    UIPanGestureRecognizer *scrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTouch:)];
    scrollGesture.minimumNumberOfTouches = 2;
    scrollGesture.maximumNumberOfTouches = 2;
    [view addGestureRecognizer:scrollGesture];
    
    self.view = view;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Make sure image is correct
    [self.imageMarkup swapImageToScan:self.scanIndex Slice:self.sliceIndex];
    self.scrollBar.frame = CGRectMake(self.imageMarkup.view.frame.origin.x, self.imageMarkup.view.frame.origin.y + self.imageMarkup.view.frame.size.height, self.imageMarkup.view.frame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
    self.scrollBar.bounds = self.scrollBar.frame;
}

//Custom setter to handle image change
-(void) setSliceIndex:(NSUInteger)sliceIndex {
    _sliceIndex = sliceIndex;
    if(self.view) {
        [self.scrollBar reloadData];
        [self.imageMarkup swapImageToScan:self.scanIndex Slice:self.sliceIndex];
        self.scrollBar.frame = CGRectMake(self.imageMarkup.view.frame.origin.x, self.imageMarkup.view.frame.origin.y + self.imageMarkup.view.frame.size.height, self.imageMarkup.view.frame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
        self.scrollBar.bounds = self.scrollBar.frame;
    }
}

//Custom setter to handle image change
-(void) setScanIndex:(NSUInteger)scanIndex {
    _scanIndex = scanIndex;
    self.sliceIndex = 0;
    
}

//Custom setter to handle image change
-(void) setCaseChosen:(CRCase *)caseChosen {
    _caseChosen = caseChosen;
    if (self.view) {
        self.imageMarkup.caseChosen = self.caseChosen;
        self.scansMenuController.highlights = [[NSArray alloc] init];
        self.scansMenuController.scans = self.caseChosen.scans;
    }
    [caseChosen loadImagesAsync];//Load images as efficiently as possible
    self.scanIndex = 0;
}

#pragma mark - Gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{ //Prevent swiping to last view controller
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
    //Change location of scrollbar, it handles change of image
}

#pragma mark - View Toggle Methods

-(void)toggleScansMenu
{
    CGRect frame = CR_LANDSCAPE_FRAME;
    if (self.scansMenuController.view.frame.size.width == 0) {
        CGFloat size = self.toolPanelViewController.view.frame.size.height * 0.75;
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - size - self.scrollBar.frame.size.height, size, size);
        [self.scansMenuController setViewFrame: frame animated:YES completion:nil];
    }
    else {
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0);
        [self.scansMenuController setViewFrame: frame animated:YES completion:nil];
    }
}
- (void)togglePatientInfo {
    CGRect frame = CR_LANDSCAPE_FRAME;
    if (self.patientInfo.frame.size.width == 0) {
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - (kPATIENT_INFO_DIMENSION) - self.scrollBar.frame.size.height, kPATIENT_INFO_DIMENSION, kPATIENT_INFO_DIMENSION);
        [UIView animateWithDuration:0.25 animations:^{
            [self.patientInfo setFrame: frame];
        }];
    } else {
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - self.scrollBar.frame.size.height, 0, 0);
        [UIView animateWithDuration:0.25 animations:^{
            [self.patientInfo setFrame: frame];
        }];
    }
}

#pragma mark - CRToolPanelViewController Delegate Methods
//Notify image markup to perform appropriate action for each tool, or perform view changes as needed
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
//Perform view changes when views should no longer be visible
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
{ //Change image if needed
    [self.caseChosen.scans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((CRScan *)obj).scanID isEqualToString:scanId]) {
            if (idx != self.scanIndex) {
                self.scanIndex = idx;
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
    self.sliceIndex = carousel.currentItemIndex; //Changing item index changes image shown
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return 0.0;
    }
    return value;
}


@end
