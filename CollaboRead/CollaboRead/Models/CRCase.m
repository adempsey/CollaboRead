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
#import "CRAPIClientService.h"
#import "NSDate+CRAdditions.h"

@implementation CRCase
//Translate from JSON to Objective C object
- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.caseID = dictionary[CR_DB_CASE_ID];
		self.name = dictionary[CR_DB_CASE_NAME];
		self.date = [NSDate dateFromJSONString: dictionary[CR_DB_CASE_DATE]];
		self.images = dictionary[CR_DB_CASE_IMAGE_LIST];
		self.answers = dictionary[CR_DB_CASE_ANSWER_LIST];
		self.lecturerAnswers = dictionary[CR_DB_CASE_ANSWER_LECTURER];
        
	}
	return self;
}

//Custom setter sets image access urls dependent on server used
- (void)setImages:(NSArray *)images
{
	NSMutableArray *caseImages = [[NSMutableArray alloc] init];

	[images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSString class]]) {

//			NSString *serverAddress = [[CRAPIClientService sharedInstance] serverAddress];

			NSString *urlString;
			// temporary for usability test
//			if ([serverAddress isEqualToString:@"http://collaboread.herokuapp.com"]) {
				urlString = obj;
//			} else {
//				urlString = [NSString stringWithFormat:@"%@/~AMD/cr/%@", serverAddress, obj];
//			}

			NSURL *imageURL = [NSURL URLWithString:urlString];
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
			[caseImages addObject:image];

		} else if ([obj isKindOfClass:[UIImage class]]) {
			[caseImages addObject:obj];
		}
	}];

	_images = caseImages;
}

//Custom setter translates answer json into answer object if needed
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
-(NSInteger)compareDates:(CRCase *)other
{
    if ([self.date isEqualToDate:other.date]) {
        return NSOrderedSame;
    }
    else if ([[self.date earlierDate:other.date] isEqualToDate:self.date])
    {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

@end
