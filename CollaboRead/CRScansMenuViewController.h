//
//  CRScansMenuViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 1/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRScansMenuViewControllerDelegate <NSObject>

@required
- (void)scansMenuViewControllerDidSelectScan:(NSString *)scanId;

@end


@interface CRScansMenuViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id < CRScansMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *scans;

-(instancetype)initWithScans:(NSArray *)scans;
-(void) setViewFrame:(CGRect)frame;

@end

