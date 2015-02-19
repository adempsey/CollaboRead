//
//  CRAnswerDrawing.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRAnswerLine.h"
#import "CRAnswerPoint.h"
#import "CRCaseKeys.h"

@implementation CRAnswerLine

- (instancetype)initWithPoints:(NSArray *)points forSlice:(NSString *)slice ofScan:(NSString *)scan
{
	self = [super init];
	if (self) {
		self.scanID = scan;
		self.sliceID = slice;
		self.data = points;
	}
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.scanID = dictionary[CR_DB_DRAWING_SCAN_ID];
		self.sliceID = dictionary[CR_DB_DRAWING_SLICE_ID];
		self.data = dictionary[CR_DB_DRAWING_DATA];
	}
	return self;
}

- (void)setData:(NSArray *)data
{
	NSMutableArray *finalArray = [[NSMutableArray alloc] init];
	
	[data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			CRAnswerPoint *answerPoint = [[CRAnswerPoint alloc] initFromJSONDict:obj];
			[finalArray addObject:answerPoint];
		}
		else if ([obj isKindOfClass:[CRAnswerPoint class]])
			[finalArray addObject:obj];
	}];
	
	_data = finalArray;
}

- (NSDictionary*)jsonDictionary
{
	NSMutableArray *answerPointDescriptions = [[NSMutableArray alloc] init];
	
	[self.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (![obj isKindOfClass:[NSDictionary class]]) {
			[answerPointDescriptions addObject:((CRAnswerPoint*)obj).jsonDictFromPoint];
		}
	}];
	
	return @{CR_DB_DRAWING_SCAN_ID: self.scanID,
			 CR_DB_DRAWING_SLICE_ID: self.sliceID,
			 CR_DB_DRAWING_DATA: answerPointDescriptions};
}

@end
