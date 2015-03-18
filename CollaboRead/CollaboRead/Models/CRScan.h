//
//  CRScan.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 1/24/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class CRScan
 
 @discussion Object for storing data about an individual scan
 Scans represent one image set of a case - e.g., a set of slices from a sagittal view, etc.
 It is expected that these will always come in json form from the api
 */
@interface CRScan : NSObject

/*!
 @brief Scan's ID number
 */
@property (nonatomic, readwrite, strong) NSString *scanID;

/*!
 @brief Title of the scan
 */
@property (nonatomic, readwrite, strong) NSString *name;

/*!
 @brief True if scan has at least one answer drawing
 */
@property (nonatomic, readwrite, assign) BOOL hasDrawing;

/*!
 @brief List of CRSlices that compose the scan's images. Can be set from CRSlice or dictionary objects
 */
@property (nonatomic, readwrite, strong) NSArray *slices;

/*!
 Initializes CRScan object with data from the supplied dictionary
 
 @param dictionary
 Dictionary with keys and values containing scan data
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
