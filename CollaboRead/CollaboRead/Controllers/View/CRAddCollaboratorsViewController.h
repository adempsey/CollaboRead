//
//  CRAddCollaboratorsViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 2/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRAddCollaboratorsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(NSArray *)collaborators;

@end
