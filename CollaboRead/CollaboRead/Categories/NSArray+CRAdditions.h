//
//  NSArray+CRAdditions.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/21/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CRAdditions)

/*!
 Creates a json formated string from an array
 @return Json string representing the array
 */
- (NSString*)jsonString;

@end
