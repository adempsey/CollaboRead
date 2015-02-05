//
//  CRSlice.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRSlice.h"
#import "CRCaseKeys.h"

@implementation CRSlice

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	if (self = [super init]) {
		self.sliceID = dictionary[CR_DB_SLICE_ID];
		self.imageURL = [NSURL URLWithString:dictionary[CR_DB_SLICE_URL]];
		self.hasDrawing = [dictionary[CR_DB_SLICE_HAS_DRAWING] boolValue];
	}
	return self;
}

// Implicitly sets value of image property
- (void)setImageURL:(NSURL *)url
{
	NSData *imageData = [NSData dataWithContentsOfURL:url];
	_image = [UIImage imageWithData:imageData];
	_imageURL = url;
}

@end
