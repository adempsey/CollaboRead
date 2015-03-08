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
#import "CRAnswerLine.h"
#import "CRSlice.h"

#import "NSDate+CRAdditions.h"

@implementation CRCase

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

-(NSArray *)answerSlicesForScan:(NSString *)scanID {
    NSMutableSet *sliceIds = [[NSMutableSet alloc] init];
    [self.answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CRAnswer *ans = obj;
        [ans.drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswerLine *line = obj;
            if ([line.scanID isEqualToString:scanID]) {
                [sliceIds addObject:line.sliceID];
            }
        }];
    }];
    NSMutableArray *idxs = [[NSMutableArray alloc] init];
    [self.scans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((CRScan *)obj).scanID isEqualToString:scanID]) {
            [((CRScan *)obj).slices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([sliceIds containsObject:((CRSlice *)obj).sliceID]) {
                    [idxs addObject:[NSNumber numberWithUnsignedInteger:idx]];
                }
            }];
            *stop = YES;
        }
    }];
    return idxs;
}

-(NSArray *)answerScans {
    NSMutableSet *scanIds = [[NSMutableSet alloc] init];
    [self.answers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CRAnswer *ans = obj;
        [ans.drawings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CRAnswerLine *line = obj;
            [scanIds addObject:line.scanID];
        }];
    }];
    NSMutableArray *idxs = [[NSMutableArray alloc] init];
    [self.scans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([scanIds containsObject:((CRScan *)obj).scanID]) {
            [idxs addObject:[NSNumber numberWithUnsignedInteger:idx]];
        }
    }];
    return idxs;
}

- (NSInteger)compareDates:(CRCase *)other
{
    if ([self.date isEqualToDate:other.date]) {
        return NSOrderedSame;
    } else if ([[self.date earlierDate:other.date] isEqualToDate:self.date]) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

@end
