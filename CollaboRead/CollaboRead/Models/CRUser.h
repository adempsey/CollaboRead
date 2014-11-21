//
//  CRUser.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/28/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CRUser : NSObject

@property (nonatomic, readwrite, strong) NSString *userID;
@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSString *title;
@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *type;
@property (nonatomic, readwrite, strong) NSString *imageURL;
@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readwrite, assign) NSString *year;
@property (nonatomic, readwrite, strong) NSArray *caseSetIDs;

// temporary - should remove once authentication's a thing
@property (nonatomic, readwrite, strong) NSString *password;

//Translate from JSON to Objective C object
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
