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
#import "CRAnswerSubmissionService.h"
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 50
#define BUTTON_SPACE 20

@interface CRImageController ()
{
    CRAnswerPoint *lastPoint;
}
@property (nonatomic, strong) UIImageView *drawView;
@property (nonatomic, strong) UIImageView *caseImage;

@property (nonatomic, readwrite, strong) CRToolPanelViewController *toolPanelViewController;
@property (nonatomic, readwrite, assign) NSUInteger selectedTool;

@property (nonatomic, readwrite, strong) UIButton *toggleButton;

@property (nonatomic, strong) CRScansMenuViewController *scansMenuController;

-(void)toggleScansMenu;
-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
-(void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
-(void)removePointFromAnswer:(CRAnswerPoint *)pt;

@end

@implementation CRImageController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		self.selectedTool = kCR_PANEL_TOOL_PEN;
		self.toggleButton = [[UIButton alloc] init];
		[[CRAnswerSubmissionService sharedInstance] initiateConnection];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.scanIndex = 0;
    self.sliceIndex = 0;

	self.navigationItem.title = self.caseChosen.name;
	[self loadAndScaleImage:((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).image];

	// Invisible now so that the image fades in once the view appears
	self.caseImage.alpha = 0.0;
    self.drawView.alpha = 0.0;
    
    self.lecturerID = self.user.userID;
	[self.view addSubview:self.caseImage];
	[self.view addSubview:self.drawView];
    
	self.toolPanelViewController = [[CRToolPanelViewController alloc] init];
	self.toolPanelViewController.delegate = self;

    CGRect frame = LANDSCAPE_FRAME; //Frame adjusted based on iOS 7 or 8
	self.toggleButton.frame = CGRectMake((kToolPanelTableViewWidth - 60.0)/2,
										 frame.size.height - 60.0 - 10.0,
										 60.0,
										 60.0);
	UIImage *toggleButtonImage = [UIImage imageNamed:@"CRToolPanelToggle.png"];
	[self.toggleButton setImage:toggleButtonImage forState:UIControlStateNormal];
	[self.toggleButton addTarget:self action:@selector(toggleToolPanel) forControlEvents:UIControlEventTouchUpInside];
    
    self.scansMenuController = [[CRScansMenuViewController alloc] initWithScans:self.caseChosen.scans];
    self.scansMenuController.delegate = self;
    [self.scansMenuController setViewFrame:CGRectMake(kToolPanelTableViewWidth, frame.size.height - kButtonDimension, 0, 0)];
    self.scansMenuController.view.hidden = YES;
    
    [self.view addSubview:self.scansMenuController.view];
    [self.view addSubview:self.toolPanelViewController.view];
    [self.view addSubview:self.toggleButton];
    
    self.lineRedComp = 255;
    self.lineBlueComp = 0;
    self.lineGreenComp = 0;
    self.patientInfo = self.caseChosen.patientInfo;
    
    //Try to load drawings from previous viewing during session or make new undo stack
    self.undoStack = [[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseChosen.caseID];
    if (!self.undoStack) {
        if ([self.user.type isEqualToString:CR_USER_TYPE_STUDENT]) {
            NSArray *answers = self.caseChosen.answers;
            NSUInteger idx = [answers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [((CRAnswer *)obj).owners indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [(NSString *)obj isEqualToString:self.user.userID];
                }] != NSNotFound;
            }];
            if(idx != NSNotFound) {
				CRAnswer *answer = answers[idx];
                self.undoStack = [[CRUndoStack alloc] initWithAnswer:answer];
            }
        }
        if (!self.undoStack) {
            self.undoStack = [[CRUndoStack alloc] init];
        }
        [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseChosen.caseID];
    }
    CRScan *scan = self.caseChosen.scans[self.scanIndex];
    self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack layerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID]];
    [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    lastPoint = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	[UIView animateWithDuration:0.25 animations:^{
		self.caseImage.alpha = 1.0;
        self.drawView.alpha = 1.0;
	}];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[CRAnswerSubmissionService sharedInstance] disconnect];
}

- (void)toggleToolPanel
{
	CGFloat buttonAlpha = self.toolPanelViewController.toolPanelIsVisible ? 0.5: 1.0;
	[self.toolPanelViewController toggleToolPanel];

	[UIView animateWithDuration:0.25 animations:^{
		self.toggleButton.alpha = buttonAlpha;
	}];
}

#pragma mark - Tool Methods

//Pops from answer stack and redraws previous answer
-(void)undoEdit
{
    CRScan *scan = self.caseChosen.scans[self.scanIndex];
    self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack removeLayerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID] copyItems:YES];
    if (self.currentDrawing.count > 0) {
        [self clearDrawing];
        [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    }
    else {
        [self clearDrawing];
    }
}

