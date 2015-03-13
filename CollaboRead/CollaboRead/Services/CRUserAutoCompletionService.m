//
//  CRUserAutoCompletionService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/13/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRUserAutoCompletionService.h"

@interface CRUserAutoCompletionService ()

@property (nonatomic, readwrite, strong) NSMutableDictionary *keys;
@property (nonatomic, readwrite, assign) BOOL terminal;

@end

@implementation CRUserAutoCompletionService

+ (CRUserAutoCompletionService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init
{
	if (self = [super init]) {
		self.terminal = NO;
		self.keys = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)insertString:(NSString*)string
{
	if (string.length < 1) {
		self.terminal = YES;
		return;
	}
	
	NSString *key = [string substringToIndex:1];
	
	if (!self.keys[key]) {
		self.keys[key] = [[CRUserAutoCompletionService alloc] init];
	}
	
	[((CRUserAutoCompletionService*) self.keys[key]) insertString:[string substringFromIndex:1]];
}

- (void)insertList:(NSArray*)list
{
	for (NSString* item in list) {
		[self insertString:item.lowercaseString];
	}
}

- (NSArray*)itemsWithPrefix:(NSString *)prefix
{
	NSArray *words = [[NSArray alloc] initWithArray:[self wordsWithPrefix:prefix forList:self]];
	
	NSMutableArray *wordsWithPrefixes = [[NSMutableArray alloc] init];
	
	if (prefix.length > 0) {
		prefix = [prefix substringToIndex:prefix.length - 1];
		
		for (NSString *word in words) {
			[wordsWithPrefixes addObject:[prefix stringByAppendingString:word]];
		}
	}
	
	return wordsWithPrefixes;
}

- (NSArray*)wordsWithPrefix:(NSString*)prefix forList:(CRUserAutoCompletionService*)list
{
	// Traverse prefix trie until we reach the final character of the prefix
	if (prefix.length > 1) {
		NSString *firstChar = [prefix substringToIndex:1];
		return [self wordsWithPrefix:[prefix substringFromIndex:1] forList:list.keys[firstChar]];
	}
	
	// Suffix list is composed of all keys that can follow the given prefix
	CRUserAutoCompletionService *suffixKeys = list.keys[prefix];
	
	// Words will contain all our suffixes
	NSMutableArray *suffixList = [[NSMutableArray alloc] init];
	
	if (suffixKeys.terminal) {
		[suffixList addObject:prefix];
	}
	
	// We first check that our list has keys for the given prefix
	if (list.keys.count > 0 && list.keys[prefix]) {
		
		for (NSString *key in suffixKeys.keys) {
			
			// If a suffix key is non-terminal, recurse into it
			if (((CRUserAutoCompletionService*)suffixKeys.keys[key]).keys.count) {
				NSArray *newListWords = [self wordsWithPrefix:key forList:suffixKeys];
				
				// Add each suffix we found at a deeper level to the suffix list
				for (NSString *word in newListWords) {
					[suffixList addObject:[prefix stringByAppendingString:word]];
				}
				
			} else {
				[suffixList addObject:[prefix stringByAppendingString:key]];
			}
		}
		
		if (suffixList.count == 0) {
			return @[prefix];
		}
	}
	
	return suffixList;
}

@end
