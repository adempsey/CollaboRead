//
//  CRAnswerSubmissionService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/30/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswerRefreshService.h"
#import "CRAnswer.h"

#define kCR_API_ADDRESS @"ws://collaboread.herokuapp.com/"

#define kCR_REFRESH_RATE 1.0

@interface CRAnswerRefreshService ()

/*!
 @brief Socket used for the connection
 */
@property (nonatomic, readwrite, strong) SRWebSocket *socket;
/*!
 @brief Whether the connection is open
 */
@property (nonatomic, readwrite, assign) BOOL open;
/*!
 @brief Last  message recieved
 */
@property (nonatomic, readwrite, strong) NSString *lastUpdate;
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

- (instancetype)init
{
	if (self = [super init]) {
		self.open = NO;
	}
	return self;
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

- (void)initiateConnectionWithCase:(CRCase*)currentCase
{
	if (!self.open) {
		self.currentCase = currentCase;
		NSURL *url = [NSURL URLWithString:kCR_API_ADDRESS];
		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
		self.socket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
		self.socket.delegate = self;
		[self.socket open];
		self.open = YES;
	}
}

- (void)disconnect
{
	[self.refreshTimer invalidate];
	self.open = NO;
	[self.socket close];
	self.socket = nil;
}

- (void)ping
{
	if (self.open) {
		[self.socket send:self.currentCase.caseID];
	}
}

- (void)recoverConnection
{
	[self initiateConnectionWithCase:self.currentCase];
}

#pragma mark - SRWebSocket Delegate Methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	if (message && [message isKindOfClass:[NSString class]]) {
		if (self.lastUpdate && ![self.lastUpdate isEqualToString:message]) {
			self.updateBlock();
			self.lastUpdate = message;
		} else if (!self.lastUpdate) {
			self.lastUpdate = message;
		}
	}
}
//These make sure the connection is maintained
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kCR_REFRESH_RATE
														 target:self
													   selector:@selector(ping)
													   userInfo:nil
														repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
	[self disconnect];
	self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kCR_REFRESH_RATE
														 target:self
													   selector:@selector(recoverConnection)
													   userInfo:nil
														repeats:YES];
}

@end
