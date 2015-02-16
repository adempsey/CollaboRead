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

@interface CRSideBarViewController : UIViewController

@property (nonatomic, readwrite, assign) NSUInteger side;
@property (nonatomic, readwrite, assign) CGFloat width;
@property (nonatomic, readwrite, assign) BOOL visible;

@property (nonatomic, readwrite, strong) id toggleButton;

@end
