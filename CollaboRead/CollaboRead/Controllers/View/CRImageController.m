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

#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 50
#define BUTTON_SPACE 20

@interface CRImageController ()
{
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CRAnswerPoint *lastPoint;
}
@property (nonatomic, strong) UIImageView *drawView;
@property (nonatomic, strong) UIImageView *caseImage;
@property (nonatomic, strong) UIButton *penButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *eraseButton;
@property (nonatomic, strong) UIButton *undoButton;
@property(nonatomic, strong) NSMutableArray *undoStack;

-(void)penSelected:(UIButton *)pen;
-(void)clearImage:(UIButton *)clear;
-(void)eraserSelected:(UIButton *)eraser;
-(void)undoEdit:(UIButton *)undo;
-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
-(void)eraseLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin;
-(void)removePointFromAnswer:(CRAnswerPoint *)pt;

@end

@implementation CRImageController

//Enables appropriate touch control
-(void)penSelected:(UIButton *)pen
{
    [pen setSelected: YES];
    [self.eraseButton setSelected:NO];
}

//Clears all drawaings, makes empty answer array so it is undoable.
-(void)clearImage:(UIButton *)clear
{
    self.drawView.image = [[UIImage alloc] init];
    [self.penButton setSelected:NO];
    [self.eraseButton setSelected:NO];
    [self.undoStack insertObject:[[NSMutableArray alloc] init] atIndex:0];
}

//Enables appropriate touch control
-(void)eraserSelected:(UIButton *)eraser
{
    [eraser setSelected:YES];
    [self.penButton setSelected:NO];
    
}

//Pops from answer stack and redraws previous answer
-(void)undoEdit:(UIButton *)undo
{
    [self.penButton setSelected:NO];
    [self.eraseButton setSelected:NO];
    [self.undoStack removeObjectAtIndex:0];
    self.drawView.image = [[UIImage alloc] init];
    
    //Draw last version if present
    if ([self.undoStack count] > 0) {
        NSMutableArray *drawingGuide = [self.undoStack objectAtIndex:0];
        //Make region drawable
        UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
        [self.drawView.image drawInRect: CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)]; //Drawable rect w/in image is 0,0 in image, to w, h of image
        
        //Set up to draw lines
        //Could use drawLineFrom:to:, but is much slower
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.coordinate.x, lastPoint.coordinate.y);
        for (int i = 0; i < [drawingGuide count] - 1; i++) {
            CRAnswerPoint *beg = [drawingGuide objectAtIndex:i];
            if (!beg.isEndPoint) {
                CRAnswerPoint *fin = [drawingGuide objectAtIndex:i + 1];
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
                [self drawLineFrom:beg to:fin];
            }
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.drawView setAlpha:1.0];
    }
    UIGraphicsEndImageContext();
    if ([self.undoStack count] == 0) {
        [self.undoButton setEnabled:NO];
    }
}

