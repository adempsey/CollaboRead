//
//  CRCarouselCell.h
//  CollaboRead
//
//  Created by Hannah Clark on 2/19/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCR_CAROUSEL_CELL_HEIGHT 75

/*!
 @class CRCarouselCell
 
 @discussion A cell for an iCarousel that displays an image, and if highlighted, is outlined
 */
@interface CRCarouselCell : UIView

/*!
 @brief Whether or not the cell should have the highlight outline
 */
@property (nonatomic, assign) BOOL isHighlighted;
/*!
 Sets the image to display
 @param image
 Image to display as the cell
 */
-(void)setImage:(UIImage *)image;

@end
