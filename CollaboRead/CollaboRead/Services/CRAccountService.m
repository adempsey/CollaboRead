//
//  CRAuthenticationService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRAccountService.h"
#import "CRDrawingPreserver.h"

@implementation CRAccountService

+ (CRAccountService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)logout
{
	self.user = nil;
	self.password = nil;
	[[CRDrawingPreserver sharedInstance] clearDrawings];
}

@end
