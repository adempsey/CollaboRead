//
//  CRSlice.h
//  CollaboRead
//
//  Created by Hannah Clark on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CRSlice : NSObject

@property (nonatomic, strong) NSString *sliceID;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL hasAnswer;


-(instancetype) initWithJSON:(NSDictionary *)dict;

@end
