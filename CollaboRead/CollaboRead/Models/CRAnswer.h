//
//  CRAnswer.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/2/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRAnswer
 
 @discussion Object for storing data about a user's answer for a particular slice.
 */
@interface CRAnswer : NSObject

/*!
 @brief Answer's ID number
 */
@property (nonatomic, readwrite, strong) NSString *answerID;

/*!
 @brief Array of CRAnswerLine objects containing drawing data
 */
@property (nonatomic, readwrite, strong) NSArray *drawings;

/*!
 @brief Date the answer was originally submitted
 */
@property (nonatomic, readwrite, strong) NSDate *submissionDate;

/*!
 @brief Array of users that submitted the answer
 */
@property (nonatomic, readwrite, strong) NSArray *owners;

/*!
 @brief The name displayed if lecturer chooses to reveal identities behind answers
If not explicitly set, default's to the current user's name
 */
@property (nonatomic, readwrite, strong) NSString *answerName;

/*!
 Initializes CRAnswer object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing answer data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

/*!
 Initializes CRAnswer object with data from the supplied parameters
 
 @param answerData
 Array of CRAnswerLine objects containing drawing data
 @param date
 Date the answer was originally submitted
 @param owners
 Array of users that submitted the answer
 @param answerID
 Answer's ID number
 */
- (instancetype)initWithData:(NSArray*)answerData submissionDate:(NSDate*)date owners:(NSArray*)owners answerName:(NSString*)answerName answerID:(NSString*)answerID;

/*!
 Converts object into a dictionary, i.e. JSON representation
 
 @return dictionary containing object values
 */
- (NSDictionary*)jsonDictionary;

@end
