//
//  SignInViewController.m
//  folw
//
//  Created by Memo on 10/19/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "SignInViewController.h"
#import <Parse/Parse.h>

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.signInButton addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signIn {
    [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text
        block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
            self.messageLabel.text = @"Successful Login";
        } else {
           // The login failed. Check error to see why.
            NSString *errorString = [error userInfo][@"error"];
            self.messageLabel.text = errorString;
        }
    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
