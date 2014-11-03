//
//  NSDate+CRAdditions.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "NSDate+CRAdditions.h"

@implementation NSDate (CRAdditions)

// http://stackoverflow.com/questions/16715320/json-date-to-nsdate-issue
+ (NSDate*)dateFromJSONString:(NSString*)string
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
	
	return [dateFormat dateFromString:string];
}

@end
