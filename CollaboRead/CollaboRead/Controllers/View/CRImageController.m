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
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 50
#define BUTTON_SPACE 20
#define ZOOM_FRACTION 0.1
#define kMAX_ZOOM 3
#define kMIN_ZOOM 1

@interface CRImageController ()
{
    CRAnswerPoint *lastPoint;
}
@property (nonatomic, strong) UIImageView *drawView;
@property (nonatomic, strong) UIImageView *caseImage;

@property (nonatomic, assign) CGFloat lastZoom;
@property (nonatomic, assign) CGPoint lastTranslation;
@property (nonatomic, assign) CGFloat pastScroll;

@property (nonatomic, readwrite, strong) CRToolPanelViewController *toolPanelViewController;
@property (nonatomic, readwrite, assign) NSUInteger selectedTool;

@property (nonatomic, readwrite, strong) UIButton *toggleButton;

@property (nonatomic, strong) UIPinchGestureRecognizer *zoomGesture;

-(void)toggleScansMenu;
-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
-(void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
-(void)removePointFromAnswer:(CRAnswerPoint *)pt;
-(void)swapImage;

-(void)drawTouch:(UIPanGestureRecognizer *)gestureRecognizer;
-(void)zoomTouch:(UIPinchGestureRecognizer *)gestureRecognizer;
-(void)panTouch:(UIPanGestureRecognizer *)gestureRecognizer;
-(void)scrollTouch:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@implementation CRImageController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		self.selectedTool = kCR_PANEL_TOOL_PEN;
		self.toggleButton = [[UIButton alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = self.caseChosen.name;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.scanIndex = 0;
    self.sliceIndex = 0;

    self.scrollBar = [[iCarousel alloc] init];
    self.scrollBar.dataSource = self;
    self.scrollBar.delegate = self;
    self.scrollBar.type = iCarouselTypeLinear;
    self.scrollBar.frame = CGRectMake(CR_TOP_BAR_HEIGHT, 0, kCR_CAROUSEL_CELL_HEIGHT, kCR_CAROUSEL_CELL_HEIGHT + 10);
    self.scrollBar.backgroundColor = CR_COLOR_PRIMARY;
    self.scrollBar.clipsToBounds = YES;
    
    //Initialize image views
	[self loadAndScaleImage:((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).image];

	// Invisible now so that the image fades in once the view appears
	self.caseImage.alpha = 0.0;
    self.drawView.alpha = 0.0;
    
    self.lecturerID = self.user.userID;//TODO:this seems wrong or unnecessary
    
    //Add image views
	[self.limView addSubview:self.caseImage];
	[self.limView addSubview:self.drawView];
    self.limView.clipsToBounds = YES;
    [self.view addSubview:self.limView];
    [self.view addSubview:self.scrollBar];
    
    self.currZoom = kMIN_ZOOM;
    self.lastZoom = self.currZoom;
    self.lastTranslation = CGPointMake(0, 0);
    
    
    //Create tool panel and it's accompanying views
	self.toolPanelViewController = [[CRToolPanelViewController alloc] init];
	self.toolPanelViewController.delegate = self;

    CGRect frame = CR_LANDSCAPE_FRAME; //Frame adjusted based on iOS 7 or 8
	self.toggleButton.frame = CGRectMake((kToolPanelTableViewWidth - 60.0)/2,
										 frame.size.height - 60.0 - 10.0,
										 60.0,
										 60.0);
	UIImage *toggleButtonImage = [UIImage imageNamed:@"CRToolPanelToggle.png"];
	[self.toggleButton setImage:toggleButtonImage forState:UIControlStateNormal];
	[self.toggleButton addTarget:self action:@selector(toggleToolPanel) forControlEvents:UIControlEventTouchUpInside];
    
    self.scansMenuController = [[CRScansMenuViewController alloc] initWithScans:self.caseChosen.scans];
    self.scansMenuController.delegate = self;
    self.scansMenuController.highlights = [[NSArray alloc] init];
    [self.scansMenuController setViewFrame:CGRectMake(kToolPanelTableViewWidth, frame.size.height - kButtonDimension, 0, 0)];
    self.scansMenuController.view.hidden = YES;
    
    [self.view addSubview:self.scansMenuController.view];
    [self.view addSubview:self.toolPanelViewController.view];
    [self.view addSubview:self.toggleButton];
    
    
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
    //Set up current drawing
    self.lineRedComp = 255;
    self.lineBlueComp = 0;
    self.lineGreenComp = 0;
    CRScan *scan = self.caseChosen.scans[self.scanIndex];
    self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack layerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID]];
    [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    lastPoint = nil;
    
    //Set up Gesture Recognizers
    UIPanGestureRecognizer *drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawTouch:)];
    drawGesture.minimumNumberOfTouches = 1;
    drawGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:drawGesture];
    
    self.zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomTouch:)];
    self.zoomGesture.delegate = self;
    [self.view addGestureRecognizer:self.zoomGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTouch:)];
    panGesture.minimumNumberOfTouches = 3;
    panGesture.maximumNumberOfTouches = 3;
    [self.view addGestureRecognizer:panGesture];
    
    UIPanGestureRecognizer *scrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTouch:)];
    scrollGesture.minimumNumberOfTouches = 2;
    scrollGesture.maximumNumberOfTouches = 2;
    [self.view addGestureRecognizer:scrollGesture];
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	[UIView animateWithDuration:0.25 animations:^{
		self.caseImage.alpha = 1.0;
        self.drawView.alpha = 1.0;
	}];
}

