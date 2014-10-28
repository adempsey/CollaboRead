//
//  CRTitledImageCollectionCell.h
//  CollaboRead
//
//  A custom collection view cell for the selection of cases or lecturers.
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRTitledImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet UILabel *name;

@end