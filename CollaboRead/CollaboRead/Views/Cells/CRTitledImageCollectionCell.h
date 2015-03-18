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
/*!
 @class CRTitledImageCollectionCell
 
 @discussion A collection view cell to display an image with a title underneath
 */
@interface CRTitledImageCollectionCell : UICollectionViewCell

/*!
 @brief ImageView to display image
 */
@property (nonatomic, strong) IBOutlet UIImageView *image;
/*!
 @brief Title of the cell
 */
@property (nonatomic, strong) IBOutlet UILabel *name;


@end
