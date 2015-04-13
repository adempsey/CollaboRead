//
//  CRAPIClientService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAPIClientService.h"
#import "CRNetworkingService.h"
#import "CRAccountService.h"
#import "CRUserKeys.h"

#import "NSArray+CRAdditions.h"
#import "NSDictionary+CRAdditions.h"

#define kCR_API_ADDRESS @"https://collaboread.herokuapp.com/api/v1/"
//#define kCR_API_ADDRESS @"http://localhost:5000/api/v1/"
#define kCR_API_ENDPOINT(endpoint) [kCR_API_ADDRESS stringByAppendingString:endpoint]

#define kHTTP_METHOD_GET @"GET"
#define kHTTP_METHOD_POST @"POST"
#define kHTTP_METHOD_PUT @"PUT"

#define kCR_API_ENDPOINT_LOGIN kCR_API_ENDPOINT(@"login")
#define kCR_API_ENDPOINT_REGISTER kCR_API_ENDPOINT(@"register")
#define kCR_API_ENDPOINT_FORGOT kCR_API_ENDPOINT(@"forgot")
#define kCR_API_ENDPOINT_USER_CHECK kCR_API_ENDPOINT(@"usercheck")
#define kCR_API_ENDPOINT_USERS kCR_API_ENDPOINT(@"users")
#define kCR_API_ENDPOINT_LECTURERS kCR_API_ENDPOINT(@"lecturers")
//#define kCR_API_ENDPOINT_CASE_SET kCR_API_ENDPOINT(@"casesets")
#define kCR_API_ENDPOINT_CASE_SET kCR_API_ENDPOINT(@"caseset")
//#define kCR_API_ENDPOINT_SUBMIT_ANSWER kCR_API_ENDPOINT(@"submitanswer")
#define kCR_API_ENDPOINT_SUBMIT_ANSWER kCR_API_ENDPOINT(@"answer")
#define kCR_API_ENDPOINT_ANSWERS kCR_API_ENDPOINT(@"answer")

#define kCR_API_QUERY_PARAMETER_ID @"id"
#define kCR_API_QUERY_PARAMETER_LECTURER_ID @"lecturerID"

#define kCR_API_QUERY_PARAMETER_CASE_SET_ID @"setID"
#define kCR_API_QUERY_PARAMETER_CASE_ID @"caseID"
#define kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS @"owners"
#define kCR_API_QUERY_PARAMETER_CASE_ANSWER_DRAWINGS @"drawings"

#define kCR_API_QUERY_PARAMETER_USER_LIST @"users"

#define kCR_API_QUERY_PARAMETER_USER_EMAIL CR_DB_USER_EMAIL
#define kCR_API_QUERY_PARAMETER_USER_PASSWORD CR_DB_USER_PASSWORD

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

#pragma mark - User Account Methods

- (void)loginUserWithEmail:(NSString *)email password:(NSString *)password block:(void (^)(CRUser*, NSError*))block
{
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_USER_EMAIL: email, kCR_API_QUERY_PARAMETER_USER_PASSWORD: password};
	[[CRNetworkingService sharedInstance] performRequestForResource:kCR_API_ENDPOINT_LOGIN usingMethod:kHTTP_METHOD_POST withParams:params completionBlock:^(NSData *data, NSError *error) {
		if (!error) {
			
			NSDictionary *retrievedUserData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			CRUser *user = [[CRUser alloc] initWithDictionary:retrievedUserData];
			
			[CRAccountService sharedInstance].user = user;
			[CRAccountService sharedInstance].password = password;
			block(user, nil);
		} else {
			block(nil, error);
		}
	}];
}

- (void)registerUser:(CRUser *)user password:(NSString *)password block:(void (^)(NSError *))block
{
	if (!user.name || !user.type || !user.year || !user.email || !password) {
		NSError *parameterError = [NSError errorWithDomain:@"Missing required parameters" code:0 userInfo:nil];
		block(parameterError);
		return;
	}
	
	NSDictionary *params = @{
							 CR_DB_USER_NAME: user.name,
							 CR_DB_USER_TYPE: user.type,
							 CR_DB_USER_TITLE: user.title ? : @"",
							 CR_DB_USER_YEAR: user.year,
							 CR_DB_USER_PICTURE: user.imageURL ? : @"",
							 CR_DB_USER_EMAIL: user.email,
							 CR_DB_USER_PASSWORD: password
							 };
	[[CRNetworkingService sharedInstance] performRequestForResource:kCR_API_ENDPOINT_REGISTER usingMethod:kHTTP_METHOD_POST withParams:params completionBlock:^(NSData *data, NSError *error) {
		block(error);
	}];
}

- (void)resetPasswordForAccountWithEmail:(NSString *)email block:(void (^)(NSError *))block
{
	NSDictionary *params = @{CR_DB_USER_EMAIL: email};
	[[CRNetworkingService sharedInstance] performRequestForResource:kCR_API_ENDPOINT_FORGOT usingMethod:kHTTP_METHOD_POST withParams:params completionBlock:^(NSData *data, NSError *error) {
		block(error);
	}];
}

