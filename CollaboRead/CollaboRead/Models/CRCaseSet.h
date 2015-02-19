//
//  CRCaseSet.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/27/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRCaseSet
 
 @discussion Object for storing a list of cases belonging to a series of lecturers
 */
@interface CRCaseSet : NSObject

/*!
 @brief Case set's ID number
 */
@property (nonatomic, readwrite, strong) NSString *setID;

/*!
 @brief List of lecturers that have ownership over the cases
 */
@property (nonatomic, readwrite, strong) NSArray *owners;

/*!
 @brief Dictionary of case objects, keyed by case ID number
 */
@property (nonatomic, readwrite, strong) NSDictionary *cases;

/*!
 Initializes CRCaseSet object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing scan data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
