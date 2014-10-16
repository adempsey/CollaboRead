//
//  CRAPIClientService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAPIClientService.h"
#import "CRNetworkingService.h"

#define kCR_API_ADDRESS @"http://collaboread.herokuapp.com/"
#define kCR_API_ENDPOINT_USERS @"users"

@implementation CRAPIClientService

+ (CRAPIClientService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)retrieveUsersWithBlock:(void (^)(NSArray*))block
{
	void (^completionBlock)(NSData*, NSURLResponse*, NSError*) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
		if (!error) {
			NSArray *users = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			block(users);
		}
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:kCR_API_ENDPOINT_USERS];

	[[CRNetworkingService sharedInstance] performGETRequestForResource:resource withParams:nil completionBlock:completionBlock];
}

@end
