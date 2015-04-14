//
//  CRCollaboratorList.h
//  CollaboRead
//
//  Created by Hannah Clark on 3/4/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRUser.h"

/*!
 @class CRCollaboratorList
 
 @discussion Singleton to store users currently working together
 */
@interface CRCollaboratorList : NSObject

+(instancetype)sharedInstance;

/*!
 @brief Custom name for group of collaborators
 */
@property (nonatomic, strong) NSString *groupName;

/*!
 Adds a collaborator to the list
 
 @param user
 User to add as a collaborator
 */
-(void)addCollaborator:(CRUser *)user;

/*!
 Retrieves all the user IDs of the collaborators
 
 @return
 IDs of all users in the list
 */
-(NSArray *)collaboratorIds;
/*!
 Retrieves the number of collaborators
 
 @return
 Number of collaborators
 */
-(NSUInteger)collaboratorCount;
/*!
 Retrieves name of collaborator specified by index
 
 @param index
 Index of collaborator
 
 @return
 Name of collaborator at index
 */
-(NSString *)collaboratorNameForIndex:(NSUInteger)index;
/*!
 Retrieves email of collaborator specified by index
 
 @param index
 Index of collaborator
 
 @return
 email of collaborator at index
 */
-(NSString *)collaboratorEmailForIndex:(NSUInteger)index;

/*!
 Removes collaborator specified by index
 
 @param index
 Index of collaborator to remove
 */
-(void)removeCollaboratorAtIndex:(NSUInteger)index;

/*!
 Clears collaborators. To be called upon logout
 */
-(void)clearCollaborators;

/*!
 Sets current user from CRAccountService, should only be called immediately upon logging in
 */
-(void)setOwner;

@end
