//
//  CRScan.m
//  CollaboRead
//
//  Created by Hannah Clark on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRScan.h"
#import "CRSlice.h"

#define kSCAN_ID @""
#define kSCAN_SLICES @""
#define kSCAN_ANSWER @""
#define kSCAN_NAME @""

@implementation CRScan

-(instancetype)initWithJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.slices = dict[kSCAN_SLICES];
        self.scanid = dict[kSCAN_ID];
        self.name = dict[kSCAN_NAME];
        self.hasAnswer = [dict[kSCAN_ANSWER] boolValue];
    }
    return self;
}

-(void)setSlices:(NSArray *)slices
{
    NSMutableArray *newSlices = [[NSMutableArray alloc] init];
    
    [slices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            CRSlice *slice = [[CRSlice alloc] initWithJSON:obj];
            [newSlices addObject:slice];
            
        } else if ([obj isKindOfClass:[UIImage class]]) {
            [newSlices addObject:obj];
        }
    }];
    
    _slices = newSlices;
}


@end
