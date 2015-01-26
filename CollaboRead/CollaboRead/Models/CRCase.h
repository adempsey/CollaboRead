//
//  CRCase.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/27/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRCase : NSObject

@property (nonatomic, readwrite, strong) NSString *caseID;
@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSDate *date;
@property (nonatomic, readwrite, strong) NSArray *scans;
@property (nonatomic, readwrite, strong) NSArray *answers;
@property (nonatomic, readwrite, strong) NSString *patientInfo;

//Translate from JSON to Objective C object
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

//Use for sorting array of cases by ascending dates
-(NSInteger)compareDates:(CRCase *)other;
@end
