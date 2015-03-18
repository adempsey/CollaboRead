//
//  CRCollaboratorList.m
//  CollaboRead
//
//  Created by Hannah Clark on 3/4/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRCollaboratorList.h"
#import "CRAPIClientService.h"
#import "CRUserKeys.h"
#import "CRAccountService.h"

@interface CRCollaboratorList ()
/*!
 @brief Users currently working together. Currently logged in user is always at index 0.
 */
@property (nonatomic, strong) NSMutableArray *collaborators;
@end
@implementation CRCollaboratorList

+ (instancetype)sharedInstance {
    static CRCollaboratorList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.collaborators = [[NSMutableArray alloc] init];
    });
    return sharedInstance;
}

- (void)addCollaborator:(CRUser *)user {
    [self.collaborators addObject:user];
}

- (NSUInteger)collaboratorCount {
    return self.collaborators.count;
}

- (NSString *)collaboratorNameForIndex:(NSUInteger)index {
    return ((CRUser *)self.collaborators[index]).name;
}

- (NSString *)collaboratorEmailForIndex:(NSUInteger)index {
    return ((CRUser *)self.collaborators[index]).email;
}
- (NSArray *)collaboratorIds {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    [self.collaborators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ret addObject:((CRUser *)obj).userID];
    }];
    return ret;
}

- (void)removeCollaboratorAtIndex:(NSUInteger)index {
    if (index > 0 && index < self.collaborators.count) {
        [self.collaborators removeObjectAtIndex: index];
    }
}

-(void)clearCollaborators {
    self.collaborators = [[NSMutableArray alloc] init];
    self.groupName = nil;
}

-(void)setOwner {
    [self.collaborators addObject:[[CRAccountService sharedInstance] user]];
}

@end
