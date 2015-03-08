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

@interface CRCollaboratorList ()
@property (nonatomic, strong) NSMutableArray *confirmedCollaborators;
@property (nonatomic, strong) NSMutableArray *unconfirmedCollaborators;
@property (nonatomic, strong) NSMutableArray *invalidCollaborators;
@end
@implementation CRCollaboratorList

+(instancetype)sharedInstance {
    static CRCollaboratorList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.confirmedCollaborators = [[NSMutableArray alloc] init];
        sharedInstance.unconfirmedCollaborators = [[NSMutableArray alloc] init];
        sharedInstance.invalidCollaborators = [[NSMutableArray alloc] init];
    });
    return sharedInstance;
}
-(void)setOwner:(NSString *)email withName:(NSString *)name andID:(NSString *)ID {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: email, CR_DB_USER_EMAIL, name, CR_DB_USER_NAME, ID, CR_DB_USER_ID, nil];
    if (self.confirmedCollaborators.count == 0) {
        [self.confirmedCollaborators addObject: dict];
    }
    else {
        [self.confirmedCollaborators replaceObjectAtIndex:0 withObject:dict];
    }
}

-(void)addCollaborator:(NSString *)email {
    [self.unconfirmedCollaborators addObject:email];
}

-(NSUInteger)collaboratorCount {
    return self.confirmedCollaborators.count + self.unconfirmedCollaborators.count + self.invalidCollaborators.count;
}

-(NSString *)collaboratorForIndex:(NSUInteger)index {
    if (index < self.confirmedCollaborators.count) {
        return self.confirmedCollaborators[index][CR_DB_USER_EMAIL];
    }
    if (index < self.confirmedCollaborators.count + self.unconfirmedCollaborators.count) {
        return self.unconfirmedCollaborators[index - self.confirmedCollaborators.count];
    }
    if (index < [self collaboratorCount]) {
        return self.invalidCollaborators[index - self.confirmedCollaborators.count - self.unconfirmedCollaborators.count];
    }
    return nil;
}

-(NSString *)nameForCollaborator:(NSString *)email {
    for (NSDictionary *d in self.confirmedCollaborators) {
        if ([d[CR_DB_USER_EMAIL] isEqualToString:email]) {
            return d[CR_DB_USER_NAME];
        }
    }
    if ([self.invalidCollaborators containsObject:email]) {
        return CR_INVALID_COLLABORATOR;
    }
    return nil;
}
-(NSArray *)collaboratorIds {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    [self.confirmedCollaborators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ret addObject:obj[CR_DB_USER_ID]];
    }];
    return ret;
}

-(void)removeCollaboratorAtIndex:(NSUInteger)index {
    if (index < self.confirmedCollaborators.count) {
        [self.confirmedCollaborators removeObjectAtIndex: index];
    }
    if (index < self.confirmedCollaborators.count + self.unconfirmedCollaborators.count) {
        [self.unconfirmedCollaborators removeObjectAtIndex: index - self.confirmedCollaborators.count];
    }
    if (index < [self collaboratorCount]) {
        [self.invalidCollaborators removeObjectAtIndex: index - self.confirmedCollaborators.count - self.unconfirmedCollaborators.count];
    }
}

-(void)verifyCollaborators:(void (^)())block {
    [[CRAPIClientService sharedInstance] verifyUsersExist:self.unconfirmedCollaborators block:^(NSArray *confirmed, NSArray *invalid) {
        [self.confirmedCollaborators addObjectsFromArray:confirmed];
        [self.invalidCollaborators addObjectsFromArray:invalid];
        [self.unconfirmedCollaborators removeAllObjects];
        block();
    }];
}
@end
