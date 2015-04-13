//
//  CRAnswerSubmissionService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/30/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswerRefreshService.h"
#import "CRAnswer.h"
#import "CRNotifications.h"

#define kCR_API_ADDRESS @"ws://collaboread.herokuapp.com/"

#define kCR_API_WS_MESSAGE_UPDATE @"UPDATE"
#define kCR_API_WS_MESSAGE_INTRO @"INTRO"

#define kCR_REFRESH_RATE 3.0

@interface CRAnswerRefreshService ()

/*!
 @brief Socket used for the connection
 */
@property (nonatomic, readwrite, strong) SRWebSocket *socket;

/*!
 @brief Whether the connection is open
 */
@property (nonatomic, readonly, assign) BOOL open;

/*!
 @brief Timer to handle checks to maintain connection
 */
@property (nonatomic, readwrite, strong) NSTimer *refreshTimer;

/*!
 Recovers connection to current case, used when the socket fails
 */
- (void)recoverConnection;

/*!
 Pings the socket, used to check presence of a connection
 */
- (void)ping;

@end

@implementation CRAnswerRefreshService

+ (CRAnswerRefreshService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (BOOL)open
{
	return self.socket.readyState == SR_OPEN;
}

- (void)dealloc
{
	[self disconnect];
}

- (void)setRefreshTimer:(NSTimer *)refreshTimer
{
	[_refreshTimer invalidate];
	_refreshTimer = refreshTimer;
}

- (void)initiateConnectionWithLecture:(NSString *)lectureID
{
	if (!self.open) {
		self.lectureID = lectureID;
		NSURL *url = [NSURL URLWithString:kCR_API_ADDRESS];
		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
		self.socket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
		self.socket.delegate = self;
		[self.socket open];
	}
}

- (void)disconnect
{
	[self.refreshTimer invalidate];
	[self.socket close];
	self.socket = nil;
}

- (void)ping
{
	if (self.open) {
		[self.socket sendPing:nil];
		
	} else if (!self.open && self.socket) {
		//Disconnected unexpectedly
		[self recoverConnection];
	}
}

- (void)recoverConnection
{
	[self.refreshTimer invalidate];
	[self initiateConnectionWithLecture:self.lectureID];
}

#pragma mark - SRWebSocket Delegate Methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	if ([message isEqualToString:kCR_API_WS_MESSAGE_UPDATE]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:CR_NOTIFICATION_REFRESH_ANSWERS object:nil];
	}
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kCR_REFRESH_RATE
														 target:self
													   selector:@selector(ping)
													   userInfo:nil
														repeats:YES];
	
	NSString *introMessage = [NSString stringWithFormat:@"%@:%@",kCR_API_WS_MESSAGE_INTRO, self.lectureID];
	[self.socket send:introMessage];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
	self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kCR_REFRESH_RATE
														 target:self
													   selector:@selector(recoverConnection)
													   userInfo:nil
														repeats:YES];
}

@end
