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

typedef NS_ENUM(NSUInteger, kCR_LOGIN_ERRORS) {
	kCR_LOGIN_ERROR_CREDENTIALS = 0
};

@interface CRLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (nonatomic, readwrite, strong) UIActivityIndicatorView *activityIndicator;

-(IBAction)loginPressed:(id)sender;
-(IBAction)exitTextField:(id)sender;
-(void)attemptLogin:(NSArray *)users;

@end

@implementation CRLoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	CGRect screenBounds = [UIScreen mainScreen].bounds;
	CGFloat activityIndicatorSize = 30.0;
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((screenBounds.size.width - activityIndicatorSize)/2,
																					   self.loginButton.frame.origin.y,
																					   activityIndicatorSize,
																					   activityIndicatorSize)];
	[self.view addSubview:self.activityIndicator];
}

-(void)attemptLogin:(NSArray *)users
{
    //Try to authenticate users
    CRUser *currUser;
    if ([users count] > 0) {
        //Find matching user from list
        currUser = [users objectAtIndex:0];
		for (int i = 1; i < [users count] && ![currUser.email isEqualToString:self.emailField.text]; i++) {
            currUser = [users objectAtIndex:i];
        }
        //Check that user was found, (list didn't run out)
		if ([currUser.email isEqualToString:self.emailField.text]) {
            //Check password
			if ([currUser.password isEqualToString:self.passwordField.text]) {

				[self showSuccess];

                UIViewController *newController;
                //Check type of user and make appropriate view
				if ([currUser.type isEqualToString:CR_USER_TYPE_LECTURER]) {
                    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"caseNavController"];
                    ((CRSelectCaseViewController *)[navController.childViewControllers objectAtIndex:0]).lecturer = currUser;
                    ((CRSelectCaseViewController *)[navController.childViewControllers objectAtIndex:0]).user = currUser;
                    newController = navController;
                }
                else if([currUser.type isEqualToString:CR_USER_TYPE_STUDENT]) {
                    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"lectNavController"];
                    ((CRSelectLecturerViewController *)[navController.childViewControllers objectAtIndex:0]).user = currUser;
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
            //Password was incorrect
            else{
				[self showError:kCR_LOGIN_ERROR_CREDENTIALS];
            }
        }
        //Username was incorrect
        else {
			[self showError:kCR_LOGIN_ERROR_CREDENTIALS];
        }
    }
}

//Start attempt to login with api call
-(IBAction)loginPressed:(id)sender
{
	self.loginButton.userInteractionEnabled = NO;
	self.loginButton.hidden = YES;

	[self.activityIndicator startAnimating];
	self.activityIndicator.hidden = NO;

    //When the information comes back, execute attemptLogin: with it
	[[CRAPIClientService sharedInstance] retrieveUsersWithBlock:^(NSArray* users) {
		[self attemptLogin:users];
	}];
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

- (void)showSuccess
{
	NSString *unicodeCheckMark = @"\u2713";
	self.loginButton.titleLabel.text = unicodeCheckMark;

	[self.activityIndicator stopAnimating];
	self.activityIndicator.hidden = YES;

	self.loginButton.hidden = NO;
}

-(void)showError:(NSUInteger)error
{
	NSString *errorString = @"Error: ";
	if (error == kCR_LOGIN_ERROR_CREDENTIALS) {
		errorString = [errorString stringByAppendingString:@"Incorrect username or password"];
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
