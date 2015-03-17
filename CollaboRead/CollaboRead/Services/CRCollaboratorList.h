//
//  CRCollaboratorList.h
//  CollaboRead
//
//  Created by Hannah Clark on 3/4/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRUser.h"

//#define CR_INVALID_COLLABORATOR @"Invalid Email"

@interface CRCollaboratorList : NSObject

@property (nonatomic, strong) NSString *groupName;

+(instancetype)sharedInstance;
//-(void)setOwner:(NSString *)email withName:(NSString *)name andID:(NSString *)ID;
//-(void)verifyCollaborators:(void (^)())block;
-(void)addCollaborator:(CRUser *)user;
-(NSArray *)collaboratorIds;
-(NSUInteger)collaboratorCount;
-(NSString *)collaboratorNameForIndex:(NSUInteger)index;
-(NSString *)collaboratorEmailForIndex:(NSUInteger)index;
-(void)removeCollaboratorAtIndex:(NSUInteger)index;

@end
