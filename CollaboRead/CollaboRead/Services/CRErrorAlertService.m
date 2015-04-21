//
//  CRErrorAlertService.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/17/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRErrorAlertService.h"
#import "CRColors.h"

@implementation CRErrorAlertService

+ (CRErrorAlertService*)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (UIAlertController*)networkErrorAlertForItem:(NSString*)item completionBlock:(void (^)(UIAlertAction*))block;
{
	NSString *message = [NSString stringWithFormat:@"Unable to load %@. Please try again in a few minutes.", item];
    if (!block) {
        block = ^(UIAlertAction *action) {};
    }
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:block];
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
																			 message:message
																	  preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:okAction];
	alertController.view.tintColor = CR_COLOR_PRIMARY;
	return alertController;
}

@end
