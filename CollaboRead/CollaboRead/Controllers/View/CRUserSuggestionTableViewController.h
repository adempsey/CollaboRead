//
//  CRUserSuggestionTableViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 3/17/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUser.h"

@interface CRUserSuggestionTableViewController : UITableViewController
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, weak) id delegate;
@end

@protocol CRUserSuggestionTableViewControllerDelegate <NSObject>

@required
-(void)suggestionSelected:(CRUser *)user;

@end
