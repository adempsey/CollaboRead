//
//  CRCarouselCell.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/19/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRCarouselCell.h"
#import "CRColors.h"


@interface CRCarouselCell ()
/*!
 @brief Image view to display the cell's image
 */
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation CRCarouselCell

-(instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kCR_CAROUSEL_CELL_HEIGHT, kCR_CAROUSEL_CELL_HEIGHT);
        _isHighlighted = NO;
        self.imgView = [[UIImageView alloc] init];
        [self addSubview: self.imgView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, kCR_CAROUSEL_CELL_HEIGHT, kCR_CAROUSEL_CELL_HEIGHT);
        _isHighlighted = NO;
        self.imgView = [[UIImageView alloc] init];
        [self addSubview: self.imgView];
    }
    return self;
}

//If the highlight is changed, adjust the view as appropriate
-(void)setIsHighlighted:(BOOL)isHighlighted {
    _isHighlighted = isHighlighted;
    if (isHighlighted) {
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [CR_COLOR_ANSWER_INDICATOR CGColor];
    } else {
        self.layer.borderWidth = 0.0;
    }
}

//Sets the image view's image
-(void)setImage:(UIImage *)image
{
    self.imgView.image = image;
    if (image.size.width > image.size.height) {
        CGFloat height = image.size.height * kCR_CAROUSEL_CELL_HEIGHT / image.size.width;
        self.imgView.frame = CGRectMake(0, (kCR_CAROUSEL_CELL_HEIGHT - height)/2,  kCR_CAROUSEL_CELL_HEIGHT, height);
    } else {
        CGFloat width = image.size.width * kCR_CAROUSEL_CELL_HEIGHT / image.size.height;
        self.imgView.frame = CGRectMake((kCR_CAROUSEL_CELL_HEIGHT - width)/2, 0, width, kCR_CAROUSEL_CELL_HEIGHT);
    }
}


@end