- (void)toggleToolPanel {
	CGFloat buttonAlpha = self.toolPanelViewController.toolPanelIsVisible ? 0.5: 1.0;
	[self.toolPanelViewController toggleToolPanel];

	[UIView animateWithDuration:0.25 animations:^{
		self.toggleButton.alpha = buttonAlpha;
	}];
}

#pragma mark - Zoom Methods
-(void) zoomOut {
    [UIView animateWithDuration:0.25 animations:^{
        self.drawView.frame = CGRectMake(0, 0, self.limFrame.size.width, self.limFrame.size.height);
        self.caseImage.frame = CGRectMake(0, 0, self.limFrame.size.width, self.limFrame.size.height);
    } completion:^(BOOL finished) {
        self.lastTranslation = CGPointMake(0, 0);
        self.currZoom = kMIN_ZOOM;
        self.lastZoom = kMIN_ZOOM;
        self.imgFrame = self.limFrame;
    }];
}

-(void)zoomImageToScale:(CGFloat)scale {
    self.currZoom = scale;
    CGRect currFrame = self.drawView.frame;
    if (self.currZoom > kMAX_ZOOM) {
        self.currZoom = kMAX_ZOOM;
    }
    else if (self.currZoom < kMIN_ZOOM) {
        self.currZoom = kMIN_ZOOM;
    }
    
    CGFloat newWidth = self.limFrame.size.width*self.currZoom;
    CGFloat newHeight = self.limFrame.size.height*self.currZoom;
    
    self.lastTranslation = CGPointMake(self.lastTranslation.x * newWidth / currFrame.size.width, self.lastTranslation.y * newHeight / currFrame.size.height);
    
    CGFloat moveLeft = (self.limFrame.size.width - newWidth)/2 + self.lastTranslation.x;
    CGFloat moveUp = (self.limFrame.size.height - newHeight)/2 + self.lastTranslation.y * newHeight / currFrame.size.height;
    
    
    
    if (self.limFrame.size.width > moveLeft + newWidth) {
        moveLeft = self.limFrame.size.width - newWidth;
    } else if (moveLeft > 0) {
        moveLeft = 0;
    }
    if (self.limFrame.size.height > moveUp + newHeight) {
        moveUp = self.limFrame.size.height - newHeight;
    } else if (moveUp > 0) {
        moveUp = 0;
    }
    CGRect newFrame = CGRectMake(moveLeft, moveUp, newWidth, newHeight);
    self.caseImage.frame = newFrame;
    self.drawView.frame = newFrame;
    self.imgFrame = newFrame;
    self.lastTranslation = CGPointMake(moveLeft - (self.limFrame.size.width - newWidth)/2, moveUp - (self.limFrame.size.height - newHeight)/2);
}

-(void)panZoom:(CGPoint)translation {
    CGRect origFrame = self.imgFrame;
    CGFloat origX = (self.limFrame.size.width - origFrame.size.width)/2;
    CGFloat origY = (self.limFrame.size.height - origFrame.size.height)/2;
    CGFloat newX = origX + translation.x;
    CGFloat newY = origY + translation.y;
    if (newX > 0 || newX + origFrame.size.width < self.limView.frame.size.width) {
        newX = origFrame.origin.x;
    }
    if (newY > 0 || newY + origFrame.size.height < self.limView.frame.size.height) {
        newY = origFrame.origin.y;
    }
    CGRect newFrame = CGRectMake(newX, newY, origFrame.size.width, origFrame.size.height);
    self.caseImage.frame = newFrame;
    self.drawView.frame = newFrame;
    self.imgFrame = newFrame;
}

