//
//  CRAPIClientService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CRCaseSet.h"
#import "CRUser.h"
#import "CRAnswer.h"

/*!
 @class CRAPIClientService
 
 @discussion This class serves as an interface for the CollaboRead API. Use this class
 to query or write to the database.
 */
@interface CRAPIClientService : NSObject

+ (CRAPIClientService*)sharedInstance;

#pragma mark - User Account Methods

/*!
 Attempts to log a user in
 
 @param email
 email to use as a username
 @param password
 password corresponding to username
 
 @param block
 completion block to execute with retrieved user information
 */
- (void)loginUserWithEmail:(NSString*)email password:(NSString*)password block:(void (^)(CRUser*, NSError*))block;

/*!
 Registers a user
 
 @param user
 user to attempt to register
 @param block
 completion block to execute at end of registration
 */
- (void)registerUser:(CRUser*)user password:(NSString*)password block:(void (^)(NSError*))block;

/*!
 Checks existance of users based on email (username)
 
 @param block
 completion block to execute with list of valid and list of invalid usernames
 */
- (void)verifyUsersExist:(NSArray*)users block:(void (^)(NSArray*, NSArray*))block;

#pragma mark - Retrieval Methods

/*!
 Retrieves a list of all users from the API
 
 @param block
 completion block to execute with list of users
 */
- (void)retrieveUsersWithBlock:(void (^)(NSArray*, NSError*))block;

/*!
 Retrieves a list of all lecturers from the API
 
 @param block
 completion block to execute with list of lecturers
 */
- (void)retrieveLecturersWithBlock:(void (^)(NSArray*, NSError*))block;

/*!
 Retrieves a specific lecturer from the API
 
 @param lecturerID
 ID number of the desired lecturer
 @param block
 completion block to execute with CRUser object for retrieved lecturer
 */
- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(CRUser*, NSError*))block;

/*!
 Retrieves a specific student from the API
 
 @param studentID
 ID number of the desired student
 @param block
 completion block to execute with CRUser object for retrieved student
 */
- (void)retrieveStudentWithID:(NSString*)studentID block:(void (^)(CRUser*, NSError*))block;

/*!
 Retrieves a specific case set from the API
 
 @param caseSetID
 ID number of the desired case set
 @param block
 completion block to execute with CRCaseSet object for retrieved case set
 */
- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(CRCaseSet*, NSError*))block;

/*!
 Retrieves a list of case sets belonging to the given lecturer from the API
 @param lecturerID
 ID number of the desired lecturer
 @param block
 completion block to execute with list of case sets retrieved from the API
 */
- (void)retrieveCaseSetsWithLecturer:(NSString*)lecturerID block:(void (^)(NSArray*, NSError*))block;

#pragma mark - Submission Methods

/*!
 Submits an answer object to the API. The updated case set is included in the completion block
 
 @param answer
 The CRAnswer object containing the drawing data and answer owners
 @param caseID
 ID number of the case to submit an answer to
 @param setID
 ID number of the case set containing the current case
 @param block
 completion block to execute with updated case set retrieved from the API
 */
- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(CRCaseSet*, NSError*))block;

@end
