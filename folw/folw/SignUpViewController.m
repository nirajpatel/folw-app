//
//  SignUpViewController.m
//  folw
//
//  Created by Memo on 10/19/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [self.view addSubview:self.signUpButton];
    
    //KERNING
    NSMutableAttributedString *fullNameAttributedString = [[NSMutableAttributedString alloc] initWithString:@"FULL NAME"];
    [fullNameAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 8)];
    _fullNameField.attributedText = fullNameAttributedString;
    
    NSMutableAttributedString *usernameAttributedString = [[NSMutableAttributedString alloc] initWithString:@"USERNAME"];
    [usernameAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 8)];
    _usernameField.attributedText = usernameAttributedString;
    
    NSMutableAttributedString *emailAttributedString = [[NSMutableAttributedString alloc] initWithString:@"EMAIL"];
    [emailAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 4)];
    _emailField.attributedText = emailAttributedString;
    
    NSMutableAttributedString *passwordAttributedString = [[NSMutableAttributedString alloc] initWithString:@"PASSWORD"];
    [passwordAttributedString addAttribute:NSKernAttributeName
                                  value:@(2.2)
                                  range:NSMakeRange(0, 7)];
    _passwordField.attributedText = passwordAttributedString;
    
    NSMutableAttributedString *labelAttributedString = [[NSMutableAttributedString alloc] initWithString:@"SIGN UP"];
    [labelAttributedString addAttribute:NSKernAttributeName
                                  value:@(2.2)
                                  range:NSMakeRange(0, 7)];
    _signUpLabel.attributedText = labelAttributedString;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [_fullNameField resignFirstResponder];
    [_emailField resignFirstResponder];
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];

}

- (void)signUp {
    PFUser *user = [PFUser user];
    
    // User name is email
    user.username = _usernameField.text;
    user.password = _passwordField.text;
    user.email = _emailField.text;
    
    // other fields can be set just like with PFObject
    user[@"fullName"] = _fullNameField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            _messageLabel.text = @"Successful Sign Up";
            [self performSegueWithIdentifier:@"signUpComplete" sender:self];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            _messageLabel.text = errorString;
        }
    }];
}

- (UIButton *)signUpButton {
    _signUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _signUpButton.frame = CGRectMake(110, 400, 100, 36);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"SUBMIT"];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(2.2)
                             range:NSMakeRange(0, 5)];
    [_signUpButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    _signUpButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:13.f];
    _signUpButton.titleLabel.textColor = [UIColor colorWithRed:0.188 green:0.188 blue:0.188 alpha:1];
    
    _signUpButton.layer.borderColor = [UIColor colorWithRed:0.188 green:0.188 blue:0.188 alpha:1].CGColor;
    _signUpButton.layer.borderWidth = 1.0f;
    _signUpButton.layer.cornerRadius = 2.0f;
    
    [_signUpButton addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    
    return _signUpButton;
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