#pragma mark - Tool Methods
//Pops from answer stack and redraws previous answer
-(void)undoEdit {
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
-(void)clearDrawing {
    self.drawView.image = [[UIImage alloc] init];
    self.drawView.frame = self.caseImage.frame;
}

#pragma mark - Drawing Methods
-(void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b {

    //Make region drawable
    UIGraphicsBeginImageContext(self.imgFrame.size);//Drawing is same size as underlying image
    if (abs((int)(self.drawView.image.size.width - self.drawView.frame.size.width)) > 0 && self.drawView.image.size.width != 0) {
        [self.drawView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)];//Using drawInRect necessary here because image is being scaled to view but is not always same size if have zoomed before drawing.
    } else {
        [self.drawView.image drawAtPoint:CGPointMake(0, 0)];//Using drawInRect blurs previous lines for currently unknown reason
    }
    
    //Set up to draw lines
    //Could use drawLineFrom:to:, but is much slower than displaying in one go
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0 * self.currZoom);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), r, g, b, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    for (int i = 1; i < [ans count]; i++) {
        CRAnswerPoint *beg = ans[i - 1];
        if (!beg.isEndPoint) {
            CRAnswerPoint *fin = [ans objectAtIndex:i];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x * self.currZoom, beg.coordinate.y * self.currZoom);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x * self.currZoom, fin.coordinate.y * self.currZoom);
        }
    }
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
    //Make region drawable
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw in size of image
    if (abs((int)(self.drawView.image.size.width - self.drawView.frame.size.width)) > 0 && self.drawView.image.size.width != 0) {
        [self.drawView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)];//Using drawInRect necessary here because image is being scaled to view but is not always same size if have zoomed before drawing.
    } else {
        [self.drawView.image drawAtPoint:CGPointMake(0, 0)];//Using drawInRect blurs previous lines for currently unknown reason
    }
    
    //Set up to draw line
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0 * self.currZoom);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.lineRedComp, self.lineGreenComp, self.lineBlueComp, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x * self.currZoom, beg.coordinate.y * self.currZoom);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x * self.currZoom, fin.coordinate.y * self.currZoom);
    
    
    //Add line to image and draw
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

-(void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
    //Make region drawable
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw in size of image
    if (abs((int)(self.drawView.image.size.width - self.drawView.frame.size.width)) > 0 && self.drawView.image.size.width != 0) {
        [self.drawView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)];//Using drawInRect necessary here because image is being scaled to view but is not always same size if have zoomed before drawing.
    } else {
        [self.drawView.image drawAtPoint:CGPointMake(0, 0)];//Using drawInRect blurs previous lines for currently unknown reason
    }

    //Set up to draw line
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 20.0 * self.currZoom);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x * self.currZoom, beg.coordinate.y * self.currZoom);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x * self.currZoom, fin.coordinate.y * self.currZoom);
    
    
    //Add line to image and draw
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

//Remove all points within erase range from answer array, setting endpoints appropriately
-(void)removePointFromAnswer:(CRAnswerPoint *)pt {
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


#pragma mark - Image Loading Methods
-(void)swapImage {
    [self zoomOut];
    CRScan *scan = self.caseChosen.scans[self.scanIndex];
    [self loadAndScaleImage:((CRSlice *)((CRScan *) scan).slices[self.sliceIndex]).image];
    self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack layerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID]];
    [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
}

//Loads the image to be drawn over into the image view and scales it to fit the screen.
//Necessary while this all is done programmatically, use "Mode: Aspect Fit" instead setting up with
//storyboard
-(void)loadAndScaleImage:(UIImage *)img {
    if (!self.caseImage) {
        self.caseImage = [[UIImageView alloc] init];
        self.drawView = [[UIImageView alloc] init];
        self.limView = [[UIView alloc] init];
    }
    self.caseImage.image = img;
    CGRect newFrame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    //Determine boundaries based on iOS version
    CGFloat topBarHeight = CR_TOP_BAR_HEIGHT + kCR_CAROUSEL_CELL_HEIGHT + 20;
    CGFloat sideBar = kToolPanelTableViewWidth;
    CGRect viewFrame = CR_LANDSCAPE_FRAME;
    
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
        newFrame.size.width != viewFrame.size.width - sideBar * 2) {
        
        double scale = (viewFrame.size.height - topBarHeight)/newFrame.size.height;
        //Determine whether having image expand to sides will cut off top and bottom. If it does, expand to top and bottom. If it doesn't expanding to top and bottom would have either caused the sides to be cut off or it fits the screen exactly and it doesn't matter which to use as scale.
        //Each case expands and centers image appropriately
        if (newFrame.size.width * scale > viewFrame.size.width - sideBar * 2) {
            scale = (viewFrame.size.width - sideBar * 2)/newFrame.size.width;
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = (viewFrame.size.height - topBarHeight - newFrame.size.height)/2 + topBarHeight;
            newFrame.origin.x = sideBar;
        }
        else {
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = topBarHeight;
            newFrame.origin.x = (viewFrame.size.width - sideBar * 2 - newFrame.size.width)/2 + sideBar;
        }
    }
    self.limFrame = newFrame;
    self.imgFrame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    self.scrollBar.frame= CGRectMake(newFrame.origin.x, CR_TOP_BAR_HEIGHT, newFrame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
    self.scrollBar.bounds = self.scrollBar.frame;
    [self.caseImage setFrame:self.imgFrame];
    [self clearDrawing];
    [self.limView setFrame:self.limFrame];
}

