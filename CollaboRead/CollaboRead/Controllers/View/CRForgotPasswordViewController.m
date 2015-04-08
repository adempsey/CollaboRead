//
//  CRForgotPasswordViewController.m
//  CollaboRead
//
//  Created by Andrew Dempsey on 3/10/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRForgotPasswordViewController.h"
#import "CRAPIClientService.h"
#import "CRColors.h"

#import "UILabel+CRAdditions.h"

@interface CRForgotPasswordViewController ()

/*!
 @brief Scroll view to move text fields above keyboard
 */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/*!
 @brief Label to notify user of instructions
 */
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
/*!
 @brief Field for user to enter email associated with an account
 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
/*!
 @brief Button to perform reset
 */
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
/*!
 @brief Activity indicator to show attempt to reset
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
/*!
 @brief Label to indicate successful reset
 */
@property (weak, nonatomic) IBOutlet UILabel *successMark;
/*!
 @brief Label to inform user of next steps
 */
@property (weak, nonatomic) IBOutlet UILabel *successInstructionsLabel;
/*!
 @brief Button to dismiss form upon completion
 */
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

/*!
 Dismisses view controller
 @param sender
 UI element that triggered call, unused
 */
- (IBAction)dismiss:(id)sender;

/*!
 Attempts password reset
 @param sender
 UI element that triggered call, unused
 */
- (IBAction)reset:(id)sender;

@end

@implementation CRForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.activityIndicator.hidden = YES;
    self.navigationController.view.layer.borderColor = CR_COLOR_TINT.CGColor;
    self.view.layer.borderColor = CR_COLOR_TINT.CGColor;
    self.navigationController.view.layer.borderWidth = 3.0;
    self.view.layer.borderWidth = 3.0;
}

- (IBAction)dismiss:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reset:(id)sender
{
	[self.view endEditing:YES];
	
	self.resetButton.userInteractionEnabled = NO;
	self.resetButton.hidden = YES;
	
	[self.activityIndicator startAnimating];
	self.activityIndicator.hidden = NO;
	
	[[CRAPIClientService sharedInstance] resetPasswordForAccountWithEmail:self.emailTextField.text block:^(NSError *error) {
		if (error) {
			self.activityIndicator.hidden = YES;
			[self.activityIndicator stopAnimating];
			
			self.resetButton.hidden = NO;
			self.resetButton.userInteractionEnabled = YES;
			
			[self.instructionsLabel fadeToVisibility:NO completion:^{
				self.instructionsLabel.text = @"Error sending reset request. Please try again later.";
				self.instructionsLabel.textColor = CR_COLOR_ERROR;
				
				[self.instructionsLabel fadeToVisibility:YES];
			}];
		} else {
			[self.navigationItem setLeftBarButtonItem:nil animated:YES];
			
			[UIView animateWithDuration:0.25 animations:^{
				self.scrollView.alpha = 0.0;

			} completion:^(BOOL finished) {
				self.successMark.hidden = NO;
				self.successInstructionsLabel.hidden = NO;
				self.doneButton.hidden = NO;

				[UIView animateWithDuration:0.25 animations:^{
					self.successMark.alpha = 1.0;
					self.successInstructionsLabel.alpha = 1.0;
					self.doneButton.alpha = 1.0;
				}];
			}];
		}
	}];
}

@end
