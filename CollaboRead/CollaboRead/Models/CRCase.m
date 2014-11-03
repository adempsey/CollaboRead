//
//  CRCase.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/27/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CRCase.h"
#import "CRCaseKeys.h"
#import "CRAnswer.h"

@implementation CRCase

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.caseID = dictionary[CR_DB_CASE_ID];
		self.name = dictionary[CR_DB_CASE_NAME];
		self.date = dictionary[CR_DB_CASE_DATE];
		self.images = dictionary[CR_DB_CASE_IMAGE_LIST];
		self.answers = dictionary[CR_DB_CASE_ANSWER_LIST];
		self.lecturerAnswers = dictionary[CR_DB_CASE_ANSWER_LECTURER];
	}
	return self;
}

- (void)setImages:(NSArray *)images
{
	NSMutableArray *caseImages = [[NSMutableArray alloc] init];

	[images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSString class]]) {
			NSURL *imageURL = [NSURL URLWithString:obj];
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
			[caseImages addObject:image];

		} else if ([obj isKindOfClass:[UIImage class]]) {
			[caseImages addObject:obj];
		}
	}];

	_images = caseImages;
}

- (void)setAnswers:(NSArray *)answers
{
	NSMutableArray *caseAnswers = [[NSMutableArray alloc] init];

	[answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			CRAnswer *answer = [[CRAnswer alloc] initWithDictionary:obj];
			[caseAnswers addObject:answer];

		} else if ([obj isKindOfClass:[CRAnswer class]]) {
			[caseAnswers addObject:obj];
		}
	}];

	_answers = caseAnswers;
}

@end