#pragma mark - Gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO;
    } else if (gestureRecognizer == self.zoomGesture && gestureRecognizer.numberOfTouches > 2) {
        return NO;
    }
    return YES;
}
-(void)drawTouch:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (CGRectContainsPoint(self.limView.bounds, [gestureRecognizer locationInView:self.limView])) {
        CGPoint touchPt = [gestureRecognizer locationInView:self.drawView];
        if (self.selectedTool == kCR_PANEL_TOOL_PEN && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: CGPointMake(touchPt.x / self.currZoom, touchPt.y / self.currZoom) end:NO];
            [self drawLineFrom:lastPoint to:currentPoint];
            [self.currentDrawing addObject:currentPoint];
            lastPoint = currentPoint;
        }
        else if (self.selectedTool == kCR_PANEL_TOOL_PEN)
        {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:CGPointMake(touchPt.x / self.currZoom, touchPt.y / self.currZoom) end:NO];
            [self.currentDrawing addObject:lastPoint];
        }
        
        else if (self.selectedTool == kCR_PANEL_TOOL_ERASER && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: CGPointMake(touchPt.x / self.currZoom, touchPt.y / self.currZoom) end:NO];
            [self eraseLineFrom:lastPoint to:currentPoint];
            [self removePointFromAnswer:currentPoint];
            lastPoint = currentPoint;
        }
        else if (self.selectedTool == kCR_PANEL_TOOL_ERASER) {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:CGPointMake(touchPt.x / self.currZoom, touchPt.y / self.currZoom) end:NO];
            [self removePointFromAnswer:lastPoint];
        }
    }
    else {
        if (lastPoint != nil) {
            lastPoint.isEndPoint = YES;
            lastPoint = nil;
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        lastPoint.isEndPoint = YES;
        CRScan *scan = self.caseChosen.scans[self.scanIndex];
        [self.undoStack addLayer:self.currentDrawing forSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID];
        self.currentDrawing = [[NSMutableArray alloc] initWithArray:self.currentDrawing copyItems:YES];
        lastPoint = nil;
    }
}

-(void)zoomTouch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPt = [gestureRecognizer locationInView:self.limView];
    if (CGRectContainsPoint(self.limView.bounds, touchPt)) {
        [self zoomImageToScale: self.lastZoom + (gestureRecognizer.scale - 1)];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.lastZoom = self.currZoom;
    }
}

-(void)panTouch:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPt = [gestureRecognizer locationInView:self.limView];
    if (CGRectContainsPoint(self.limView.bounds, touchPt)) {
        CGPoint translation =[gestureRecognizer translationInView:self.limView];
        [self panZoom:CGPointMake(translation.x + self.lastTranslation.x, translation.y + self.lastTranslation.y)];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        CGRect frame = self.drawView.frame;
        CGFloat x = frame.origin.x - (self.limView.frame.size.width - frame.size.width)/2;
        CGFloat y = frame.origin.y - (self.limView.frame.size.height - frame.size.height)/2;
        self.lastTranslation = CGPointMake(x, y);
    }
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


-(void)toggleScansMenu
{
    CGRect frame = CR_LANDSCAPE_FRAME;
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
            [self.undoStack addLayer:[[NSArray alloc] init] forSlice: ((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).sliceID ofScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID];
            self.currentDrawing = [[NSMutableArray alloc] init];
			[self clearDrawing];
            [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseChosen.caseID];
            break;
        case kCR_PANEL_TOOL_SCANS:
            [self toggleScansMenu];
            self.selectedTool = tool;
        default:
            break;
	}
}

-(void)toolPanelViewController:(CRToolPanelViewController *)toolPanelViewController didDeselectTool:(NSInteger)tool
{
    if (tool == kCR_PANEL_TOOL_SCANS) {
        [self toggleScansMenu];
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
                self.scrollBar.frame= CGRectMake(self.limFrame.origin.x, CR_TOP_BAR_HEIGHT, self.limFrame.size.width, kCR_CAROUSEL_CELL_HEIGHT + 20);
                self.scrollBar.bounds = self.scrollBar.frame;
                [self swapImage];
            }
            *stop = true;
        }
    }];
}

#pragma mark - iCarousel Data Source Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
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
    [self swapImage];
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return 0.0;
    }
    return value;
}


@end
