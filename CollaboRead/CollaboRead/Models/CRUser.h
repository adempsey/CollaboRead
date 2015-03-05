//
//  CRUser.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 10/28/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class CRUser
 
 @discussion Object for storing individual user data
 */
@interface CRUser : NSObject

/*!
 @brief User's ID number
 */
@property (nonatomic, readwrite, strong) NSString *userID;

/*!
 @brief User's real name
 */
@property (nonatomic, readwrite, strong) NSString *name;

/*!
 @brief The email address associated with the user's account
 */
@property (nonatomic, readwrite, strong) NSString *email;

/*!
 @brief The type of user (e.g., Student, Professor, Administrator)
 */
@property (nonatomic, readwrite, strong) NSString *type;

/*!
 @brief User's title/position, if applicable (e.g., Assistant Professor, Lecturer, etc.)
 */
@property (nonatomic, readwrite, strong) NSString *title;

/*!
 @brief User's graduating class year, if applicable
 */
@property (nonatomic, readwrite, strong) NSString *year;

/*!
 @brief List of case set ID numbers owned by the user, if applicable
 */
@property (nonatomic, readwrite, strong) NSArray *caseSetIDs;

/*!
 @brief URL of the user's avatar
 */
@property (nonatomic, readwrite, strong) NSString *imageURL;

/*!
 @brief Image for the user's avatar (set implicitly by imageURL)
 */
@property (nonatomic, readonly, strong) UIImage *image;

/*!
 Initializes CRUser object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing user data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