//Only clears image, does not affect saved data
-(void)clearDrawing
{
    self.drawView.frame = self.imgFrame;
    self.drawView.image = [[UIImage alloc] init];
}

#pragma mark - Drawing Methods

-(void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b
{

    //Make region drawable
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw only in image
    [self.drawView.image drawAtPoint:CGPointMake(0, 0)];
    
    //Set up to draw lines
    //Could use drawLineFrom:to:, but is much slower than displaying in one go
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), r, g, b, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.coordinate.x, lastPoint.coordinate.y);
    for (int i = 1; i < [ans count]; i++) {
        CRAnswerPoint *beg = ans[i - 1];
        if (!beg.isEndPoint) {
            CRAnswerPoint *fin = [ans objectAtIndex:i];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
        }
    }
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

//Loads the image to be drawn over into the image view and scales it to fit the screen.
//Necessary while this all is done programmatically, use "Mode: Aspect Fit" instead setting up with
//storyboard
-(void)loadAndScaleImage:(UIImage *)img
{
    if (!self.caseImage) {
        self.caseImage = [[UIImageView alloc] init];
        self.drawView = [[UIImageView alloc] init];
    }
    self.caseImage.image = img;
    CGRect newFrame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    //Determine boundaries based on iOS version
    CGFloat topBarHeight = TOP_BAR_HEIGHT;
    CGRect viewFrame = LANDSCAPE_FRAME;
    
    //If image is portrait orientation, make it landscape so it can appear larger on the screen
    if (newFrame.size.height > newFrame.size.width) {
        self.caseImage.image = [[UIImage alloc] initWithCGImage:self.caseImage.image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
        //Rotation doesn't adjust UIImageView's frame, so must be done manually.
        CGFloat temp = newFrame.size.width;
        newFrame.size.width = newFrame.size.height;
        newFrame.size.height = temp;
    }
    
    //If the image doesn't already fit as much as the view as possible
    if (newFrame.size.height != viewFrame.size.height - topBarHeight &&
        newFrame.size.width != viewFrame.size.width) {
        
        double scale = (viewFrame.size.height - topBarHeight)/newFrame.size.height;
        
        //Determine whether having image expand to sides will cut off top and bottom. If it does, expand to top and bottom. If it doesn't expanding to top and bottom would have either caused the sides to be cut off or it fits the screen exactly and it doesn't matter which to use as scale.
        //Each case expands and centers image appropriately
        if (newFrame.size.width * scale > viewFrame.size.width) {
            scale = viewFrame.size.width/newFrame.size.width;
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = (viewFrame.size.height - newFrame.size.height)/2;
            newFrame.origin.x = 0;
        }
        else {
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = topBarHeight;
            newFrame.origin.x = (viewFrame.size.width - newFrame.size.width)/2;
        }
    }
    self.imgFrame = newFrame;
    [self.caseImage setFrame:newFrame];
    [self clearDrawing];
    [self.drawView setNeedsDisplay];
    [self.caseImage setNeedsDisplay];
    [self.view setNeedsDisplay];
}

//Prepares undostack, begins appropriate draw action
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPt = [[touches anyObject] locationInView:self.drawView];
    if (CGRectContainsPoint(self.drawView.bounds, touchPt)) {
        if (self.selectedTool == kCR_PANEL_TOOL_PEN) {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:touchPt end:NO];
            [self.currentDrawing addObject:lastPoint];
        }
    
        else if (self.selectedTool == kCR_PANEL_TOOL_ERASER) {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:touchPt end:NO];
            [self removePointFromAnswer:lastPoint];
        }
    }
}

//Continues appropriate draw action, changing undostack as necessary
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPt = [[touches anyObject] locationInView:self.drawView];
    if (CGRectContainsPoint(self.drawView.bounds, touchPt)) {
        if (self.selectedTool == kCR_PANEL_TOOL_PEN && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
            [self drawLineFrom:lastPoint to:currentPoint];
            [self.currentDrawing addObject:currentPoint];
            lastPoint = currentPoint;
        }
        else if (self.selectedTool == kCR_PANEL_TOOL_PEN)
        {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:touchPt end:NO];
            [self.currentDrawing addObject:lastPoint];
        }
        
        else if (self.selectedTool == kCR_PANEL_TOOL_ERASER && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
            [self eraseLineFrom:lastPoint to:currentPoint];
            [self removePointFromAnswer:currentPoint];
            lastPoint = currentPoint;
        }
        else if (self.selectedTool == kCR_PANEL_TOOL_ERASER) {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:touchPt end:NO];
            [self removePointFromAnswer:lastPoint];
        }
    }
    else {
        if (lastPoint != nil) {
            lastPoint.isEndPoint = YES;
            lastPoint = nil;
        }
    }
}

