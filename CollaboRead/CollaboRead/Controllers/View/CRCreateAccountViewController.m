//
//  CRCreateAccountViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 2/19/15.
//  Copyright (c) 2015 CollaboRead. All rights reserved.
//

#import "CRCreateAccountViewController.h"
#import "CRColors.h"

@interface CRCreateAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *roleSelector;
@property (weak, nonatomic) IBOutlet UITextField *yearTitleField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordCheckField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)registerAccount:(id)sender;
-(BOOL)validEmail:(NSString *)email;
@end

@implementation CRCreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.textColor = CR_COLOR_ERROR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)registerAccount:(id)sender {
    self.errorLabel.hidden = YES;
    if ([self.emailField.text isEqualToString:@""] || ![self validEmail: self.emailField.text]) {
        self.errorLabel.text = @"Invalid email";
        self.errorLabel.hidden = NO;
    } else if ([self.nameField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Empty names are invalid";
        self.errorLabel.hidden = NO;
    } else if ([self.passwordField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Empty passwords are invalid";
        self.errorLabel.hidden = NO;
    } else if ([self.passwordField.text isEqualToString:self.passwordCheckField.text]) {
        self.errorLabel.text = @"Passwords do not match";
        self.errorLabel.hidden = NO;
    } else {
        //make call to register, do stuff with button
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end