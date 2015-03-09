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

@interface CRCreateAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *roleSelector;
@property (weak, nonatomic) IBOutlet UITextField *yearTitleField;
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.textColor = CR_COLOR_ERROR;
    self.errorLabel.hidden = YES;
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)switchRole:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.titleLabel.hidden = YES;
        self.yearLabel.hidden = NO;
    } else {
        self.yearLabel.hidden = YES;
        self.titleLabel.hidden = NO;
    }
}

-(void)toggleActivityIndicator {
    if (self.activityIndicator.hidden) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

-(IBAction)registerAccount:(id)sender {
    self.errorLabel.hidden = YES;
    if ([self.emailField.text isEqualToString:@""] || ![self validEmail: self.emailField.text]) {
        self.errorLabel.text = @"Invalid email format";
        self.errorLabel.hidden = NO;
    } else if ([self.nameField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Empty names are invalid";
        self.errorLabel.hidden = NO;
    } else if ([self.passwordField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Empty passwords are invalid";
        self.errorLabel.hidden = NO;
    } else if (![self.passwordField.text isEqualToString:self.passwordCheckField.text]) {
        self.errorLabel.text = @"Passwords do not match";
        self.errorLabel.hidden = NO;
    } else {
        self.registerButton.hidden = YES;
        self.cancelButton.enabled = NO;
        [self performSelector:@selector(toggleActivityIndicator) withObject:nil afterDelay:0.0];
        [self performSelector:@selector(performRegistration) withObject:nil afterDelay:0.0];
    }
}

-(void)performRegistration {
    CRUser *user = [[CRUser alloc] init];
    user.email = self.emailField.text;
    user.name = self.nameField.text;
    user.type = self.roleSelector.selectedSegmentIndex == 0 ? CR_USER_TYPE_STUDENT : CR_USER_TYPE_LECTURER;
    user.year = self.roleSelector.selectedSegmentIndex == 0 ? self.yearTitleField.text : @"0";
    user.title = self.roleSelector.selectedSegmentIndex == 0 ? CR_USER_TYPE_STUDENT : self.yearTitleField.text;
    user.type = self.roleSelector.selectedSegmentIndex == 0 ? CR_USER_TYPE_STUDENT : CR_USER_TYPE_LECTURER;
    [[CRAPIClientService sharedInstance] registerUser:user password:self.passwordField.text block:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self toggleActivityIndicator];
            if (error) {
                self.registerButton.hidden = NO;
                self.errorLabel.text = @"Registration unsuccessful";
                self.errorLabel.hidden = NO;
                self.cancelButton.enabled = YES;
            } else {
                self.errorLabel.textColor = [UIColor whiteColor];
                self.errorLabel.text = @"Account successfully registered";
                self.errorLabel.hidden = NO;
                self.doneButton.hidden = NO;
            }
            
        });
    }];

}

-(BOOL)validEmail:(NSString *)email {
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailField]) {
        [textField resignFirstResponder];
        [self.nameField becomeFirstResponder];
    }
    else if ([textField isEqual:self.nameField]) {
        [textField resignFirstResponder];
    }
    else if ([textField isEqual:self.yearTitleField]) {
        [textField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