//Finishes appropriate drawing action, updates record of drawing on image
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPt = [[touches anyObject] locationInView:self.drawView];
    if (CGRectContainsPoint(self.drawView.bounds, touchPt)) {
        if (self.selectedTool == kCR_PANEL_TOOL_PEN && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
            [self drawLineFrom:lastPoint to:currentPoint];
            [self.currentDrawing addObject:currentPoint];
        }
        else if (self.selectedTool == kCR_PANEL_TOOL_ERASER && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
            [self eraseLineFrom:lastPoint to:currentPoint];
            [self removePointFromAnswer:currentPoint];
        }
        CRScan *scan = self.caseChosen.scans[self.scanIndex];
        [self.undoStack addLayer:self.currentDrawing forSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID];
        self.currentDrawing = [[NSMutableArray alloc] initWithArray:self.currentDrawing copyItems:YES];
    }
    lastPoint = nil;
}


-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
    //Make region drawable
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw only in image
    [self.drawView.image drawAtPoint:CGPointMake(0, 0)];//Using drawInRect blurs previous lines for currently unknown reason
    
    //Set up to draw line
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.lineRedComp, self.lineGreenComp, self.lineBlueComp, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
    
    
    //Add line to image and draw
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

-(void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
    //Make region drawable
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw only in image
    [self.drawView.image drawAtPoint:CGPointMake(0, 0)]; //Doesn't use drawInRect to keep consistent with drawing lines and prevent blurring that ocurred for unknown reason
    
    //Set up to draw line
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 20.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
    
    
    //Add line to image and draw
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

//Remove all points within erase range from answer array, setting endpoints appropriately
-(void)removePointFromAnswer:(CRAnswerPoint *)pt
{
    //Find which to remove
    NSIndexSet *toRemove = [self.currentDrawing indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [pt isInTouchRange:obj];
    }];
    //Set endpoints of precending points to points to remove
    [toRemove enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            ((CRAnswerPoint *)[self.currentDrawing objectAtIndex:idx - 1]).isEndPoint = YES;
        }
    }];
    //Remove points
    [self.currentDrawing removeObjectsAtIndexes:toRemove];
}

-(void)toggleScansMenu
{
    CGRect frame = LANDSCAPE_FRAME;
    if (self.scansMenuController.view.hidden) {
        self.scansMenuController.view.hidden = NO;
        CGFloat size = self.toolPanelViewController.view.frame.size.height * 0.75;
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - size - kButtonDimension, size, size);
        [UIView animateWithDuration:0.25 animations:^{
            [self.scansMenuController setViewFrame: frame];
        } completion:^(BOOL finished) {}];
    }
    else {
        frame = CGRectMake(kToolPanelTableViewWidth, frame.size.height - kButtonDimension, 0, 0);
    
        [UIView animateWithDuration:0.25 animations:^{
            [self.scansMenuController setViewFrame: frame];
        } completion:^(BOOL finished) {
            self.scansMenuController.view.hidden = YES;
        }];
    }
}

#pragma mark - CRToolPanelViewController Delegate Methods

- (void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didSelectTool:(NSInteger)tool
{
	switch (tool) {
		case kCR_PANEL_TOOL_PEN:
		case kCR_PANEL_TOOL_ERASER:
			self.selectedTool = tool;
			break;
		case kCR_PANEL_TOOL_UNDO:
			[self undoEdit];
			break;
		case kCR_PANEL_TOOL_CLEAR:
            //CRScan *scan = self.caseChosen.scans[self.scanIndex];
            [self.undoStack addLayer:[[NSArray alloc] init] forSlice: ((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).sliceID ofScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID];
            self.currentDrawing = [[NSMutableArray alloc] init];
			[self clearDrawing];
            [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseChosen.caseID];
            break;
        case kCR_PANEL_TOOL_SCANS:
            [self toggleScansMenu];
            self.selectedTool = tool;
            break;
	}
}

-(void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didDeselectTool:(NSInteger)tool
{
    switch (tool) {
        case kCR_PANEL_TOOL_SCANS:
            [self toggleScansMenu];
            break;
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
                [self loadAndScaleImage:((CRSlice *)((CRScan *) obj).slices[self.sliceIndex]).image];
                CRScan *scan = self.caseChosen.scans[self.scanIndex];
                self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack layerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID]];
                [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
            }
            *stop = true;
        }
    }];
}

@end
