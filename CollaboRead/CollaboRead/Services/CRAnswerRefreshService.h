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

@interface CRAnswerRefreshService : NSObject <SRWebSocketDelegate>

+ (CRAnswerRefreshService*)sharedInstance;

@property (nonatomic, readwrite, copy) void (^updateBlock)();
@property (nonatomic, readwrite, strong) CRCase *currentCase;

- (void)initiateConnectionWithCase:(CRCase*)currentCase;
- (void)disconnect;

@end