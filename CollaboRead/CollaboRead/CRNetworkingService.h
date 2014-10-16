//
//  CRNetworkingService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRNetworkingService : NSObject

+ (CRNetworkingService*)sharedInstance;
- (void)performGETRequestForResource:(NSString*)resource withParams:(NSDictionary*)params completionBlock:(void (^)(NSData*))completionBlock;

@end
