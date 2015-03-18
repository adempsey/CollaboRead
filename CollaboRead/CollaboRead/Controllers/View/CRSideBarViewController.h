//
//  CRSideBarViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/12/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CR_SIDE_BAR_SIDES) {
	CR_SIDE_BAR_SIDE_LEFT = 0,
	CR_SIDE_BAR_SIDE_RIGHT
};
/*!
 @class CRSideBarViewController
 
 @discussion
 A view controller meant to be a child view controller associating to either the left or right side of the screen with the ability to toggle visibility, effecting a horizontal slide out of view or into view.
 */
@interface CRSideBarViewController : UIViewController

@property (nonatomic, readwrite, weak) id delegate;

/*!
 @brief Side associated to, of CR_SIDE_BAR_SIDES
 */
@property (nonatomic, readwrite, assign) NSUInteger side;

/*!
 @brief Width of bar
 */
@property (nonatomic, readwrite, assign) CGFloat width;

/*!
 @brief Whether the bar is currently toggled on screen
 */
@property (nonatomic, readwrite, assign) BOOL visible;

/*!
 @brief Button to trigger toggle, may be a UIButton or UIBarButtonItem
 */
@property (nonatomic, readwrite, strong) id toggleButton;

@end

/*!
 @protocol CRSideBarViewControllerDelegate
 
 @discussion
 Provides an interface for another controller to observe changes in the side bar
 */
@protocol CRSideBarViewControllerDelegate <NSObject>

@optional
/*!
 Called when the controller changes visibility to allow the delegate to respond appropriately
 
 @param sideBarViewController
 Side bar controller changed
 @param visible
 New visibility of controller
 */
- (void)CRSideBarViewController:(CRSideBarViewController*)sideBarViewController didChangeVisibility:(BOOL)visible;

@end