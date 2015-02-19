//
//  CRToolPanelCell.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/6/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRToolPanelCell.h"
#import "CRColors.h"

@implementation CRToolPanelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	self.imageView.tintColor = selected ? CR_COLOR_TINT : [UIColor whiteColor];
}

@end
