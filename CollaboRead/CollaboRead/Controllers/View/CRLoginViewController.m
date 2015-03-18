//
//  LoginViewController.m
//  CollaboRead
//
//  Checks login information and directs user to appropriate flow based on role
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "CRLoginViewController.h"
#import "CRUserKeys.h"
#import "CRUser.h"
#import "CRSelectCaseViewController.h"
#import "CRSelectLecturerViewController.h"
#import "CRAPIClientService.h"
#import "CRViewSizeMacros.h"
#import "CRErrorAlertService.h"
#import "CRCollaboratorList.h"

#define kActivityIndicatorSize 30.0
typedef NS_ENUM(NSUInteger, kCR_LOGIN_ERRORS) {
	kCR_LOGIN_ERROR_CREDENTIALS = 0,
	kCR_LOGIN_ERROR_NETWORK
};

@interface CRLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (nonatomic, readwrite, strong) UIActivityIndicatorView *activityIndicator;

/*!
 Attempts login with information entered in fields
 */
- (void)attemptLogin;
/*!
 Triggers a login attempt
 @param sender
 UI element triggering method call, unused
 */
- (IBAction)loginPressed:(id)sender;
/*!
 Dismisses keyboard on touch
 @param sender
 UI element triggering method call, unused
 */
- (IBAction)exitTextField:(id)sender; //Dismisses keyboard when appropriate
/*!
 Adjusts UI to show successful login
 */
- (void)showSuccess;
/*!
 Adjusts UI to show login error
 @param error
 Error number to base response type on
 */
- (void)showError:(NSUInteger)error;

@end

@implementation CRLoginViewController

//Sets up activity indicator, other setup done via storyboard
- (void)viewDidLoad
{
	[super viewDidLoad];
	CGRect screenBounds = CR_LANDSCAPE_FRAME;
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((screenBounds.size
        .width - kActivityIndicatorSize)/2, self.loginButton.frame.origin.y, kActivityIndicatorSize,
        kActivityIndicatorSize)];
	[self.view addSubview:self.activityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.loginButton.titleLabel.text = @"Login";
	self.loginButton.userInteractionEnabled = YES;
	
	self.emailField.text = @"";
	self.passwordField.text = @"";
}

-(void)attemptLogin
{
	[[CRAPIClientService sharedInstance] loginUserWithEmail:self.emailField.text password:self.passwordField.text block:^(CRUser *user, NSError *error) {
		if (error) {
			[self showError:kCR_LOGIN_ERROR_CREDENTIALS];
		} else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSuccess];
            });


			UIViewController *newController;
			//Check type of user and make appropriate view

			if ([user.type isEqualToString:CR_USER_TYPE_LECTURER]) {
				UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"caseNavController"];
				((CRSelectCaseViewController *)[navController.childViewControllers objectAtIndex:0]).lecturer = user;
				newController = navController;
				
			} else if([user.type isEqualToString:CR_USER_TYPE_STUDENT]) {
				UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"lectNavController"];
                [[CRCollaboratorList sharedInstance] setOwner];
				newController = navController;
			}

			dispatch_async(dispatch_get_main_queue(), ^{
				// Delay view controller presentation by a bit
				[UIView animateWithDuration:.5 animations:^{
					self.loginButton.alpha = 0.99;
				} completion:^(BOOL finished) {
					[self presentViewController:newController animated:YES completion:nil];
				}];
			});
		}
	}];
}

-(IBAction)loginPressed:(id)sender
{
	self.loginButton.userInteractionEnabled = NO;
	self.loginButton.hidden = YES;

	[self.activityIndicator startAnimating];
	self.activityIndicator.hidden = NO;

	[self attemptLogin];
}

//Dismiss keyboard from a tap outside text fields or end of editting
-(IBAction)exitTextField:(id)sender
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

//Adjust desplay to give user feedback on login credentials
- (void)showSuccess
{
	if (self.errorLabel.alpha > 0.0) {
		[UIView animateWithDuration:0.25 animations:^{
			self.errorLabel.alpha = 0.0;
		}];
	}
	
	NSString *unicodeCheckMark = @"\u2713";
	self.loginButton.titleLabel.text = unicodeCheckMark;

	[self.activityIndicator stopAnimating];
	self.activityIndicator.hidden = YES;

	self.loginButton.hidden = NO;
}

-(void)showError:(NSUInteger)error
{
	if (self.errorLabel.alpha > 0.0) {
		[UIView animateWithDuration:0.25 animations:^{
			self.errorLabel.alpha = 0.0;
		}];
	}

	NSString *errorString = @"Error: ";
	switch (error) {
		case kCR_LOGIN_ERROR_CREDENTIALS:
			errorString = [errorString stringByAppendingString:@"Incorrect username or password."];
			break;
		case kCR_LOGIN_ERROR_NETWORK:
			errorString = [errorString stringByAppendingString:@"Unable to access network. Please try again in a few minutes."];
			break;
		default:
			errorString = @"";
			break;
	}
	
	self.errorLabel.text = errorString;

	[self.activityIndicator stopAnimating];
	self.activityIndicator.hidden = YES;

	self.loginButton.userInteractionEnabled = YES;
	self.loginButton.hidden = NO;

	[UIView animateWithDuration:0.25 animations:^{
		self.errorLabel.alpha = 1.0;
	}];
}

@end
