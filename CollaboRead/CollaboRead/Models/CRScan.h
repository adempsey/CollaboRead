//
//  CRScan.h
//  CollaboRead
//
//  Created by Hannah Clark on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRScan : NSObject

@property (nonatomic, retain) NSString *scanid;
@property (nonatomic, retain) NSArray *slices;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL hasAnswer;

-(instancetype)initWithJSON:(NSDictionary *)dict;

@end
