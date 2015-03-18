//
//  CRPatientInfoViewController.h
//  CollaboRead
//
//  Created by Hamid Mansoor on 12/1/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRSideBarViewController.h"

/*!
 @class CRPatientInfoViewController
 @discussion A view controller to display patient info
 */
@interface CRPatientInfoViewController : UIViewController

/*!
 @brief Text of patient info to display
 */
@property (nonatomic, readwrite, strong) NSString *infoText;

/*!
 Initializes the view with some patient info
 @param patientInfo
 String to set infoText property to
 */
- (instancetype)initWithPatientInfo:(NSString *)patientInfo;

/*!
 Updates the frame of the view and its subviews appropriately, should be used exclusively to set the view size
 @param frame
 New frame for the view
 */
-(void)setViewFrame:(CGRect)frame;

@end
