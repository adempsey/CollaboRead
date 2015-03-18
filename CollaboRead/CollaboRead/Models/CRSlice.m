//
//  CRSlice.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRSlice.h"
#import "CRCaseKeys.h"

@interface CRSlice ()
/*!
 @brief Image for the slice
 @warning Don't set this property manually. It is lazily initialized from the imageURL
 */
@property (nonatomic, strong) UIImage *image;
@end

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

//Sets the url, and clears the data of the image so that it will reflect the new URL at the next access
- (void)setImageURL:(NSURL *)url
{
    _image = nil;
	_imageURL = url;
}

//Accesses the image, retrieving it from the URL if necessary
-(UIImage *)image {
    if (_image == nil) {
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
        _image = [UIImage imageWithData:imageData];
    }
    return _image;
}

@end
