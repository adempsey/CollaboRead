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
#define kCR_API_ENDPOINT_LECTURERS @"lecturers"

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
	[self retrieveItemList:kCR_API_ENDPOINT_USERS withBlock:block];
}

- (void)retrieveLecturersWithBlock:(void (^)(NSArray*))block
{
	[self retrieveItemList:kCR_API_ENDPOINT_LECTURERS withBlock:block];
}

- (void)retrieveItemList:(NSString*)itemList withBlock:(void (^)(NSArray*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSArray *list = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(list);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:itemList];

	[[CRNetworkingService sharedInstance] performGETRequestForResource:resource withParams:nil completionBlock:completionBlock];
}

@end
