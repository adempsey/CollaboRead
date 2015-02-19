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

-(void)setIsHighlighted:(BOOL)isHighlighted {
    _isHighlighted = isHighlighted;
    if (isHighlighted) {
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [CR_COLOR_ANSWER_INDICATOR CGColor];
    } else {
        self.layer.borderWidth = 0.0;
    }
}

-(void)setImage:(UIImage *)image
{
    self.imgView.image = image;
    self.imgView.frame = CGRectMake(0, 0, image.size.width * kCR_CAROUSEL_CELL_HEIGHT / image.size.height, kCR_CAROUSEL_CELL_HEIGHT);
    self.frame = self.imgView.frame;
}


@end
