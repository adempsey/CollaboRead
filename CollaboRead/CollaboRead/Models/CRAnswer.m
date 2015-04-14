//
//  CRAnswer.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRAnswer.h"
#import "CRAnswerLine.h"
#import "CRCaseKeys.h"
#import "CRAccountService.h"

@implementation CRAnswer

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.answerID = dictionary[CR_DB_ANSWER_ID];
		self.lectureID = dictionary[CR_DB_ANSWER_LECTURE];
		self.caseID = dictionary[CR_DB_ANSWER_CASE];
		self.owners = dictionary[CR_DB_ANSWER_OWNERS];
		self.groupName = dictionary[CR_DB_ANSWER_GROUP_NAME];
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

- (instancetype)initWithData:(NSArray*)answerData submissionDate:(NSDate*)date owners:(NSArray*)owners answerName:(NSString*)answerName answerID:(NSString*)answerID inCase:(NSString *)caseID forLecture:(NSString *)lectureID
{
	if (self = [super init]) {
		self.answerID = answerID;
		self.drawings = answerData;
		self.submissionDate = date;
		self.owners = owners;
		self.groupName = answerName;
        self.caseID = caseID;
        self.lectureID = lectureID;
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

	return @{CR_DB_ANSWER_ID: self.answerID,
			 CR_DB_ANSWER_OWNERS: self.owners,
             CR_DB_ANSWER_LECTURE: self.lectureID,
             CR_DB_ANSWER_CASE: self.caseID,
			 CR_DB_ANSWER_GROUP_NAME: self.groupName,
             CR_DB_ANSWER_SUBMISSION_DATE: [NSString stringWithFormat:@"%@", self.submissionDate],
			 CR_DB_ANSWER_DRAWINGS: drawingDescriptions};
}

@end
