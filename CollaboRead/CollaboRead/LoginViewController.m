//
//  LoginViewController.m
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#import "LoginViewController.h"
#import "UserKeys.h"
#import "LecturerCasesViewController.h"

@interface LoginViewController ()
{
    NSURLConnection *currentConnection;
}
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

-(IBAction)loginPressed:(id)sender;
-(IBAction)exitTextField:(id)sender;
-(void)attemptLogin:(NSArray *)users;

@end

@implementation LoginViewController

-(void)attemptLogin:(NSArray *)users
{
    NSDictionary *currUser;
    if ([users count] > 0) {
        currUser = [users objectAtIndex:0];
        for (int i = 1; i < [users count] && ![[currUser objectForKey:EMAIL] isEqualToString:self.emailField.text]; i++) {
            currUser = [users objectAtIndex:i];
        }
        if ([[currUser objectForKey:EMAIL] isEqualToString:self.emailField.text]) {
            if ([[currUser objectForKey:PASS] isEqualToString:self.passwordField.text]) {
                NSLog(@"good");
                UIViewController *newController;
                if ([[currUser objectForKey:TYPE] isEqualToString:LECTURER]) {
                    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
                    ((LecturerCasesViewController *)[navController.childViewControllers objectAtIndex:0]).lecturer = currUser;
                    newController = navController;
                }
                [self presentViewController:newController animated:NO completion:nil];
            }
            else{
                NSLog(@"Incorrect Password");
            }
        }
        else {
            NSLog(@"No Matching User");
        }
    }
}

-(IBAction)loginPressed:(id)sender
{
    NSString *urlString = @"http://collaboread.herokuapp.com/users";
    NSURL *reqUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:reqUrl];
    if (currentConnection) {
        [currentConnection cancel];
        currentConnection = nil;
    }
    currentConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(IBAction)exitTextField:(id)sender
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    currentConnection = nil;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Error: %@", error);
    connection = nil;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error;
    NSArray *users =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self attemptLogin:users];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    currentConnection = nil;
}





@end
