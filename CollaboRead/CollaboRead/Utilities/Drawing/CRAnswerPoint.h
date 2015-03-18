//
//  CRAnswerPoint.h
//  CollaboRead
//
//  Holds a point in a line of an answer drawing.
//
//  Created by Hannah Clark on 10/11/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class CRAnswerPoint
 
 @discussion Object for storing a point of an answer in a way that renders the redrawing possible.
 */

@interface CRAnswerPoint : NSObject <NSCopying>
/*!
 @brief Actual location on image scaled to screen
 */
@property (nonatomic, assign) CGPoint coordinate;
/*!
 @brief If the point should be connected to the next point in the answer when redrawn
 */
@property (nonatomic, assign) BOOL isEndPoint;

/*!
 Initializes CRAnswerPoint object with data from the supplied dictionary
 
 @param dict
 Dictionary with keys and values containing point data
 */
-(id)initFromJSONDict:(NSDictionary *)dict;

/*!
 Initializes CRAnswerPoint object for the given point and endpoint values
 
 @param point
 CGPoint of the appropriate location
 
 @param end
 YES if the point is the endpoint of its section of line, otherwise NO
 */
-(id)initWithPoint:(CGPoint)point end:(BOOL)end;
/*!
 Compares equality of the point with some other object
 
 @param object
 Object to compare to the point
 
 @return YES if the points are equivalent, otherwise NO
 */
-(BOOL)isEqual:(id)object;
/*!
 Compares relative of the point with some other object
 
 @param object
 Object to compare location fo to the point
 
 @return YES if object is a CRAnswerPoint within touch range of the point, otherwise NO
 */
-(BOOL)isInTouchRange:(id)object; //Used to determine erase radius
/*!
 Creates deep copy of the point
 
 @return copy of the point with the same values
 */
-(id)copyWithZone:(NSZone *)zone;
/*!
 Converts object into a dictionary, i.e. JSON representation
 
 @return dictionary containing object values
 */
-(NSDictionary *)jsonDictFromPoint;

/*!
 Converts object into a dictionary, i.e. JSON representation
 
 @return dictionary containing object values
 */
//-(NSString*)jsonString;

@end
