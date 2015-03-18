//
//  CRAuthenticationService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRUser.h"

/*!
 @class CRAccountService
 
 @discussion Singleton to keep track of currently logged in user
 */
@interface CRAccountService : NSObject

+ (CRAccountService*)sharedInstance;

/*!
 @brief Currently logged in user
 */
@property (nonatomic, readwrite, strong) CRUser *user;
/*!
 @brief Password of logged in user
 */
@property (nonatomic, readwrite, strong) NSString *password;

/*!
 Clears user information upon a logout
 */
- (void)logout;

@end
