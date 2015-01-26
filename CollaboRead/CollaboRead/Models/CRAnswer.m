//
//  CRAnswer.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswer.h"
#import "CRAnswerLine.h"
#import "CRAnswerPoint.h"
#import "CRCaseKeys.h"

#import "NSDate+CRAdditions.h"
#import "NSDictionary+CRAdditions.h"

#define kANSWER_SLICE @""
#define kANSWER_SCAN @""

@implementation CRAnswer

//Translate JSON dictionary of an answer into app useable objective c object
- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.answerID = dictionary[CR_DB_ANSWER_ID];
		self.owners = dictionary[CR_DB_ANSWER_OWNERS];
		self.submissionDate = dictionary[CR_DB_ANSWER_SUBMISSION_DATE];
		
		NSMutableArray *drawings = [[NSMutableArray alloc] init];
		for (NSDictionary *drawing in dictionary[CR_DB_ANSWER_DRAWINGS]) {
			CRAnswerLine *answerDrawing = [[CRAnswerLine alloc] initWithDictionary:drawing];
			[drawings addObject:answerDrawing];
		}
		self.drawings = drawings;
	}
	return self;
}

//Create an answer from data provide by app
- (instancetype)initWithData:(NSArray*)drawings submissionDate:(NSDate*)date owners:(NSArray*)owners answerID:(NSString*)answerID
{
	if (self = [super init]) {
		self.answerID = answerID;
		self.drawings = drawings;
		self.submissionDate = date;
		self.owners = owners;
	}
	return self;
}

- (NSDictionary*)jsonDictionary
{
	NSMutableArray *drawingDescriptions = [[NSMutableArray alloc] init];
	[self.drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[CRAnswerLine class]]) {
			[drawingDescriptions addObject:((CRAnswerLine*)obj).jsonDictionary];
		}
	}];
#warning wrong date
	return @{CR_DB_ANSWER_ID: self.answerID,
			 CR_DB_ANSWER_OWNERS: self.owners,
			 CR_DB_ANSWER_SUBMISSION_DATE: @"january 25",
			 CR_DB_ANSWER_DRAWINGS: drawingDescriptions};
}

@end
