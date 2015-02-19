//
//  CRCarouselCell.h
//  CollaboRead
//
//  Created by Hannah Clark on 2/19/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCR_CAROUSEL_CELL_HEIGHT 75

@interface CRCarouselCell : UIView

@property (nonatomic, assign) BOOL isHighlighted;

-(void)setImage:(UIImage *)image;

@end
