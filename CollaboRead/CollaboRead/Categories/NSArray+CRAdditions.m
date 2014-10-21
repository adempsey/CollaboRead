//
//  NSArray+CRAdditions.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/21/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "NSArray+CRAdditions.h"

@implementation NSArray (CRAdditions)

- (NSString*)jsonString
{
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
