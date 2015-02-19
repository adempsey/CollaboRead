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
	NSString *res = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return res;
}

@end
