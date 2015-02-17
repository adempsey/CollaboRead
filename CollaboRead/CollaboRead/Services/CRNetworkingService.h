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

/*!
 Initiates a request to a RESTful web resource and provides the server's response in the completion block
 
 @param resource
 Network address of the desired resource
 @param method
 Desired HTTP method (e.g., GET, POST, etc.)
 @param params
 A dictionary of the parameters to include along the request
 @param completionBlock
 Completion block to be executed once the response is received from the server, which passes the response data. Error is non-nil if the request was unsuccessful
 */
- (void)performRequestForResource:(NSString*)resource usingMethod:(NSString*)method withParams:(NSDictionary*)params completionBlock:(void (^)(NSData*, NSError*))completionBlock;

@end
