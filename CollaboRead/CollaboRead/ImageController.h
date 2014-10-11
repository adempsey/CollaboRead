//
//  ImageController.h
//  CollaboRead
//
//  Allows drawing a path in red over a preloaded image. Image should be loaded using loadAndScaleImage:
//  only.
//
//  Created by Andrew Dempsey on 10/8/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageController : UIViewController

//Loads the image to be drawn over into the view and scales it to fit the screen.
-(void)loadAndScaleImage:(UIImage *)img;

@end

