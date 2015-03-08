//
//  CRAuthenticationService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRUser.h"

@interface CRAccountService : NSObject

+ (CRAccountService*)sharedInstance;

@property (nonatomic, readwrite, strong) CRUser *user;
@property (nonatomic, readwrite, strong) NSString *password;

@end
