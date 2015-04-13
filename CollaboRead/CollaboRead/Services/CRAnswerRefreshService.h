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
 @brief Lecture to receive updates about
 */
@property (nonatomic, readwrite, strong) NSString *lectureID;

/*!
 Opens socket connection for the given case, also setting currentCase
 @param lectureID
 Lecture to receive updates about
 */
- (void)initiateConnectionWithLecture:(NSString*)lectureID;

/*!
 Ends socket connection for a case
 */
- (void)disconnect;

@end