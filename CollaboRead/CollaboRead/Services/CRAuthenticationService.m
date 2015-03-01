//
//  CRAuthenticationService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRAuthenticationService.h"

@implementation CRAuthenticationService

+ (CRAuthenticationService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

@end
