//
//  ImageController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/8/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "ImageController.h"
#import "AnswerPoint.h"

#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 50
#define BUTTON_SPACE 20

@interface ImageController ()
{
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    AnswerPoint *lastPoint;
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

@end

@implementation ImageController

//Enables appropriate touch control
-(void)penSelected:(UIButton *)pen
{
    [pen setSelected: YES];
    [self.eraseButton setSelected:NO];
}
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
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.coordinate.x, lastPoint.coordinate.y);
        for (int i = 0; i < [drawingGuide count] - 1; i++) {
            AnswerPoint *beg = [drawingGuide objectAtIndex:i];
            if (!beg.isEndPoint) {
                AnswerPoint *fin = [drawingGuide objectAtIndex:i + 1];
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), beg.coordinate.x, beg.coordinate.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), fin.coordinate.x, fin.coordinate.y);
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
}

-(void)loadView {
    [super loadView];
    
    //Most likely will be done by a transitioning view
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Users/hannah/Desktop/CompSci/Capstone/Collaboread/CollaboRead/CollaboRead/CollaboRead/background.jpg"];//could change to URL or other form
    UIImage *img = [[UIImage alloc] initWithData:imgData];
    [self loadAndScaleImage:img];
    
    self.undoStack = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.caseImage];
    self.drawView = [[UIImageView alloc] initWithFrame:self.caseImage.frame];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.penButton.selected) {
        lastPoint = [[AnswerPoint alloc] initWithPoint:[[touches anyObject] locationInView:self.drawView] end:NO];
        NSMutableArray *newDrawing;
        if ([self.undoStack count] > 0) {
            newDrawing = [[NSMutableArray alloc] initWithArray:[self.undoStack objectAtIndex:0]];
        } else {
            newDrawing = [[NSMutableArray alloc] init];
        }
        [newDrawing addObject:lastPoint];
        [self.undoStack insertObject:newDrawing atIndex:0];
        [self.undoButton setEnabled:YES];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.penButton.selected) {
        AnswerPoint *currentPoint = [[AnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:NO];
        
        //Make region drawable
        UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
        [self.drawView.image drawInRect: CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)]; //Drawable rect w/in image is 0,0 in image, to w, h of image
        
        //Set up to draw line
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.coordinate.x, lastPoint.coordinate.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.coordinate.x, currentPoint.coordinate.y);
        
        //Add line to image and draw
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.drawView setAlpha:1.0];
        UIGraphicsEndImageContext();
        
        [[self.undoStack objectAtIndex:0] addObject:currentPoint];
        lastPoint = currentPoint;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.penButton.selected) {
        AnswerPoint *currentPoint = [[AnswerPoint alloc] initWithPoint: [[touches anyObject] locationInView:self.drawView] end:YES];
        
        //Make region drawable
        UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
        [self.drawView.image drawInRect: CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)]; //Drawable rect w/in image is 0,0 in image, to w, h of image
        
        //Set up to draw line
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.coordinate.x, lastPoint.coordinate.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.coordinate.x, currentPoint.coordinate.y);

        
        //Add line to image and draw
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.drawView setAlpha:1.0];
        UIGraphicsEndImageContext();
        
        [[self.undoStack objectAtIndex:0] addObject:currentPoint];
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
