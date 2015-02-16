//
//  CRPatientInfoViewController.h
//  CollaboRead
//
//  Created by Hamid Mansoor on 12/1/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRSideBarViewController.h"

@interface CRPatientInfoViewController : CRSideBarViewController

@property (nonatomic, readwrite, strong) NSString *infoText;

- (instancetype)initWithPatientInfo:(NSString *)patientInfo;

@end
