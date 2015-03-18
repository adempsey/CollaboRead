//
//  CRUserAutoCompletionService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/13/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRUserAutoCompletionService
 
 @discussion Given a list of names, provides autocompletion suggestions
 */
@interface CRUserAutoCompletionService : NSObject
+ (CRUserAutoCompletionService*)sharedInstance;

/*!
 Gets autocomplete options for a given string prefix
 @param prefix
 Prefix to search for completions for
 @return
 List of strings with given prefix
 */
- (NSArray*)itemsWithPrefix:(NSString*)prefix;
/*!
 Adds a string to options for autocomplete
 @param string
 String to add to autocomplete options
 */
- (void)insertString:(NSString*)string;
/*!
 Adds a list of strings to options for autocomplete
 @param list
 Array of strings to add to autocomplete options
 */
- (void)insertList:(NSArray*)list;

@end
