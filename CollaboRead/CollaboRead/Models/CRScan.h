//
//  CRScan.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRScan : NSObject

@property (nonatomic, readwrite, strong) NSString *scanID;
@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, assign) BOOL hasDrawing;
@property (nonatomic, readwrite, strong) NSArray *slices;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
