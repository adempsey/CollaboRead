//
//  CRCollaboratorList.h
//  CollaboRead
//
//  Created by Hannah Clark on 3/4/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CR_INVALID_COLLABORATOR @"Invalid Email"

@interface CRCollaboratorList : NSObject

@property (nonatomic, strong) NSString *groupName;

+(instancetype)sharedInstance;
-(void)setOwner:(NSString *)email withName:(NSString *)name andID:(NSString *)ID;
-(void)verifyCollaborators:(void (^)())block;
-(void)addCollaborator:(NSString *)email;
-(NSArray *)collaboratorIds;
-(NSUInteger)collaboratorCount;
-(NSString *)collaboratorForIndex:(NSUInteger)index;
-(NSString *)nameForCollaborator:(NSString *)email;
-(void)removeCollaboratorAtIndex:(NSUInteger)index;

@end
