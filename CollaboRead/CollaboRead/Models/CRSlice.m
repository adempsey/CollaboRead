//
//  CRSlice.m
//  CollaboRead
//
//  Created by Hannah Clark on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRSlice.h"

#define kSLICE_ID @"sliceID"
#define kSLICE_IMAGE_URL @"url"
#define kSLICE_ANSWER @"hasDrawing"

@implementation CRSlice

-(instancetype)initWithJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.sliceID = dict[kSLICE_ID];
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:dict[kSLICE_IMAGE_URL]]];
        self.hasAnswer = [dict[kSLICE_ANSWER] boolValue];
    }
    return self;
}

@end
