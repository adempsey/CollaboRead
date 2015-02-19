//
//  CRPatientInfoViewController.h
//  CollaboRead
//
//  Created by Hamid Mansoor on 12/1/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRPatientInfoViewController : UIViewController

- (instancetype)initWithPatientInfo: (NSString *) patientInfo;
- (void)toggleTable;

@end
