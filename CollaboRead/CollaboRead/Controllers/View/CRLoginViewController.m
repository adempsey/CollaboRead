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
#import "UserKeys.h"
#import "CRSelectCaseViewController.h"
#import "CRSelectLecturerViewController.h"
#import "CRAPIClientService.h"

@interface CRLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

-(IBAction)loginPressed:(id)sender;
-(IBAction)exitTextField:(id)sender;
-(void)attemptLogin:(NSArray *)users;

@end

@implementation CRLoginViewController


-(void)attemptLogin:(NSArray *)users
{
    //Try to authenticate users
    NSDictionary *currUser;
    if ([users count] > 0) {
        //Find matching user from list
        currUser = [users objectAtIndex:0];
        for (int i = 1; i < [users count] && ![[currUser objectForKey:EMAIL] isEqualToString:self.emailField.text]; i++) {
            currUser = [users objectAtIndex:i];
        }
        //Check that user was found, (list didn't run out)
        if ([[currUser objectForKey:EMAIL] isEqualToString:self.emailField.text]) {
            //Check password
            if ([[currUser objectForKey:PASS] isEqualToString:self.passwordField.text]) {
                NSLog(@"good");
                UIViewController *newController;
                //Check type of user and make appropriate view
                if ([currUser[TYPE] isEqualToString:LECTURER]) {
                    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"caseNavController"];
                    ((CRSelectCaseViewController *)[navController.childViewControllers objectAtIndex:0]).lecturer = currUser;
                    ((CRSelectCaseViewController *)[navController.childViewControllers objectAtIndex:0]).user = currUser;
                    newController = navController;
                }
                else if([currUser[TYPE] isEqualToString:STUDENT]) {
                    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"lectNavController"];
                    ((CRSelectLecturerViewController *)[navController.childViewControllers objectAtIndex:0]).user = currUser;
                    newController = navController;
                }

				dispatch_async(dispatch_get_main_queue(), ^{
					[self presentViewController:newController animated:NO completion:nil];
				});
            }
            //Password was incorrect
            else{
                NSLog(@"Incorrect Password");
            }
        }
        //Username was incorrect
        else {
            NSLog(@"No Matching User");
        }
    }
}

//Start attempt to login with api call
-(IBAction)loginPressed:(id)sender
{
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

@end
