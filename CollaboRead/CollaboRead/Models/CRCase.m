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
#import "CRScan.h"
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
		self.scans = dictionary[CR_DB_CASE_SCANS];
		self.answers = dictionary[CR_DB_CASE_ANSWERS];
        self.patientInfo = dictionary[CR_DB_PATIENT_INFO];
	}
	return self;
}

- (void)setScans:(NSArray *)scans
{
	NSMutableArray *finalArray = [[NSMutableArray alloc] init];
	
	[scans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			CRScan *scan = [[CRScan alloc] initWithDictionary:obj];
			[finalArray addObject:scan];
		}
	}];
	
	_scans = finalArray;
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