//Loads the image to be drawn over into the image view and scales it to fit the screen.
//Necessary while this all is done programmatically, use "Mode: Aspect Fit" instead setting up with
//storyboard
-(void)loadAndScaleImage:(UIImage *)img
{
    self.caseImage = [[UIImageView alloc] initWithImage:img];
    CGRect newFrame = self.caseImage.frame;
    
    //If image is portrait orientation, make it landscape so it can appear larger on the screen
    if (newFrame.size.height > newFrame.size.width) {
        self.caseImage.image = [[UIImage alloc] initWithCGImage:self.caseImage.image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
        //Rotation doesn't adjust UIImageView's frame, so must be done manually.
        CGFloat temp = newFrame.size.width;
        newFrame.size.width = newFrame.size.height;
        newFrame.size.height = temp;
    }
    
    //If the image doesn't already fit as much as the view as possible
    if (newFrame.size.height != self.view.frame.size.height &&
        newFrame.size.width != self.view.frame.size.width) {
        
        double scale = self.view.frame.size.height/newFrame.size.height;
        
        //Determine whether having image expand to sides will cut off top and bottom. If it does, expand to top and bottom. If it doesn't expanding to top and bottom would have either caused the sides to be cut off or it fits the screen exactly and it doesn't matter which to use as scale.
        //Each case expands and centers image appropriately
        if (newFrame.size.width * scale > self.view.frame.size.width) {
            scale = self.view.frame.size.width/newFrame.size.width;
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = (self.view.frame.size.height - newFrame.size.height)/2;
            newFrame.origin.x = 0;
        }
        else {
            newFrame.size.width *= scale;
            newFrame.size.height *= scale;
            newFrame.origin.y = 0;
            newFrame.origin.x = (self.view.frame.size.width - newFrame.size.width)/2;
        }
    }
    
    [self.caseImage setFrame:newFrame];
    self.drawView = [[UIImageView alloc] initWithFrame:self.caseImage.frame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Most likely will be done by a transitioning view
	UIImage *img = self.caseChosen.images[0];
	self.navigationItem.title = self.caseChosen.name;
    [self loadAndScaleImage:img];

    self.undoStack = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.caseImage];
    [self.view addSubview:self.drawView];
    
    
    //Storyboards are getting a little on my nerves, so I'm writing the code for the buttons for now
    self.penButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [self.penButton setFrame:CGRectMake(BUTTON_SPACE, self.view.frame.size.height/2.0 - (2 * BUTTON_HEIGHT + BUTTON_SPACE * 1.5), BUTTON_HEIGHT, BUTTON_WIDTH)];
    [self.penButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.penButton setTitle:@"PEN" forState:UIControlStateNormal];//Change to setting images?
    [self.penButton setTitle:@"PEN" forState:UIControlStateSelected];
    [self.penButton setSelected:YES];
    [self.view addSubview:self.penButton];
    [self.penButton addTarget:self action:@selector(penSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.eraseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [self.eraseButton setFrame:CGRectMake(BUTTON_SPACE, self.view.frame.size.height/2.0 - (BUTTON_HEIGHT + BUTTON_SPACE/2.0), BUTTON_HEIGHT, BUTTON_WIDTH)];
    [self.eraseButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.eraseButton setTitle:@"ERS" forState:UIControlStateNormal];//Change to setting images?
    [self.eraseButton setTitle:@"ERS" forState:UIControlStateSelected];
    [self.view addSubview:self.eraseButton];
    [self.eraseButton addTarget:self action:@selector(eraserSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    self.undoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [self.undoButton setFrame:CGRectMake(BUTTON_SPACE, self.view.frame.size.height/2.0 + BUTTON_SPACE/2.0, BUTTON_HEIGHT, BUTTON_WIDTH)];
    [self.undoButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.undoButton setTitle:@"UNDO" forState:UIControlStateNormal];//Change to setting images?
    [self.undoButton setTitle:@"UNDO" forState:UIControlStateSelected];
    [self.view addSubview:self.undoButton];
    [self.undoButton setEnabled:NO];
    [self.undoButton addTarget:self action:@selector(undoEdit:) forControlEvents:UIControlEventTouchUpInside];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Change to custom
    [self.clearButton setFrame:CGRectMake(BUTTON_SPACE, self.view.frame.size.height/2.0 + BUTTON_SPACE * 1.5 + BUTTON_HEIGHT, BUTTON_HEIGHT, BUTTON_WIDTH)];
    [self.clearButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.clearButton setTitle:@"CLR" forState:UIControlStateNormal];//Change to setting images?
    [self.clearButton setTitle:@"CLR" forState:UIControlStateSelected];
    [self.view addSubview:self.clearButton];
    [self.clearButton addTarget:self action:@selector(clearImage:) forControlEvents:UIControlEventTouchUpInside];
    
    red = 255;
    blue = 0;
    green = 0;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.penButton.selected) {
        lastPoint = [[CRAnswerPoint alloc] initWithPoint:[[touches anyObject] locationInView:self.drawView] end:NO];
        NSMutableArray *newDrawing;
        if ([self.undoStack count] > 0) {
            newDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack objectAtIndex:0] copyItems:YES];
        } else {
            newDrawing = [[NSMutableArray alloc] init];
        }
        [newDrawing addObject:lastPoint];
        [self.undoStack insertObject:newDrawing atIndex:0];
        [self.undoButton setEnabled:YES];
    }
    
    else if (self.eraseButton.selected) {
        lastPoint = [[CRAnswerPoint alloc] initWithPoint:[[touches anyObject] locationInView:self.drawView] end:NO];
        NSMutableArray *newDrawing;
        if ([self.undoStack count] > 0) {
            newDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack objectAtIndex:0] copyItems:YES];
        } else {
            newDrawing = [[NSMutableArray alloc] init];
        }
        [self.undoStack insertObject:newDrawing atIndex:0];
        [self.undoButton setEnabled:YES];
        [self removePointFromAnswer:lastPoint];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.penButton.selected) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
        [self drawLineFrom:lastPoint to:currentPoint];
        [self.undoStack[0] addObject:currentPoint];
        lastPoint = currentPoint;
    }
    
    else if (self.eraseButton.selected) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
        [self eraseLineFrom:lastPoint to:currentPoint];
        [self removePointFromAnswer:currentPoint];
        lastPoint = currentPoint;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.penButton.selected) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
        [self drawLineFrom:lastPoint to:currentPoint];
        [self.undoStack[0] addObject:currentPoint];
    }
    else if (self.eraseButton.selected) {
        CRAnswerPoint *currentPoint = [[CRAnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
        [self eraseLineFrom:lastPoint to:currentPoint];
        [self removePointFromAnswer:currentPoint];
    }
}

-(void)drawLineFrom:(CRAnswerPoint *)beg to:(CRAnswerPoint *)fin {
    //Make region drawable
    UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
    [self.drawView.image drawInRect: CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)]; //Drawable rect w/in image is 0,0 in image, to w, h of image
    
    //Set up to draw line
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
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
    [self.drawView.image drawInRect: CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)]; //Drawable rect w/in image is 0,0 in image, to w, h of image
    
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
        ((CRAnswerPoint *)[self.undoStack[0] objectAtIndex:idx - 1]).isEndPoint = YES;
    }];
    //Remove points
    [self.undoStack[0] removeObjectsAtIndexes:toRemove];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
