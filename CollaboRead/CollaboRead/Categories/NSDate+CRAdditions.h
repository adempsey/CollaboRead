//
//  NSDate+CRAdditions.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CRAdditions)

/*!
 Creates a date object from a json string
 @param string
 Json string containing the date
 @return Date represented by json string
 */
+ (NSDate*)dateFromJSONString:(NSString*)string;

@end
