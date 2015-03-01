//
//  CRNetworkingService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRNetworkingService.h"
#import "CRAuthenticationService.h"

#define kHTTP_METHOD_GET @"GET"
#define kHTTP_METHOD_POST @"POST"

#define kCR_API_QUERY_PARAMETER_USER_EMAIL @"email"
#define kCR_API_QUERY_PARAMETER_USER_PASSWORD @"password"

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

- (void)performRequestForResource:(NSString*)resource usingMethod:(NSString*)method withParams:(NSDictionary*)params completionBlock:(void (^)(NSData*, NSError*))completionBlock
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

	if (params) {
		NSString *paramString = [self parameterStringWithDictionary:params];

		// HTTP GET requests append parameters to the end of the URL
		if ([method isEqualToString:kHTTP_METHOD_GET]) {
			resource = [NSString stringWithFormat:@"%@?%@", resource, paramString];

		// HTTP POST requests set the request body as the parameter string
		} else if ([method isEqualToString:kHTTP_METHOD_POST]) {
			NSData *encodedParams = [paramString dataUsingEncoding:NSUTF8StringEncoding];
			[request setHTTPBody:encodedParams];
		}
	}

	NSURL *resourceURL = [NSURL URLWithString:resource];
	[request setURL:resourceURL];

	[request setHTTPMethod:method];

	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error ) {
		completionBlock(data, error);
	}];
}

- (void)performAuthenticatedRequestForResource:(NSString *)resource usingMethod:(NSString *)method withParams:(NSDictionary *)params completionBlock:(void (^)(NSData *, NSError *))completionBlock
{
	NSMutableDictionary *authenticatedParams;
 
	if (params) {
		authenticatedParams = [params mutableCopy];
	} else {
		authenticatedParams = [[NSMutableDictionary alloc] init];
	}

	authenticatedParams[kCR_API_QUERY_PARAMETER_USER_EMAIL] = [[CRAuthenticationService sharedInstance] email];
	authenticatedParams[kCR_API_QUERY_PARAMETER_USER_PASSWORD] = [[CRAuthenticationService sharedInstance] password];
	
	[self performRequestForResource:resource usingMethod:method withParams:authenticatedParams completionBlock:completionBlock];
}

#pragma mark - Helper Methods

/*!
 Converts a dictionary of request parameters into a string for requests
 
 @param dictionary
 Dictionary containing the parameter keys and values to be used in the request
 
 @return Properly formatted parameter string with the dictionary's keys and values
 */
- (NSString*)parameterStringWithDictionary:(NSDictionary*)dictionary
{
	NSString *queryString = @"";

	for (NSString* key in dictionary) {
		NSString *queryParameter = [NSString stringWithFormat:@"%@=%@&", key, dictionary[key]];
		queryString = [queryString stringByAppendingString:queryParameter];
	}

	// Remove trailing '&' character
	return [queryString substringToIndex:queryString.length-1];
}

@end
