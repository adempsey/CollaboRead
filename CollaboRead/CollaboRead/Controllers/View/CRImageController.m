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
#import "CRAPIClientService.h"
#import "CRViewSizeMacros.h"
#import "CRDrawingPreserver.h"
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
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	//Most likely will be done by a transitioning view
	UIImage *img = self.caseChosen.images[0];
	self.navigationItem.title = self.caseChosen.name;
	[self loadAndScaleImage:img];

	// Invisible now so that the image fades in once the view appears
	self.caseImage.alpha = 0.0;
    self.drawView.alpha = 0.0;
    
    self.lecturerID = self.user.userID;
	[self.view addSubview:self.caseImage];
	[self.view addSubview:self.drawView];
    
	self.toolPanelViewController = [[CRToolPanelViewController alloc] init];
	self.toolPanelViewController.delegate = self;
	[self.view addSubview:self.toolPanelViewController.view];

    CGRect frame = LANDSCAPE_FRAME; //Frame adjusted based on iOS 7 or 8
	self.toggleButton.frame = CGRectMake((kToolPanelTableViewWidth - 60.0)/2,
										 frame.size.height - 60.0 - 10.0,
										 60.0,
										 60.0);
	UIImage *toggleButtonImage = [UIImage imageNamed:@"CRToolPanelToggle.png"];
	[self.toggleButton setImage:toggleButtonImage forState:UIControlStateNormal];
	[self.toggleButton addTarget:self action:@selector(toggleToolPanel) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.toggleButton];
    
    self.lineRedComp = 255;
    self.lineBlueComp = 0;
    self.lineGreenComp = 0;
    self.patientInfo = self.caseChosen.patientInfo;
    
    //Try to load drawings from previous viewing during session or make new undo stack
    self.undoStack = [[CRDrawingPreserver sharedInstance] drawingHistoryForCaseID:self.caseId];
    if (!self.undoStack) {
        self.undoStack = [[NSMutableArray alloc] init];
    }
    else if ([self.undoStack count] > 0)
    {
        [self drawAnswer:self.undoStack[0] inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[UIView animateWithDuration:0.25 animations:^{
		self.caseImage.alpha = 1.0;
        self.drawView.alpha = 1.0;
	}];
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
	if (self.undoStack.count > 1) {
		[self.undoStack removeObjectAtIndex:0];

		self.drawView.image = [[UIImage alloc] init];
		[self drawAnswer: self.undoStack[0] inRed:self.lineRedComp Green:self.lineGreenComp Blue:self.lineBlueComp];
    }
    else if(self.undoStack.count == 1){
        [self.undoStack removeObjectAtIndex:0];
        [self clearDrawing];
    }
}

//Only clears image, does not affect saved data
-(void)clearDrawing
{
    self.drawView.image = [[UIImage alloc] init];
}

#pragma mark - Drawing Methods

-(void)drawAnswer:(NSArray *)ans inRed:(CGFloat)r Green:(CGFloat)g Blue:(CGFloat)b
{

    //Make region drawable
    UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
    [self.drawView.image drawAtPoint:CGPointMake(0, 0)];
    
    //Set up to draw lines
    //Could use drawLineFrom:to:, but is much slower than displaying in one go
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), r, g, b, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.coordinate.x, lastPoint.coordinate.y);
    for (int i = 1; i < [ans count]; i++) {
        CRAnswerPoint *beg = [ans objectAtIndex:i - 1];
        if (!beg.isEndPoint) {
            CRAnswerPoint *fin = [ans objectAtIndex:i];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
            [self drawLineFrom:beg to:fin];
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
    self.caseImage = [[UIImageView alloc] initWithImage:img];
    CGRect newFrame = self.caseImage.frame;
    
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
    
    [self.caseImage setFrame:newFrame];
    self.drawView = [[UIImageView alloc] initWithFrame:newFrame];
}

//Prepares undostack, begins appropriate draw action
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.selectedTool == kCR_PANEL_TOOL_PEN) {
        lastPoint = [[CRAnswerPoint alloc] initWithPoint:[[touches anyObject] locationInView:self.drawView] end:NO];
        NSMutableArray *newDrawing;
        if ([self.undoStack count] > 0) {
            newDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack objectAtIndex:0] copyItems:YES];
        } else {
            newDrawing = [[NSMutableArray alloc] init];
        }
        [newDrawing addObject:lastPoint];
        [self.undoStack insertObject:newDrawing atIndex:0];
    }
    
    else if (self.selectedTool == kCR_PANEL_TOOL_ERASER) {
        lastPoint = [[CRAnswerPoint alloc] initWithPoint:[[touches anyObject] locationInView:self.drawView] end:NO];
        NSMutableArray *newDrawing;
        if ([self.undoStack count] > 0) {
            newDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack objectAtIndex:0] copyItems:YES];
        } else {
            newDrawing = [[NSMutableArray alloc] init];
        }
        [self.undoStack insertObject:newDrawing atIndex:0];
        [self removePointFromAnswer:lastPoint];
    }
}

//Continues appropriate draw action, changing undostack as necessary
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.selectedTool == kCR_PANEL_TOOL_PEN) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
        [self drawLineFrom:lastPoint to:currentPoint];
        [self.undoStack[0] addObject:currentPoint];
        lastPoint = currentPoint;
    }
    
    else if (self.selectedTool == kCR_PANEL_TOOL_ERASER) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
        [self eraseLineFrom:lastPoint to:currentPoint];
        [self removePointFromAnswer:currentPoint];
        lastPoint = currentPoint;
    }
}

//Finishes appropriate drawing action, updates record of drawing on image
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.selectedTool == kCR_PANEL_TOOL_PEN) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
        [self drawLineFrom:lastPoint to:currentPoint];
        [self.undoStack[0] addObject:currentPoint];
    }
    else if (self.selectedTool == kCR_PANEL_TOOL_ERASER) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
        [self eraseLineFrom:lastPoint to:currentPoint];
        [self removePointFromAnswer:currentPoint];
    }
    [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseId];
}


-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
    //Make region drawable
    UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
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
    UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
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
    NSIndexSet *toRemove = [self.undoStack[0] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [pt isInTouchRange:obj];
    }];
    //Set endpoints of precending points to points to remove
    [toRemove enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            ((CRAnswerPoint *)[self.undoStack[0] objectAtIndex:idx - 1]).isEndPoint = YES;
        }
    }];
    //Remove points
    [self.undoStack[0] removeObjectsAtIndexes:toRemove];
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
            [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseId];
			break;
		case kCR_PANEL_TOOL_CLEAR:
            [self.undoStack insertObject:[[NSMutableArray alloc] init] atIndex:0];
			[self clearDrawing];
            [[CRDrawingPreserver sharedInstance] setDrawingHistory:self.undoStack forCaseID:self.caseId];
			break;
	}
}

@end
