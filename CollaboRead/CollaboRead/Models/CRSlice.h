//
//  CRSlice.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CRSlice : NSObject

@property (nonatomic, readwrite, strong) NSString *sliceID;
@property (nonatomic, readwrite, strong) NSURL *url;
@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readwrite, assign) BOOL hasDrawing;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
