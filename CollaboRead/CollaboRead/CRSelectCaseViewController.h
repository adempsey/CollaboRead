//
//  CRSelectCaseViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRSelectCaseViewController : UICollectionViewController

@property (nonatomic, strong) NSDictionary *lecturer;
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSArray *caseSets;

@end
