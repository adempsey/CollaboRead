//
//  CRCreateAccountViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/19/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRCreateAccountViewController.h"
#import "CRColors.h"
#import "CRAPIClientService.h"
#import "CRErrorAlertService.h"
#import "CRUser.h"
#import "CRUserKeys.h"

#import "UILabel+CRAdditions.h"

@interface CRCreateAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yearSelector;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordCheckField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *successCheckMark;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *successMessage;

- (IBAction)registerAccount:(id)sender;
- (IBAction)switchRole:(UISegmentedControl *)sender;
- (IBAction)done:(id)sender;
- (BOOL)validEmail:(NSString *)email;
- (void)registerForKeyboardNotifications;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)toggleActivityIndicator;
- (void)performRegistration;

@end

@implementation CRCreateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.errorLabel.textColor = CR_COLOR_ERROR;
    self.errorLabel.hidden = YES;
    [self registerForKeyboardNotifications];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchRole:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.titleLabel.hidden = YES;
        self.yearLabel.hidden = NO;
    } else {
        self.yearLabel.hidden = YES;
        self.titleLabel.hidden = NO;
    }
}

- (void)toggleActivityIndicator
{
    if (self.activityIndicator.hidden) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (IBAction)registerAccount:(id)sender
{
	[self.view endEditing:YES];
    if ([self.emailField.text isEqualToString:@""] || ![self validEmail: self.emailField.text]) {
		[self.errorLabel animateTransitionToText:@"Invalid email format"];
		
    } else if ([self.nameField.text isEqualToString:@""]) {
		[self.errorLabel animateTransitionToText:@"Empty names are invalid"];
		
    } else if ([self.passwordField.text isEqualToString:@""]) {
		[self.errorLabel animateTransitionToText:@"Empty passwords are invalid"];
		
    } else if (![self.passwordField.text isEqualToString:self.passwordCheckField.text]) {
		[self.errorLabel animateTransitionToText:@"Passwords do not match"];
		
    } else {
        self.registerButton.hidden = YES;
        self.cancelButton.enabled = NO;
        [self performSelector:@selector(toggleActivityIndicator) withObject:nil afterDelay:0.0];
        [self performSelector:@selector(performRegistration) withObject:nil afterDelay:0.0];
    }
}

- (void)performRegistration {
    CRUser *user = [[CRUser alloc] init];
    user.email = self.emailField.text;
    user.name = self.nameField.text;
    user.type = CR_USER_TYPE_STUDENT;
	user.year = [NSString stringWithFormat:@"%ld", (long) self.yearSelector.selectedSegmentIndex + 1];
	user.title = @"";

    [[CRAPIClientService sharedInstance] registerUser:user password:self.passwordField.text block:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{

            [self toggleActivityIndicator];
            if (error) {
                self.registerButton.hidden = NO;
				[self.errorLabel animateTransitionToText:@"Registration unsuccessful. Please try again later."];

            } else {
				
				[UIView animateWithDuration:0.25 animations:^{
					self.scrollView.alpha = 0.0;
				} completion:^(BOOL finished) {
					[self showSuccessInfo];
				}];
            }
            
        });
    }];
}

- (void)showSuccessInfo
{
	self.successCheckMark.hidden = NO;
	self.doneButton.hidden = NO;
	self.successMessage.hidden = NO;
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[UIView animateWithDuration:0.25 animations:^{
		self.successCheckMark.alpha = 1.0;
		self.doneButton.alpha = 1.0;
		self.successMessage.alpha = 1.0;
	}];
}

- (BOOL)validEmail:(NSString *)email {
    if ([email componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].count < 2) {
        NSArray *halves = [email componentsSeparatedByString:@"@"];
        if (halves.count == 2) {
            if([[halves objectAtIndex:1] componentsSeparatedByString:@"."].count > 1) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailField]) {
        [textField resignFirstResponder];
        [self.nameField becomeFirstResponder];
    }
    else if ([textField isEqual:self.nameField]) {
        [textField resignFirstResponder];
    }
    else if ([textField isEqual:self.passwordField]) {
        [textField resignFirstResponder];
        [self.passwordCheckField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordCheckField]) {
        [textField resignFirstResponder];
    }
    return NO;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect keyPadFrame=[[UIApplication sharedApplication].keyWindow convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:self.view];
    CGSize kbSize =keyPadFrame.size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect activeRect=[self.view convertRect:self.activeField.frame fromView:self.activeField.superview];
    CGRect aRect = self.view.bounds;
    aRect.size.height -= (kbSize.height);
    
    CGPoint origin =  activeRect.origin;
    origin.y -= self.scrollView.contentOffset.y;
    origin.y += activeRect.size.height;
    if (!CGRectContainsPoint(aRect, origin)) {
        CGPoint scrollPoint = CGPointMake(0.0,CGRectGetMaxY(activeRect)-(aRect.size.height));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

@end
