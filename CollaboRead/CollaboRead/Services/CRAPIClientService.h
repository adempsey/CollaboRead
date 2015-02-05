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

- (void)retrieveUsersWithBlock:(void (^)(NSArray*))block;
- (void)retrieveLecturersWithBlock:(void (^)(NSArray*))block;
- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(CRUser*))block;
- (void)retrieveStudentWithID:(NSString*)studentID block:(void (^)(CRUser*))block;
- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(CRCaseSet*))block;
- (void)retrieveCaseSetsWithLecturer:(NSString*)lecturerID block:(void (^)(NSArray*))block;

- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(CRCaseSet*))block;

@end
