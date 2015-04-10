//
//  CRSelectCaseViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUser.h"

/*!
 @class CRSelectCaseViewController
 
 @discussion View Controller for case selection
 */
@interface CRSelectCaseViewController : UICollectionViewController

/*!
 @brief Lecturer whose cases are being selected from
 */
@property (nonatomic, strong) CRUser *lecturer;
@property (nonatomic, readwrite, strong) NSString *lectureID;
@property (nonatomic, readwrite, strong) NSDictionary *cases;

@end
