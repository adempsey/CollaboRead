//
//  CRErrorAlertService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/17/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class CRErrorAlertSevice
 
 @discussion Service to provide alerts about network errors
 */
@interface CRErrorAlertService : NSObject

+ (CRErrorAlertService*)sharedInstance;

/*!
 Generates alert for specific type of error
 
 @param item
 Type of error for the alert
 
 @param block
 Block to execute in response to user action with alert
 */
- (UIAlertController*)networkErrorAlertForItem:(NSString*)item completionBlock:(void (^)(UIAlertAction*))block;

@end
