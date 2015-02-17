//
//  CRAPIClientService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAPIClientService.h"
#import "CRNetworkingService.h"

#import "NSArray+CRAdditions.h"
#import "NSDictionary+CRAdditions.h"

#define kCR_API_ADDRESS @"https://collaboread.herokuapp.com/api/v1/"

#define kHTTP_METHOD_GET @"GET"
#define kHTTP_METHOD_POST @"POST"

#define kCR_API_ENDPOINT_USERS @"users"
#define kCR_API_ENDPOINT_LECTURERS @"lecturers"
#define kCR_API_ENDPOINT_CASE_SET @"casesets"
#define kCR_API_ENDPOINT_SUBMIT_ANSWER @"submitanswer"

#define kCR_API_QUERY_PARAMETER_ID @"id"
#define kCR_API_QUERY_PARAMETER_LECTURER_ID @"lecturerID"
#define kCR_API_QUERY_PARAMETER_CASE_SET_ID @"setID"
#define kCR_API_QUERY_PARAMETER_CASE_ID @"caseID"
#define kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS @"owners"
#define kCR_API_QUERY_PARAMETER_CASE_ANSWER_DRAWINGS @"drawings"

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

#pragma mark - Public API Interface Methods

- (void)retrieveUsersWithBlock:(void (^)(NSArray*, NSError*))block
{
	[self retrieveItemListFromEndpoint:kCR_API_ENDPOINT_USERS completionBlock:^(NSArray *list, NSError *error) {
		NSMutableArray *userList = [[NSMutableArray alloc] init];
		
		if (!error) {
			[list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj isKindOfClass:[NSDictionary class]]) {
					CRUser *user = [[CRUser alloc] initWithDictionary:obj];
					[userList addObject:user];
				}
			}];
		}

		block(userList, error);
	}];
}

- (void)retrieveLecturersWithBlock:(void (^)(NSArray*, NSError*))block
{
	[self retrieveItemListFromEndpoint:kCR_API_ENDPOINT_LECTURERS completionBlock:^(NSArray *list, NSError *error) {
		NSMutableArray *lecturerList = [[NSMutableArray alloc] init];

		if (!error) {
			[list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj isKindOfClass:[NSDictionary class]]) {
					CRUser *user = [[CRUser alloc] initWithDictionary:obj];
					[lecturerList addObject:user];
				}
			}];
		}

		block(lecturerList, error);
	}];
}

- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(CRUser*, NSError*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_LECTURERS withID:lecturerID completionBlock:^(NSDictionary *userDictionary, NSError *error) {
		CRUser *lecturer;
		if (!error) {
			lecturer = [[CRUser alloc] initWithDictionary:userDictionary];
		}
		block(lecturer, error);
	}];
}

- (void)retrieveStudentWithID:(NSString*)studentID block:(void (^)(CRUser*, NSError*))block
{
    [self retrieveItemFromEndpoint:kCR_API_ENDPOINT_USERS withID:studentID completionBlock:^(NSDictionary *userDictionary, NSError *error) {
		CRUser *student;
		if (!error) {
			student = [[CRUser alloc] initWithDictionary:userDictionary];
		}
        block(student, error);
    }];
}

- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(CRCaseSet*, NSError*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_CASE_SET withID:caseSetID completionBlock:^(NSDictionary *caseSetDictionary, NSError *error) {
		CRCaseSet *caseSet;
		if (!error) {
			caseSet = [[CRCaseSet alloc] initWithDictionary:caseSetDictionary];
		}
		block(caseSet, error);
	}];
}

- (void)retrieveCaseSetsWithLecturer:(NSString *)lecturerID block:(void (^)(NSArray*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		NSMutableArray *caseSets = [[NSMutableArray alloc] init];

		if (!error) {
			NSArray *retrievedItems = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
			[retrievedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj isKindOfClass:[NSDictionary class]]) {
					CRCaseSet *caseSet = [[CRCaseSet alloc] initWithDictionary:obj];
					[caseSets addObject:caseSet];
				}
			}];
		}

		block(caseSets, error);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:kCR_API_ENDPOINT_CASE_SET];
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_LECTURER_ID: lecturerID};

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
}

#pragma mark - Private API Interface Methods

/*!
 Retrieves a unique item from the API
 
 @param endpoint
 The desired endpoint from which to retrieve the item
 @param idNumber
 The desired item's ID number
 @param block
 completion block to execute with item retrieved from the API
 */
- (void)retrieveItemFromEndpoint:(NSString*)endpoint withID:(NSString*)idNumber completionBlock:(void (^)(NSDictionary*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		NSDictionary *retrievedItem;
		if (!error) {
			retrievedItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		}
		block(retrievedItem, error);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:endpoint];
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_ID: idNumber};

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
}

/*!
 Retrieves a list of items from the API
 
 @param endpoint
 The desired endpoint from which to retrieve the list of items
 @param block
 completion block to execute with item list retrieved from the API
 */
- (void)retrieveItemListFromEndpoint:(NSString*)endpoint completionBlock:(void (^)(NSArray*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		NSArray *list;
		if (!error) {
			list = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		}
		block(list, error);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:endpoint];
	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:kHTTP_METHOD_GET withParams:nil completionBlock:completionBlock];
}

#pragma mark - Public Submission Methods

- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(CRCaseSet*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		CRCaseSet *caseSet;
		if (!error) {
			NSDictionary *caseItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
			caseSet = [[CRCaseSet alloc] initWithDictionary:caseItem];
		}
		block(caseSet, error);
	};

	NSString *resource = [kCR_API_ADDRESS stringByAppendingString:kCR_API_ENDPOINT_SUBMIT_ANSWER];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: answer.jsonDictionary];
	params[kCR_API_QUERY_PARAMETER_CASE_ANSWER_DRAWINGS] = ((NSDictionary *)params[kCR_API_QUERY_PARAMETER_CASE_ANSWER_DRAWINGS]).jsonString;
	params[kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS] = ((NSArray *)params[kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS]).jsonString;
	params[kCR_API_QUERY_PARAMETER_CASE_SET_ID] = setID;
	params[kCR_API_QUERY_PARAMETER_CASE_ID] = caseID;
	
	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:kHTTP_METHOD_POST withParams:params completionBlock:completionBlock];
}

@end
