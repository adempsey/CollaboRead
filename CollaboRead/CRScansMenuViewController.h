//
//  CRScansMenuViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 1/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @protocol CRScansMenuViewControllerDelegate
 @discussion Provides an interface to be alerted to changes in selection of scans
 */
@protocol CRScansMenuViewControllerDelegate <NSObject>

@required
/*!
 Called when a scan is selected
 @param scanId
 The scan selected
 */
- (void)scansMenuViewControllerDidSelectScan:(NSString *)scanId;

@end

/*!
 @class CRScansMenuViewController
 @discussion A view controller to select from a variety of scans
*/
@interface CRScansMenuViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id < CRScansMenuViewControllerDelegate> delegate;
/*!
 @brief Scans to display as choices
 */
@property (nonatomic, strong) NSArray *scans;
/*!
 @brief Indices of scans to highlight
 */
@property (nonatomic, strong) NSArray *highlights;

-(instancetype)initWithScans:(NSArray *)scans;
/*!
 Method to change the view's frame.
 Changing the view's frame should always be done through this method as it changes the number of items to display.
 @param frame
 The new frame for the view
 @param animated
 Whether to animate the transition
 @param block
 Block to execute after animation
 */
- (void)setViewFrame:(CGRect)frame animated:(BOOL)animated completion:(void(^)())block;

@end

