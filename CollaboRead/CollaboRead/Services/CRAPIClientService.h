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

@interface CRAPIClientService : NSObject

+ (CRAPIClientService*)sharedInstance;

- (void)retrieveUsersWithBlock:(void (^)(NSArray*))block;
- (void)retrieveLecturersWithBlock:(void (^)(NSArray*))block;
- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(CRUser*))block;
- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(CRCaseSet*))block;
- (void)retrieveCaseSetsWithLecturer:(NSString*)lecturer block:(void (^)(NSArray*))block;

- (void)submitAnswer:(NSString*)answer fromStudents:(NSArray*)students forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(CRCaseSet*))block;

@end
