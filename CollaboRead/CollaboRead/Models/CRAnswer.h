//
//  CRAnswer.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAnswer : NSObject

@property (nonatomic, readwrite, strong) NSString *answerID;
@property (nonatomic, readwrite, strong) NSArray *drawings;//Data that can be used to recreate answer
@property (nonatomic, readwrite, strong) NSDate *submissionDate;//Create Date
@property (nonatomic, readwrite, strong) NSArray *owners;//Submitting users
@property (nonatomic, strong) NSString *scanID;
@property (nonatomic, strong) NSString *sliceID;

//Translate JSON dictionary of an answer into app useable objective c object
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
//Create an answer from data provide by app
- (instancetype)initWithData:(NSArray*)answerData submissionDate:(NSDate*)date owners:(NSArray*)owners answerID:(NSString*)answerID;

- (NSDictionary*)jsonDictionary;

@end
