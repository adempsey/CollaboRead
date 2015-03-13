//
//  CRUserAutoCompletionService.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/13/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRUserAutoCompletionService : NSObject

+ (CRUserAutoCompletionService*)sharedInstance;
- (NSArray*)itemsWithPrefix:(NSString*)prefix;
- (void)insertString:(NSString*)string;
- (void)insertList:(NSArray*)list;

@end
