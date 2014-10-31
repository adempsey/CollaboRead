//
//  CRAPIClientService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAPIClientService.h"
#import "CRNetworkingService.h"
#import "CRCaseSet.h"
#import "CRUser.h"

#import "NSArray+CRAdditions.h"

#define kCR_API_ADDRESS @"https://collaboread.herokuapp.com/api/v1/"

#define kCR_API_ENDPOINT_USERS @"users"
#define kCR_API_ENDPOINT_LECTURERS @"lecturers"
#define kCR_API_ENDPOINT_CASE_SET @"casesets"
#define kCR_API_ENDPOINT_SUBMIT_ANSWER @"submitanswer"

#define kCR_API_QUERY_PARAMETER_ID @"id"
#define kCR_API_QUERY_PARAMETER_LECTURER_ID @"lecturerID"
#define kCR_API_QUERY_PARAMETER_CASE_SET_ID @"setID"
#define kCR_API_QUERY_PARAMETER_CASE_ID @"caseID"
#define kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS @"owners"
#define kCR_API_QUERY_PARAMETER_CASE_ANSWER_DATA @"answerData"

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

#pragma mark - Retrieval Methods

- (void)retrieveUsersWithBlock:(void (^)(NSArray*))block
{
	[self retrieveItemListFromEndpoint:kCR_API_ENDPOINT_USERS completionBlock:^(NSArray *list) {
		NSMutableArray *userList = [[NSMutableArray alloc] init];

		[list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[NSDictionary class]]) {
				CRUser *user = [[CRUser alloc] initWithDictionary:obj];
				[userList addObject:user];
			}
		}];

		block(userList);
	}];
}

- (void)retrieveLecturersWithBlock:(void (^)(NSArray*))block
{
	[self retrieveItemListFromEndpoint:kCR_API_ENDPOINT_LECTURERS completionBlock:^(NSArray *list) {
		NSMutableArray *lecturerList = [[NSMutableArray alloc] init];

		[list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[NSDictionary class]]) {
				CRUser *user = [[CRUser alloc] initWithDictionary:obj];
				[lecturerList addObject:user];
			}
		}];

		block(lecturerList);
	}];
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
		NSArray *retrievedItems = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		NSMutableArray *caseSets = [[NSMutableArray alloc] init];

		[retrievedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[NSDictionary class]]) {
				CRCaseSet *caseSet = [[CRCaseSet alloc] initWithDictionary:obj];
				[caseSets addObject:caseSet];
			}
		}];

		block(caseSets);
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

#pragma mark - Submission Methods

- (void)submitAnswer:(NSString*)answer fromStudents:(NSArray*)students forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(NSDictionary*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSDictionary *caseItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(caseItem);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:kCR_API_ENDPOINT_SUBMIT_ANSWER];

	NSDictionary *params = @{
							 kCR_API_QUERY_PARAMETER_CASE_SET_ID: setID,
							 kCR_API_QUERY_PARAMETER_CASE_ID: caseID,
							 kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS: students.jsonString,
							 kCR_API_QUERY_PARAMETER_CASE_ANSWER_DATA: answer
							 };

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"POST" withParams:params completionBlock:completionBlock];
}

@end
