//
//  CRSelectLectureViewController.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 4/9/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUser.h"

@interface CRSelectLectureViewController : UICollectionViewController

@property (nonatomic, readwrite, strong) CRUser *lecturer;

@end
