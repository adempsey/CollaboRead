//
//  CRScan.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRScan.h"
#import "CRSlice.h"
#import "CRCaseKeys.h"

@implementation CRScan

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	if (self = [super init]) {
		self.scanID = dictionary[CR_DB_SCAN_ID];
		self.name = dictionary[CR_DB_SCAN_NAME];
		self.hasDrawing = [dictionary[CR_DB_SCAN_HAS_DRAWING] boolValue];
		self.slices = dictionary[CR_DB_SCAN_SLICES];
	}
	return self;
}

- (void)setSlices:(NSArray *)slices
{
	NSMutableArray *finalArray = [[NSMutableArray alloc] init];
	
	[slices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			CRSlice *slice = [[CRSlice alloc] initWithDictionary:obj];
			[finalArray addObject:slice];
		}
	}];
	
	_slices = finalArray;
}

@end
