//
//  NSDictionary+CRAdditions.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/25/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "NSDictionary+CRAdditions.h"

@implementation NSDictionary (CRAdditions)

- (NSString*)jsonString
{
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
	NSString *res = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	return res;
}

@end
