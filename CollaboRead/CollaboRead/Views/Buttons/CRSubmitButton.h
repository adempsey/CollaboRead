//
//  CRSubmitButton.h
//  CollaboRead
//
//  Created by Andrew Dempsey on 2/7/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @typedef kCR_SUBMIT_BUTTON_STATES
 @brief Each constant is a state of the answer submission process. The button's appearance should reflect that state.
 
 @constant CR_SUBMIT_BUTTON_STATE_SUBMIT Prompts the user to submit an answer.
 This state should be used if the user has not previously submitted an answer for a case
 @constant CR_SUBMIT_BUTTON_STATE_PENDING The button's interactivity is disabled and shows an activity indicator. 
 This state should be used while the answer submission is pending.
 @constant CR_SUBMIT_BUTTON_STATE_SUCCESS Used if the submission process was successful. 
 The button will automatically set itself to CR_SUBMIT_BUTTON_STATE_SUBMITTED after a brief time period.
 @constant CR_SUBMIT_BUTTON_STATE_ERROR Used if the submission process was unsuccessful. 
 The button will automatically set itself to CR_SUBMIT_BUTTON_STATE_SUBMITTED or CR_SUBMIT_BUTTON_STATE_INITIAL, depending on if the user has submitted successfully in the past or not.
 @constant CR_SUBMIT_BUTTON_STATE_RESUBMIT Prompts the user to re-submit an answer to a case they have previously completed.
 */
typedef NS_ENUM(NSUInteger, kCR_SUBMIT_BUTTON_STATES) {
	CR_SUBMIT_BUTTON_STATE_SUBMIT = 0,
	CR_SUBMIT_BUTTON_STATE_PENDING,
	CR_SUBMIT_BUTTON_STATE_SUCCESS,
	CR_SUBMIT_BUTTON_STATE_ERROR,
	CR_SUBMIT_BUTTON_STATE_RESUBMIT // Show when an answer has previously been submitted
};

/*!
 @class CRSubmitButton
 
 @discussion Button to be used for when the student wishes to submit an answer.
*/
@interface CRSubmitButton : UIButton

/*!
 @brief Change the appearance and title of the button to give appropriate instructions
 and information to the user.
 */
@property (nonatomic, readwrite, assign) NSUInteger buttonState;

@end
