//
//  CRAnswerSubmissionService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/30/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "CRCase.h"

/*!
 @class CRAnswerRefreshService
 @discussion Maintains a websocket connection to receive updates of new answers submitted for a case
 */
@interface CRAnswerRefreshService : NSObject <SRWebSocketDelegate>

+ (CRAnswerRefreshService*)sharedInstance;

/*!
 @brief Block of actions to perform upon receiving notice of an update
 */
@property (nonatomic, readwrite, copy) void (^updateBlock)();
/*!
 @brief Case to receive updates about
 */
@property (nonatomic, readwrite, strong) CRCase *currentCase;

/*!
 Opens socket connection for the given case, also setting currentCase
 @param currentCase
 Case to receive updates for
 */
- (void)initiateConnectionWithCase:(CRCase*)currentCase;
/*!
 Ends socket connection for a case
 */
- (void)disconnect;

@end