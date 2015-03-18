//
//  CRSlice.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class CRSlice
 
 @discussion Object for storing data about an individual image slice within a scan.
 Slices represent one individual image within a scan.
 It is expected that these will always come in json form from the api
 */
@interface CRSlice : NSObject

/*!
 @brief Slice's ID number
 */
@property (nonatomic, readwrite, strong) NSString *sliceID;

/*!
 @brief URL of the slice's image location
 */
@property (nonatomic, readwrite, strong) NSURL *imageURL;

/*!
 @brief Slice image (set implicitly by imageURL)
 */
//@property (nonatomic, readonly, strong) UIImage *image;
-(UIImage *)image;

/*!
 @brief True if slice has at least one answer drawing
 */
@property (nonatomic, readwrite, assign) BOOL hasDrawing;

/*!
 Initializes CRSlice object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing slice data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;


@end
