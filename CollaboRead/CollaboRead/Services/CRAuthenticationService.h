//
//  CRAuthenticationService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/28/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAuthenticationService : NSObject

+ (CRAuthenticationService*)sharedInstance;

@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *password;

@end
