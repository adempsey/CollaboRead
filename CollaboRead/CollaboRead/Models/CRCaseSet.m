//
//  CRCaseSet.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/27/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRCaseSet.h"
#import "CRCase.h"
#import "CRCaseKeys.h"

@implementation CRCaseSet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	if (self = [super init]) {
		self.setID = dictionary[CR_DB_CASE_SET_ID];
		self.owners = dictionary[CR_DB_CASE_SET_OWNERS];
		self.cases = dictionary[CR_DB_CASE_SET_CASE_LIST];
	}
	return self;
}

- (void)setCases:(NSDictionary *)cases
{
	NSMutableDictionary *casesDictionary = [[NSMutableDictionary alloc] init];

	[cases enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			CRCase *crCase = [[CRCase alloc] initWithDictionary:obj];
			casesDictionary[key] = crCase;

		} else if ([obj isKindOfClass:[CRCase class]]) {
			casesDictionary[key] = obj;
		}
	}];

	_cases = casesDictionary;
}

@end
