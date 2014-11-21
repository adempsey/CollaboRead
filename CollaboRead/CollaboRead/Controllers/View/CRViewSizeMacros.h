//
//  CRViewSizeMacros.h
//  CollaboRead
//
//  Use to determine size of view elements rather than doing so directly in most cases because of
//  conflicts in behavior between iOS 7 and 8
//
//  Created by Hannah Clark on 11/12/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#ifndef CollaboRead_CRViewSizeMacros_h
#define CollaboRead_CRViewSizeMacros_h

#define kNavigationBarHeight 44

#define LANDSCAPE_FRAME ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:\
        NSNumericSearch] == NSOrderedAscending) ? \
        CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, \
        [UIScreen mainScreen].bounds.size.width) : [UIScreen mainScreen].bounds

#define TOP_BAR_HEIGHT ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:\
        NSNumericSearch] == NSOrderedAscending) ? \
        kNavigationBarHeight + \
        [UIApplication sharedApplication].statusBarFrame.size.width : \
        kNavigationBarHeight + \
        [UIApplication sharedApplication].statusBarFrame.size.height

#define STATUS_BAR_HEIGHT ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:\
        NSNumericSearch] == NSOrderedAscending) ? \
        [UIApplication sharedApplication].statusBarFrame.size.width : \
        [UIApplication sharedApplication].statusBarFrame.size.height


#endif
