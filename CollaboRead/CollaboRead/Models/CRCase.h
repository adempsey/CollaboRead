//
//  CRCase.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/27/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRCase
 
 @discussion Object for storing data about an individual case.
 Cases represent one individual question to be asked in a lecture, which may contain several scans.
 */
@interface CRCase : NSObject

/*!
 @brief Case's ID number
 */
@property (nonatomic, readwrite, strong) NSString *caseID;

/*!
 @brief Case's title
 */
@property (nonatomic, readwrite, strong) NSString *name;

/*!
 @brief Date case was created
 */
@property (nonatomic, readwrite, strong) NSDate *date;

/*!
 @brief Array of CRScan objects that compose the case
 */
@property (nonatomic, readwrite, strong) NSArray *scans;

/*!
 @brief Array of CRAnswer objects for answers submitted by students
 */
@property (nonatomic, readwrite, strong) NSArray *answers;

/*!
 @brief Text information about the case supplied by the case creator
 */
@property (nonatomic, readwrite, strong) NSString *patientInfo;

/*!
 Initializes CRCase object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing scan data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

/*!
 Method to determine indices of slices with answers for given scan
 
 @param scanID
 Scan to search for answers on
 
 @return Array of indices of slices with answers for scan
 */
- (NSArray *)answerSlicesForScan:(NSString *)scanID;

/*!
 Method used to sort cases by date
 
 @param other
 Secondary CRCase object to use for comparison
 
 @return Integer object to use for sorting
 */
- (NSInteger)compareDates:(CRCase *)other;

@end
