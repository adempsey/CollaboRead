//
//  CRCaseImageMarkupViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 3/18/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

//ODDITY - Image views had to include superview's origin offsets in their own to get correct possition, although it seems that this should not be the case

#import "CRCaseImageMarkupViewController.h"
#import "CRViewSizeMacros.h"
#import "CRToolPanelViewController.h"
#import "CRAnswerPoint.h"
#import "CRAccountService.h"
#import "CRDrawingPreserver.h"
#import "CRSlice.h"
#import "CRScan.h"
#import "CRUserKeys.h"
#import "CRAnswerLine.h"

#define kMAX_ZOOM 3
#define kMIN_ZOOM 1
#define ZOOM_FRACTION 0.1

@interface CRCaseImageMarkupViewController ()
{
    CRAnswerPoint *lastPoint;
}
@property (nonatomic, strong) UIImageView *drawView;
@property (nonatomic, strong) UIImageView *caseImage;
@property (nonatomic, strong) UIImageView *permanentDrawView;

@property (nonatomic, strong) NSMutableArray *currentDrawing;

@property (nonatomic, assign) CGFloat lastZoom;
@property (nonatomic, assign) CGPoint lastTranslation;
@property (nonatomic, assign) CGFloat currZoom;
@property (nonatomic, assign) CGRect imgFrame;

@property (nonatomic, assign) NSUInteger scanIndex;
@property (nonatomic, assign) NSUInteger sliceIndex;

@property (nonatomic, strong) UIPinchGestureRecognizer *zoomGesture;

//Loads the image to be drawn over into the view and scales it to fit the screen.
- (void)loadAndScaleImage:(UIImage *)img;

