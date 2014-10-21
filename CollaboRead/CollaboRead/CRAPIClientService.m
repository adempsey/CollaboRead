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
#define kCR_API_ENDPOINT_CASE_SET @"casesets"
#define kCR_API_QUERY_PARAMETER_ID @"id"
#define kCR_API_QUERY_PARAMETER_LECTURER_ID @"lecturerID"

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
	[self retrieveItemListFromEndpoint:kCR_API_ENDPOINT_USERS completionBlock:block];
}

- (void)retrieveLecturersWithBlock:(void (^)(NSArray*))block
{
	[self retrieveItemListFromEndpoint:kCR_API_ENDPOINT_LECTURERS completionBlock:block];
}

- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(NSDictionary*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_LECTURERS withID:lecturerID completionBlock:block];
}

- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(NSDictionary*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_CASE_SET withID:caseSetID completionBlock:block];
}

- (void)retrieveCaseSetsWithLecturer:(NSString *)lecturer block:(void (^)(NSArray *))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSArray *retrievedItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(retrievedItem);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:kCR_API_ENDPOINT_CASE_SET];
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_LECTURER_ID: lecturer};

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"GET" withParams:params completionBlock:completionBlock];
}

- (void)retrieveItemFromEndpoint:(NSString*)endpoint withID:(NSString*)idNumber completionBlock:(void (^)(NSDictionary*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSDictionary *retrievedItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(retrievedItem);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:endpoint];
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_ID: idNumber};

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"GET" withParams:params completionBlock:completionBlock];
}

- (void)retrieveItemListFromEndpoint:(NSString*)endpoint completionBlock:(void (^)(NSArray*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSArray *list = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(list);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:endpoint];

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"GET" withParams:nil completionBlock:completionBlock];
}

@end
