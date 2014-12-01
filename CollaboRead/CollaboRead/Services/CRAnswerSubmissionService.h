//
//  CRAnswerSubmissionService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/30/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "CRAnswer.h"

@interface CRAnswerSubmissionService : NSObject <SRWebSocketDelegate>

@property (nonatomic, readwrite, copy) void (^didReceiveAnswerBlock)(NSString*);

+ (CRAnswerSubmissionService*)sharedInstance;

- (void)initiateConnection;
- (void)disconnect;

- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inSet:(NSString*)setID;

@end