- (void)verifyUsersExist:(NSArray*)users block:(void (^)(NSArray*, NSArray*))block
{
	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_USER_LIST: users.jsonString};
	[[CRNetworkingService sharedInstance] performAuthenticatedRequestForResource:kCR_API_ENDPOINT_USER_CHECK usingMethod:kHTTP_METHOD_POST withParams:params completionBlock:^(NSData *data, NSError *error) {
		if (!error) {
			
			NSArray *existingUsersList = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			NSMutableSet *existingEmails = [[NSMutableSet alloc] init];
			
			for (NSDictionary *user in existingUsersList) {
				[existingEmails addObject:user[kCR_API_QUERY_PARAMETER_USER_EMAIL]];
			}
			
			NSMutableSet *nonExistingUsers = [NSMutableSet setWithArray:users];
			[nonExistingUsers minusSet:existingEmails];
			
			block(existingUsersList, [nonExistingUsers allObjects]);
		}
	}];
}

#pragma mark - Public Database Retrieval Methods

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

- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(CRLecture*, NSError*))block
{
	[self retrieveItemFromEndpoint:kCR_API_ENDPOINT_CASE_SET withID:caseSetID completionBlock:^(NSDictionary *caseSetDictionary, NSError *error) {
		CRLecture *caseSet;
		if (!error) {
			caseSet = [[CRLecture alloc] initWithDictionary:caseSetDictionary];
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
					CRLecture *caseSet = [[CRLecture alloc] initWithDictionary:obj];
					[caseSets addObject:caseSet];
				}
			}];
		}
		
		NSLog(@"%@", caseSets);

		block(caseSets, error);
	};

//	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_LECTURER_ID: lecturerID};
	NSDictionary *params = @{@"lecturerID": lecturerID};
	[[CRNetworkingService sharedInstance] performAuthenticatedRequestForResource:kCR_API_ENDPOINT_CASE_SET usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
}

- (void)retrieveLecturesWithLecturer:(NSString*)lecturerID block:(void (^)(NSArray*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		NSMutableArray *caseSets = [[NSMutableArray alloc] init];
		
		if (!error) {
			NSArray *retrievedItems = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
			[retrievedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj isKindOfClass:[NSDictionary class]]) {
					CRLecture *caseSet = [[CRLecture alloc] initWithDictionary:obj];
					[caseSets addObject:caseSet];
				}
			}];
		}
		
		block(caseSets, error);
	};
	
	//	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_LECTURER_ID: lecturerID};
	NSDictionary *params = @{@"lecturerID": lecturerID};
	[[CRNetworkingService sharedInstance] performAuthenticatedRequestForResource:kCR_API_ENDPOINT_CASE_SET usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
}

- (void)retrieveAnswersForCase:(NSString*)caseID inLecture:(NSString*)lectureID block:(void (^)(NSArray*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		NSMutableArray *answerList = [[NSMutableArray alloc] init];
		
		if (!error) {
			NSArray *retrievedAnswers = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
			[retrievedAnswers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj isKindOfClass:[NSDictionary class]]) {
					CRAnswer *answer = [[CRAnswer alloc] initWithDictionary:obj];
					[answerList addObject:answer];
				}
			}];
		}
		
		block(answerList, error);
	};
	
	NSDictionary *params = @{@"lectureID": lectureID, @"caseID": caseID};
	[[CRNetworkingService sharedInstance] performRequestForResource:kCR_API_ENDPOINT_ANSWERS usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
}

- (void)retrieveAnswerForCase:(NSString*)caseID inLecture:(NSString*)lectureID withOwner:(NSString*)ownerID block:(void (^)(CRAnswer*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		CRAnswer *answer;
		if (!error && json.length > 0) {
			NSDictionary *answerData = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
			 answer = [[CRAnswer alloc] initWithDictionary:answerData];
		}
		block(answer, error);
	};
	
	NSDictionary *params = @{@"lectureID": lectureID, @"caseID": caseID, @"ownerID": ownerID};
	[[CRNetworkingService sharedInstance] performRequestForResource:kCR_API_ENDPOINT_ANSWERS usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
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

	NSDictionary *params = @{kCR_API_QUERY_PARAMETER_ID: idNumber};
	[[CRNetworkingService sharedInstance] performAuthenticatedRequestForResource:endpoint usingMethod:kHTTP_METHOD_GET withParams:params completionBlock:completionBlock];
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

	[[CRNetworkingService sharedInstance] performAuthenticatedRequestForResource:endpoint usingMethod:kHTTP_METHOD_GET withParams:nil completionBlock:completionBlock];
}

#pragma mark - Public Submission Methods

- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inLecture:(NSString*)setID block:(void (^)(CRLecture*, NSError*))block
{
	void (^completionBlock)(NSData*, NSError*) = ^void(NSData *json, NSError *error) {
		CRLecture *caseSet;
		if (!error) {
			NSDictionary *caseItem = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
			caseSet = [[CRLecture alloc] initWithDictionary:caseItem];
		}
		block(caseSet, error);
	};
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: answer.jsonDictionary];
	params[@"drawings"] = ((NSDictionary *)params[kCR_API_QUERY_PARAMETER_CASE_ANSWER_DRAWINGS]).jsonString;
	params[@"owners"] = ((NSArray *)params[kCR_API_QUERY_PARAMETER_CASE_ANSWER_OWNERS]).jsonString;
	params[@"lectureID"] = setID;
	params[@"caseID"] = caseID;
	params[@"groupName"] = @"group name";
	
	[[CRNetworkingService sharedInstance] performAuthenticatedRequestForResource:kCR_API_ENDPOINT_SUBMIT_ANSWER usingMethod:kHTTP_METHOD_PUT withParams:params completionBlock:completionBlock];
}

@end