- (void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
- (void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
- (void)removePointFromAnswer:(CRAnswerPoint *)pt;

- (void)wipeDrawing;

- (void)drawTouch:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)zoomTouch:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)panTouch:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@implementation CRCaseImageMarkupViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    view.clipsToBounds = YES;
    
    self.caseImage = [[UIImageView alloc] init];
    self.drawView = [[UIImageView alloc] init];
    self.permanentDrawView = [[UIImageView alloc] init];
    
    //Add image views
    [view addSubview:self.caseImage];
    [view addSubview:self.drawView];
    [view addSubview:self.permanentDrawView];
    
    //Set up Gesture Recognizers
    UIPanGestureRecognizer *drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawTouch:)];
    drawGesture.minimumNumberOfTouches = 1;
    drawGesture.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:drawGesture];
    
    self.zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomTouch:)];
    self.zoomGesture.delegate = self;
    [view addGestureRecognizer:self.zoomGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTouch:)];
    panGesture.minimumNumberOfTouches = 3;
    panGesture.maximumNumberOfTouches = 3;
    [view addGestureRecognizer:panGesture];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currZoom = kMIN_ZOOM;
    self.lastZoom = self.currZoom;
    self.lastTranslation = CGPointMake(0, 0);
    
    //Set up current drawing
    self.lineRedComp = 255;
    self.lineBlueComp = 0;
    self.lineGreenComp = 0;
    
    lastPoint = nil;
    
    //Try to load drawings from previous viewing during session or make new undo stack
    self.undoStack = [[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseChosen.caseID];
    if (!self.undoStack) {
        if ([[CRAccountService sharedInstance].user.type isEqualToString:CR_USER_TYPE_STUDENT]) {
            NSArray *answers = self.caseChosen.answers;
            NSUInteger idx = [answers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [((CRAnswer *)obj).owners indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [(NSString *)obj isEqualToString:[CRAccountService sharedInstance].user.userID];
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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CRScan *scan = self.caseChosen.scans[self.scanIndex];
    self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack layerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID]];
    [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
}

#pragma mark - Image Loading Methods
-(void)swapImageToScan:(NSUInteger)scanIndex Slice:(NSUInteger)sliceIndex {
    if (self.view) {
        [self zoomOut];
        self.scanIndex = scanIndex;
        self.sliceIndex = sliceIndex;
        CRScan *scan = self.caseChosen.scans[self.scanIndex];
        [self loadAndScaleImage:((CRSlice *)((CRScan *) scan).slices[self.sliceIndex]).image];
        self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack layerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID]];
        [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    }
}

//Loads the image to be drawn over into the image view and scales it to fit the screen.
//Necessary while this all is done programmatically, use "Mode: Aspect Fit" instead setting up with
//storyboard
-(void)loadAndScaleImage:(UIImage *)img {
    self.caseImage.image = img;
    CGRect newFrame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    //If the image doesn't already fit as much as the view as possible
    if (newFrame.size.height != self.maxFrame.size.height &&
        newFrame.size.width != self.maxFrame.size.width) {
        
        double scale = self.maxFrame.size.height/newFrame.size.height;
        //Determine whether having image expand to sides will cut off top and bottom. If it does, expand to top and bottom. If it doesn't expanding to top and bottom would have either caused the sides to be cut off or it fits the screen exactly and it doesn't matter which to use as scale.
        //Each case expands and centers image appropriately
        if (newFrame.size.width * scale > self.maxFrame.size.width) {
            scale = self.maxFrame.size.width/newFrame.size.width;
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = (self.maxFrame.size.height - newFrame.size.height)/2 + self.maxFrame.origin.y;
            newFrame.origin.x = self.maxFrame.origin.x;
        }
        else {
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = self.maxFrame.origin.y;
            newFrame.origin.x = (self.maxFrame.size.width - newFrame.size.width)/2 + self.maxFrame.origin.x;
        }
    }
    self.view.frame = newFrame;
    self.view.bounds = newFrame;
    self.imgFrame = newFrame;//CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    [self.caseImage setFrame:self.imgFrame];
    [self wipeDrawing];
    self.permanentDrawView.image = [[UIImage alloc] init];
    self.permanentDrawView.frame = self.imgFrame;
}

- (void) wipeDrawing {
    self.drawView.image = [[UIImage alloc] init];
    self.drawView.frame = self.caseImage.frame;
}

#pragma mark - Zoom Methods
- (void) zoomOut {
    [UIView animateWithDuration:0.25 animations:^{
        self.drawView.frame = self.view.frame;
        self.caseImage.frame = self.view.frame;
        self.permanentDrawView.frame = self.view.frame;
    } completion:^(BOOL finished) {
        self.lastTranslation = CGPointMake(0, 0);
        self.currZoom = kMIN_ZOOM;
        self.lastZoom = kMIN_ZOOM;
        self.imgFrame = self.view.frame;
    }];
}


- (void)zoomImageToScale:(CGFloat)scale {
    self.currZoom = scale;
    CGRect currFrame = self.drawView.frame;
    if (self.currZoom > kMAX_ZOOM) {
        self.currZoom = kMAX_ZOOM;
    }
    else if (self.currZoom < kMIN_ZOOM) {
        self.currZoom = kMIN_ZOOM;
    }
    
    CGFloat newWidth = self.view.frame.size.width*self.currZoom;
    CGFloat newHeight = self.view.frame.size.height*self.currZoom;
    
    self.lastTranslation = CGPointMake(self.lastTranslation.x * newWidth / currFrame.size.width, self.lastTranslation.y * newHeight / currFrame.size.height);
    
    CGFloat moveLeft = (self.view.frame.size.width - newWidth)/2 + self.lastTranslation.x;
    CGFloat moveUp = (self.view.frame.size.height - newHeight)/2 + self.lastTranslation.y * newHeight / currFrame.size.height;
    
    
    
    if (self.view.frame.size.width > moveLeft + newWidth) {
        moveLeft = self.view.frame.size.width - newWidth;
    } else if (moveLeft > 0) {
        moveLeft = 0;
    }
    if (self.view.frame.size.height > moveUp + newHeight) {
        moveUp = self.view.frame.size.height - newHeight;
    } else if (moveUp > 0) {
        moveUp = 0;
    }
    CGRect newFrame = CGRectMake(moveLeft + self.view.frame.origin.x, moveUp + self.view.frame.origin.y, newWidth, newHeight);
    self.caseImage.frame = newFrame;
    self.drawView.frame = newFrame;
    self.imgFrame = newFrame;
    self.permanentDrawView.frame = newFrame;
    self.lastTranslation = CGPointMake(moveLeft - (self.view.frame.size.width - newWidth)/2, moveUp - (self.view.frame.size.height - newHeight)/2);
}

- (void)panZoom:(CGPoint)translation {
    CGRect origFrame = self.imgFrame;
    CGFloat origX = (self.view.frame.size.width - origFrame.size.width)/2;
    CGFloat origY = (self.view.frame.size.height - origFrame.size.height)/2;
    CGFloat newX = origX + translation.x;
    CGFloat newY = origY + translation.y;
    if (newX > 0 || newX + origFrame.size.width < self.view.frame.size.width) {
        newX = origFrame.origin.x;
    }
    if (newY > 0 || newY + origFrame.size.height < self.view.frame.size.height) {
        newY = origFrame.origin.y;
    }
    CGRect newFrame = CGRectMake(newX, newY, origFrame.size.width, origFrame.size.height);
    self.caseImage.frame = newFrame;
    self.drawView.frame = newFrame;
    self.imgFrame = newFrame;
    self.permanentDrawView.frame = newFrame;
}

#pragma mark - Tool Methods
//Pops from answer stack and redraws previous answer
- (void)undoEdit {
    CRScan *scan = self.caseChosen.scans[self.scanIndex];
    self.currentDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack removeLayerForSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID] copyItems:YES];
    if (self.currentDrawing.count > 0) {
        [self wipeDrawing];
        [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    }
    else {
        [self wipeDrawing];
    }
}

//Only clears image, does not affect saved data
- (void)clearDrawing {
    [self.undoStack addLayer:[[NSArray alloc] init] forSlice: ((CRSlice *)((CRScan *)self.caseChosen.scans[self.scanIndex]).slices[self.sliceIndex]).sliceID ofScan:((CRScan *)self.caseChosen.scans[self.scanIndex]).scanID];
    self.currentDrawing = [[NSMutableArray alloc] init];
    [self wipeDrawing];
    [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseChosen.caseID];
}

#pragma mark - Drawing Methods
- (void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b {
    
    //Make region drawable
    if (!CGRectEqualToRect(self.imgFrame, CGRectZero)) {
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
}

- (void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
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

- (void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
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
- (void)removePointFromAnswer:(CRAnswerPoint *)pt {
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

- (void)drawTouch:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (CGRectContainsPoint(self.view.bounds, [gestureRecognizer locationInView:self.view])) {
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
        if (self.selectedTool == kCR_PANEL_TOOL_POINTER && lastPoint != nil) {
            CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: CGPointMake(touchPt.x / self.currZoom, touchPt.y / self.currZoom) end:NO];
            [self drawLineFrom:lastPoint to:currentPoint];
            lastPoint = currentPoint;
        }
        else if (self.selectedTool == kCR_PANEL_TOOL_POINTER)
        {
            lastPoint = [[CRAnswerPoint alloc] initWithPoint:CGPointMake(touchPt.x / self.currZoom, touchPt.y / self.currZoom) end:NO];
        }
    }
    else {
        if (lastPoint != nil && self.selectedTool != kCR_PANEL_TOOL_POINTER) {
            lastPoint.isEndPoint = YES;
            lastPoint = nil;
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.selectedTool == kCR_PANEL_TOOL_PEN || self.selectedTool == kCR_PANEL_TOOL_ERASER) {
            lastPoint.isEndPoint = YES;
            CRScan *scan = self.caseChosen.scans[self.scanIndex];
            [self.undoStack addLayer:self.currentDrawing forSlice: ((CRSlice *)scan.slices[self.sliceIndex]).sliceID ofScan:scan.scanID];
            self.currentDrawing = [[NSMutableArray alloc] initWithArray:self.currentDrawing copyItems:YES];
            lastPoint = nil;
        } else if (self.selectedTool == kCR_PANEL_TOOL_POINTER) {
            [self wipeDrawing];
            [self drawAnswer:self.currentDrawing inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
            lastPoint = nil;
        }
    }
}

#pragma mark - Gesture methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.zoomGesture && gestureRecognizer.numberOfTouches > 2) {
        return NO;
    }
    return YES;
}

- (void)zoomTouch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPt = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(self.view.bounds, touchPt)) {
        [self zoomImageToScale: self.lastZoom + (gestureRecognizer.scale - 1)];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.lastZoom = self.currZoom;
    }
}

- (void)panTouch:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPt = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(self.view.bounds, touchPt)) {
        CGPoint translation =[gestureRecognizer translationInView:self.view];
        [self panZoom:CGPointMake(translation.x + self.lastTranslation.x, translation.y + self.lastTranslation.y)];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        CGRect frame = self.drawView.frame;
        CGFloat x = frame.origin.x - (self.view.frame.size.width - frame.size.width)/2;
        CGFloat y = frame.origin.y - (self.view.frame.size.height - frame.size.height)/2;
        self.lastTranslation = CGPointMake(x, y);
    }
}

#pragma mark - Permanent Drawings
- (void)drawPermenantAnswers:(NSArray *)answers inColors:(NSArray *)colors {
    UIGraphicsBeginImageContext(self.imgFrame.size);//Draw only in image
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    [answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CRAnswerLine *line = obj;
        for (int i = 1; i < [line.data count]; i++) {
            NSDictionary* color = colors[idx];
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), [color[@"red"] floatValue], [color[@"green"] floatValue], [color[@"blue"] floatValue], 1.0);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
            CRAnswerPoint *beg = [line.data objectAtIndex:i - 1];
            if (!beg.isEndPoint) {
                CRAnswerPoint *fin = [line.data objectAtIndex:i];
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x * self.currZoom, beg.coordinate.y * self.currZoom);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x * self.currZoom, fin.coordinate.y * self.currZoom);
            }
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext());
    }];
    self.permanentDrawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.permanentDrawView setAlpha:1.0];
    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end