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

@end
