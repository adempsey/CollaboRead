//
//  CRAnswerDrawing.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAnswerLine : NSObject

@property (nonatomic, readwrite, strong) NSString *scanID;
@property (nonatomic, readwrite, strong) NSString *sliceID;
@property (nonatomic, readwrite, strong) NSArray *data;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithPoints:(NSArray *)points forSlice:(NSString *)slice ofScan:(NSString *)scan;
- (NSDictionary*)jsonDictionary;

@end
