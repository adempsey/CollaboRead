//
//  NSDictionary+CRAdditions.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/25/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CRAdditions)
/*!
 Converts dictionary to a json string
 @return Json formatted string from the dictionary
 */
- (NSString*)jsonString;

@end
