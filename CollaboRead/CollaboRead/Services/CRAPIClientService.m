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

//#define kCR_API_ADDRESS @"https://collaboread.herokuapp.com/api/v1/"

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

@interface CRAPIClientService ()

@property (nonatomic, readwrite, strong) NSString *serverAPIAddress;

@end

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

- (void)setServerAddress:(NSString *)serverAddress
{
	serverAddress = [NSString stringWithFormat:@"http://%@", serverAddress];
	_serverAddress = serverAddress;

	if (![serverAddress isEqualToString:@"http://collaboread.herokuapp.com"]) {
		serverAddress = [serverAddress stringByAppendingString:@":5000"];
	}

	self.serverAPIAddress = [serverAddress stringByAppendingString:@"/api/v1/"];
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

- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(CRUser*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_LECTURERS withID:lecturerID completionBlock:^(NSDictionary *userDictionary) {
		CRUser *lecturer = [[CRUser alloc] initWithDictionary:userDictionary];
		block(lecturer);
	}];
}

- (void)retrieveStudentWithID:(NSString*)studentID block:(void (^)(CRUser*))block
{
    [self retrieveItemFromEndpoint:kCR_API_ENDPOINT_USERS withID:studentID completionBlock:^(NSDictionary *userDictionary) {
        CRUser *student = [[CRUser alloc] initWithDictionary:userDictionary];
        block(student);
    }];
}

- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(CRCaseSet*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_CASE_SET withID:caseSetID completionBlock:^(NSDictionary *caseSetDictionary) {
		CRCaseSet *caseSet = [[CRCaseSet alloc] initWithDictionary:caseSetDictionary];
		block(caseSet);
	}];
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

	NSString *resource = [self.serverAPIAddress stringByAppendingString:kCR_API_ENDPOINT_CASE_SET];
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_LECTURER_ID: lecturer};

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"GET" withParams:params completionBlock:completionBlock];
}

- (void)retrieveItemFromEndpoint:(NSString*)endpoint withID:(NSString*)idNumber completionBlock:(void (^)(NSDictionary*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSDictionary *retrievedItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(retrievedItem);
	};

	NSString *resource = [self.serverAPIAddress stringByAppendingString:endpoint];
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_ID: idNumber};

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"GET" withParams:params completionBlock:completionBlock];
}

- (void)retrieveItemListFromEndpoint:(NSString*)endpoint completionBlock:(void (^)(NSArray*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSArray *list = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		block(list);
	};

	NSString *resource = [self.serverAPIAddress stringByAppendingString:endpoint];

	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"GET" withParams:nil completionBlock:completionBlock];
}

#pragma mark - Submission Methods

- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(CRCaseSet*))block
{
	void (^completionBlock)(NSData*) = ^void(NSData *json) {
		NSDictionary *caseItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		CRCaseSet *caseSet = [[CRCaseSet alloc] initWithDictionary:caseItem];
		block(caseSet);
	};

	NSString *resource = [self.serverAPIAddress stringByAppendingString:kCR_API_ENDPOINT_SUBMIT_ANSWER];

	NSDictionary *params = @{
							 kCR_API_QUERY_PARAMETER_CASE_SET_ID: setID,
							 kCR_API_QUERY_PARAMETER_CASE_ID: caseID,
							 kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS: answer.owners.jsonString,
							 kCR_API_QUERY_PARAMETER_CASE_ANSWER_DATA: answer.answerData.jsonString
							 };
	[[CRNetworkingService sharedInstance] performRequestForResource:resource usingMethod:@"POST" withParams:params completionBlock:completionBlock];
}

@end
