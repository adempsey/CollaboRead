//
//  CRUser.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/28/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRUser.h"
#import "CRUserKeys.h"

@interface CRUser ()

/*!
 @brief Image for the user's avatar
 @warning Don't set this property manually. Set implicitly using imageURL instead
 */
@property (nonatomic, readwrite, strong) UIImage *image;

@end

@implementation CRUser

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		self.userID = dictionary[CR_DB_USER_ID];
		self.name = dictionary[CR_DB_USER_NAME];
		self.title = dictionary[CR_DB_USER_TYPE];
		self.email = dictionary[CR_DB_USER_EMAIL];
		self.type = dictionary[CR_DB_USER_TYPE];
		self.imageURL = dictionary[CR_DB_USER_PICTURE];
		self.year = dictionary[CR_DB_USER_YEAR];
		self.caseSetIDs = dictionary[CR_DB_USER_CASE_SETS];
	}
	return self;
}

// Implicitly sets value of image property
- (void)setImageURL:(NSString *)imageURLString
{
	NSURL *imageURL = [NSURL URLWithString:imageURLString];
	self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
	_imageURL = imageURLString;
}

@end
