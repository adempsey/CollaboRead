//
//  CRNetworkingService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRNetworkingService.h"

@implementation CRNetworkingService

+ (CRNetworkingService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)performGETRequestForResource:(NSString*)resource withParams:(NSDictionary*)params completionBlock:(void (^)(NSData*))completionBlock
{
	if (params) {
		NSString *parameterString = [self parameterStringWithDictionary:params];
		resource = [resource stringByAppendingString:parameterString];
	}

	NSURL *url = [NSURL URLWithString:resource];

	NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error){
		if (!error) {
			completionBlock(data);
		}
	}];
	[dataTask resume];
}

- (NSString*)parameterStringWithDictionary:(NSDictionary*)dictionary
{
	NSString *queryString = @"?";

	for (NSString* key in dictionary) {
		NSString *queryParameter = [NSString stringWithFormat:@"%@=%@&", key, dictionary[key]];
		queryString = [queryString stringByAppendingString:queryParameter];
	}

	// Remove trailing '&' character
	return [queryString substringToIndex:queryString.length-1];
}

@end
