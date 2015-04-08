//
//  CRAddCollaboratorsViewController.h
//  CollaboRead
//
//  Created by Hannah Clark on 2/22/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRSideBarViewController.h"
#import "CRUserSuggestionTableViewController.h"

/*!
 @class CRAddCollaboratorsViewController
 
 @discussion Provides user interface to adjust the collaborators for answers
 */
@interface CRAddCollaboratorsViewController : CRSideBarViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CRUserSuggestionTableViewControllerDelegate>

@end
