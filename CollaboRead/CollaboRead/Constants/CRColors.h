//
//  CRColors.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 11/4/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#ifndef CollaboRead_CRColors_h
#define CollaboRead_CRColors_h

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define CR_COLOR_PRIMARY UIColorFromRGB(0x1C1B1C)
//#define CR_COLOR_SECONDARY UIColorFromRGB(0x525252)
#define CR_COLOR_TINT UIColorFromRGB(0xBAE7CA)
#define CR_COLOR_ERROR UIColorFromRGB(0xFF4760)
#define CR_COLOR_ANSWER_INDICATOR [UIColor yellowColor]

#define studentColors @[@{@"red":@0, @"green": @255, @"blue" : @0}, \
@{@"red":@0, @"green": @0, @"blue" : @255}, \
@{@"red":@255, @"green": @255, @"blue" : @0}, \
@{@"red":@255, @"green": @0, @"blue" : @255}, \
@{@"red":@0, @"green": @255, @"blue" : @255}, \
@{@"red":@255, @"green": @150, @"blue" : @100}, \
@{@"red":@175, @"green": @255, @"blue" : @50}, \
@{@"red":@175, @"green": @255, @"blue" : @255}, \
@{@"red":@175, @"green": @100, @"blue" : @255}, \
@{@"red":@175, @"green": @255, @"blue" : @200}, \
@{@"red":@255, @"green": @50, @"blue" : @100}, \
@{@"red":@150, @"green": @150, @"blue" : @255}, \
@{@"red":@255, @"green": @200, @"blue" : @255}, \
@{@"red":@0, @"green": @150, @"blue" : @150}, \
@{@"red":@150, @"green": @100, @"blue" : @100}]

#endif
