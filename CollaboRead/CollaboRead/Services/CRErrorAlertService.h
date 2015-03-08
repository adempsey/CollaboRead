//
//  CRErrorAlertService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/17/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CRErrorAlertService : NSObject

+ (CRErrorAlertService*)sharedInstance;

- (UIAlertController*)networkErrorAlertForItem:(NSString*)item completionBlock:(void (^)(UIAlertAction*))block;

@end
