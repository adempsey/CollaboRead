//
//  CRAPIClientService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAPIClientService : NSObject

+ (CRAPIClientService*)sharedInstance;

- (void)retrieveUsersWithBlock:(void (^)(NSArray*))block;
- (void)retrieveLecturersWithBlock:(void (^)(NSArray*))block;
- (void)retrieveLecturerWithID:(NSString*)lecturerID block:(void (^)(NSDictionary*))block;
- (void)retrieveCaseSetWithID:(NSString*)caseSetID block:(void (^)(NSDictionary*))block;
- (void)retrieveCaseSetsWithLecturer:(NSString*)lecturer block:(void (^)(NSArray*))block;

- (void)submitAnswer:(NSString*)answer fromStudents:(NSArray*)students forCase:(NSString*)caseID inSet:(NSString*)setID block:(void (^)(NSDictionary*))block;

@end
