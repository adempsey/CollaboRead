//
//  CRSelectCaseViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUser.h"

@interface CRSelectCaseViewController : UICollectionViewController

@property (nonatomic, strong) CRUser *lecturer;
@property (nonatomic, strong) CRUser *user;
@property (nonatomic, strong) NSArray *allUsers;



@end
