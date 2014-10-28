//
//  CRCaseSet.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/27/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRCaseSet : NSObject

@property (nonatomic, readwrite, strong) NSString *setID;
@property (nonatomic, readwrite, strong) NSArray *owners;
@property (nonatomic, readwrite, strong) NSDictionary *cases;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
