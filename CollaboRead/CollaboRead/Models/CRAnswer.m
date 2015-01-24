//
//  CRAnswer.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswer.h"
#import "CRAnswerPoint.h"

#import "NSDate+CRAdditions.h"

#define kANSWER_DATA @"answerData"
#define kANSWER_SUBMISSION_DATE @"submissionDate"
#define kANSWER_OWNERS @"owners"

#define kANSWER_SLICE @""
#define kANSWER_SCAN @""

@implementation CRAnswer

//Translate JSON dictionary of an answer into app useable objective c object
- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
        NSMutableArray *points = [[NSMutableArray alloc] init];
        for (NSDictionary *pt in dictionary[kANSWER_DATA]) {
            [points addObject: [[CRAnswerPoint alloc] initFromJSONDict:pt]];
        }
        self.answerData = points;
		self.submissionDate = [NSDate dateFromJSONString:dictionary[kANSWER_SUBMISSION_DATE]];
		self.owners = dictionary[kANSWER_OWNERS];
        //self.scanID = dictionary[kANSWER_SCAN];
        //self.sliceID = dictionary[kANSWER_SLICE];
	}
	return self;
}

//Create an answer from data provide by app
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
