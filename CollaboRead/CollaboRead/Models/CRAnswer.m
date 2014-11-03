//
//  CRAnswer.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswer.h"

#import "NSDate+CRAdditions.h"

#define kANSWER_DATA @"answerData"
#define kANSWER_SUBMISSION_DATE @"submissionDate"
#define kANSWER_OWNERS @"owners"

@implementation CRAnswer

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.answerData = dictionary[kANSWER_DATA];
		self.submissionDate = [NSDate dateFromJSONString:dictionary[kANSWER_SUBMISSION_DATE]];
		self.owners = dictionary[kANSWER_OWNERS];
	}
	return self;
}

- (instancetype)initWithData:(NSArray*)answerData submissionDate:(NSDate*)date owners:(NSArray*)owners
{
	if (self = [super init]) {
		self.answerData = answerData;
		self.submissionDate = date;
		self.owners = owners;
	}
	return self;
}

@end
