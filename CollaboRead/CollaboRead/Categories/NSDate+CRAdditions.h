//
//  NSDate+CRAdditions.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CRAdditions)

+ (NSDate*)dateFromJSONString:(NSString*)string;

@end
