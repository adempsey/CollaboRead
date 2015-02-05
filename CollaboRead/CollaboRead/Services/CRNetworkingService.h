//
//  CRNetworkingService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRNetworkingService
 @discussion This class is responsible for communicating with RESTful services.
 The class is essentially just an abstraction for easily constructing network requests
 */
@interface CRNetworkingService : NSObject

+ (CRNetworkingService*)sharedInstance;
- (void)performRequestForResource:(NSString*)resource usingMethod:(NSString*)method withParams:(NSDictionary*)params completionBlock:(void (^)(NSData*))completionBlock;

@end
