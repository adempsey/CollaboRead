//
//  CRTitledImageCollectionCell.m
//  CollaboRead
//
//  A custom collection view cell for the selection of cases or lecturers.
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRTitledImageCollectionCell.h"
#import "CRColors.h"

@implementation CRTitledImageCollectionCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 21)];
        [self.image setContentMode:UIViewContentModeScaleAspectFit];
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 21, frame.size.width, 21)];
        self.name.textAlignment = NSTextAlignmentCenter;
        self.name.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.image];
        [self.contentView addSubview:self.name];
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    self.name.textColor = selected ? CR_COLOR_TINT : [UIColor whiteColor];
}


@end
