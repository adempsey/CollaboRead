//
//  CRUserSuggestionTableViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 3/17/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUser.h"

/*!
 @class CRUserSuggestionTableViewController
 
 @discussion Suggests users in a table format based on a prefix and the current contents of the user autocompletion service
 */
@interface CRUserSuggestionTableViewController : UITableViewController
/*!
 @brief prefix to display suggestions for, automatically updates view when set
 */
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, weak) id delegate;
@end

@protocol CRUserSuggestionTableViewControllerDelegate <NSObject>

@required
-(void)suggestionSelected:(CRUser *)user;

@end
