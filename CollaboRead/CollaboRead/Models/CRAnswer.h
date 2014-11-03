//
//  CRAnswer.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAnswer : NSObject

@property (nonatomic, readwrite, strong) NSArray *answerData;
@property (nonatomic, readwrite, strong) NSDate *submissionDate;
@property (nonatomic, readwrite, strong) NSArray *owners;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithData:(NSArray*)answerData submissionDate:(NSDate*)date owners:(NSArray*)owners;

@end
