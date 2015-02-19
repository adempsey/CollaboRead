//
//  CRAnswerDrawing.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRAnswerLine
 
 @discussion Object for storing an answer's drawing data for a particular slice.
 */
@interface CRAnswerLine : NSObject

/*!
 @brief Corresponding scan's ID number
 */
@property (nonatomic, readwrite, strong) NSString *scanID;

/*!
 @brief Corresponding slice's ID number
 */
@property (nonatomic, readwrite, strong) NSString *sliceID;

/*!
 @brief Array of CRAnswerPoint objects containing drawing coordinates
 */
@property (nonatomic, readwrite, strong) NSArray *data;

/*!
 Initializes CRAnswerLine object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing answer line data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

/*!
 Initializes CRAnswerLine object with data from the supplied parameters
 
 @param points
 Array of CRAnswerPoint objects containing drawing coordinates
 @param slice
 Corresponding slice's ID number
 @param scan
 Corresponding scan's ID number
 */
- (instancetype)initWithPoints:(NSArray *)points forSlice:(NSString *)slice ofScan:(NSString *)scan;

/*!
 Converts object into a dictionary, i.e. JSON representation
 
 @return dictionary containing object values
 */
- (NSDictionary*)jsonDictionary;

@end
