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
		self.owners = dictionary[CR_DB_ANSWER_OWNERS];
		self.answerName = dictionary[CR_DB_ANSWER_GROUP_NAME] ? : [CRAccountService sharedInstance].user.name;
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

- (instancetype)initWithData:(NSArray*)answerData submissionDate:(NSDate*)date owners:(NSArray*)owners answerName:(NSString*)answerName answerID:(NSString*)answerID
{
	if (self = [super init]) {
		self.answerID = answerID;
		self.drawings = answerData;
		self.submissionDate = date;
		self.owners = owners;
		self.answerName = answerName ? : [CRAccountService sharedInstance].user.name;
        self.answerColor = [CRAccountService sharedInstance].user.color;
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
			 CR_DB_ANSWER_GROUP_NAME: self.answerName,
             CR_DB_ANSWER_SUBMISSION_DATE: [NSString stringWithFormat:@"%@", self.submissionDate],
			 CR_DB_ANSWER_DRAWINGS: drawingDescriptions};
}

@end
