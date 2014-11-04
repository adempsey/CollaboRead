//
//  CRNetworkingService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRNetworkingService.h"

#define kHTTP_METHOD_GET @"GET"
#define kHTTP_METHOD_POST @"POST"

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

- (void)performRequestForResource:(NSString*)resource usingMethod:(NSString*)method withParams:(NSDictionary*)params completionBlock:(void (^)(NSData*))completionBlock
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

	if (params) {
		NSString *paramString = [self parameterStringWithDictionary:params];

		if ([method isEqualToString:kHTTP_METHOD_GET]) {
			resource = [NSString stringWithFormat:@"%@?%@", resource, paramString];

		} else if ([method isEqualToString:kHTTP_METHOD_POST]) {
			NSData *encodedParams = [paramString dataUsingEncoding:NSUTF8StringEncoding];
			[request setHTTPBody:encodedParams];

		}
	}

	NSURL *resourceURL = [NSURL URLWithString:resource];
	[request setURL:resourceURL];

	[request setHTTPMethod:method];

	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error ) {
		NSData *escapedData = [self decodeHTMLEntitiesInJSON:data];
		completionBlock(escapedData);
	}];
}

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

- (NSData*)decodeHTMLEntitiesInJSON:(NSData*)json
{
	NSString __block *stringifiedJSON = [NSString stringWithUTF8String:json.bytes];

	NSDictionary *entities = @{
							   @"&lt;"	: @"",
							   @"&gt;"	: @"",
							   @"&amp;"	: @"",
							   @"&quot;": @""
							   };

	[entities enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		stringifiedJSON = [stringifiedJSON stringByReplacingOccurrencesOfString:key withString:obj];
	}];

	return [stringifiedJSON dataUsingEncoding:NSUTF8StringEncoding];
}

@end
