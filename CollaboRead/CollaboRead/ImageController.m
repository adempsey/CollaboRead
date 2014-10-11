//
//  ImageController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/8/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "ImageController.h"

@interface ImageController ()
{
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGPoint lastPoint;
}
@property (nonatomic, strong) UIImageView *drawView;
@property (nonatomic, strong) UIImageView *caseImage;
@end

@implementation ImageController
@synthesize drawView;
@synthesize caseImage;


//Loads the image to be drawn over into the image view and scales it to fit the screen.
-(void)loadAndScaleImage:(UIImage *)img
{
    self.caseImage = [[UIImageView alloc] initWithImage:img];
    CGRect newFrame = self.caseImage.frame;
    
    //If image is portrait orientation, make it landscape so it can appear larger on the screen
    if (newFrame.size.height > newFrame.size.width) {
        self.caseImage.image = [[UIImage alloc] initWithCGImage:self.caseImage.image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
        CGFloat temp = newFrame.size.width;
        newFrame.size.width = newFrame.size.height;
        newFrame.size.height = temp;
        self.caseImage.frame = newFrame;
        NSLog(@"w = %f, h = %f", newFrame.size.width, newFrame.size.height);
    }
    
    //If the image doesn't already fit as much as the view as possible
    if (caseImage.frame.size.height != self.view.frame.size.height &&
        caseImage.frame.size.width != self.view.frame.size.width) {
        
        double scale = self.view.frame.size.height/self.caseImage.frame.size.height;
        
        //Determine whether having image expand to sides will cut off top and bottom. If it does, expand to top and bottom. If it doesn't expanding to top and bottom would have either caused the sides to be cut off or it fits the screen exactly and it doesn't matter which to use as scale.
        //Each case expands and centers image appropriately
        if (newFrame.size.width * scale > self.view.frame.size.width) {
            scale = self.view.frame.size.width/self.caseImage.frame.size.width;
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
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Users/hannah/Desktop/CompSci/Capstone/Collaboread/CollaboRead/CollaboRead/CollaboRead/background.jpg"];//could change to URL or other form
                                                                                                                                                   //also likely would be set by transitioning view.
    UIImage *img = [[UIImage alloc] initWithData:imgData];
    //[img set scale somehow?]
    [self loadAndScaleImage:img];
    [self.view addSubview:self.caseImage];
    
    
    self.drawView = [[UIImageView alloc] initWithFrame:self.caseImage.frame];
    [self.view addSubview:self.drawView];
    red = 255;
    blue = 0;
    green = 0;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    lastPoint = [[touches anyObject] locationInView:self.drawView];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint currentPoint = [[touches anyObject] locationInView:self.drawView];
    
    UIGraphicsBeginImageContext(self.drawView.frame.size);//Draw only in image
    
    [self.drawView.image drawInRect: CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)]; //Drawable rect w/in image is 0,0 in image, to w, h of image
    
    //Set up to draw line
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    
    //Add line to image and draw
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawView setAlpha:1.0];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
