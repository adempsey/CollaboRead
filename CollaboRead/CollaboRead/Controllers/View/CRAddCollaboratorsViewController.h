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

@interface CRAddCollaboratorsViewController : CRSideBarViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CRUserSuggestionTableViewControllerDelegate>

@end
