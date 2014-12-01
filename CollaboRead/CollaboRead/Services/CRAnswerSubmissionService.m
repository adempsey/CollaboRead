//
//  CRAnswerSubmissionService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/30/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswerSubmissionService.h"
#import "CRAnswer.h"

@interface CRAnswerSubmissionService ()

@property (nonatomic, readwrite, strong) SRWebSocket *socket;
@property (nonatomic, readwrite, assign) BOOL open;

@end

@implementation CRAnswerSubmissionService

+ (CRAnswerSubmissionService*)sharedInstance
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
	if (self == [super init]) {
		self.open = NO;
	}
	return self;
}

- (void)dealloc
{
	[self disconnect];
}

- (void)initiateConnection
{
	if (!self.open) {
		NSURL *url = [NSURL URLWithString:@"ws://127.0.0.1:9999/"];
		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
		self.socket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
		self.socket.delegate = self;
		self.open = YES;
		[self.socket open];
	}
}

- (void)disconnect
{
	[self.socket close];
	self.socket = nil;
}

- (void)submitAnswer:(CRAnswer*)answer forCase:(NSString*)caseID inSet:(NSString*)setID
{
	[self.socket send:caseID];
}

#pragma mark - SRWebSocket Delegate Methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	if (self.didReceiveAnswerBlock && [message isKindOfClass:[NSString class]]) {
		self.didReceiveAnswerBlock(message);
	}
}

@end
