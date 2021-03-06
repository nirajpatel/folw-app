//
//  SignInViewController.m
//  folw
//
//  Created by Memo on 10/19/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "SignInViewController.h"
#import <Parse/Parse.h>
#import "createTripViewController.h"
#import "FolwMapViewController.h"

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
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    // Do any additional setup after loading the view.
    [self.view addSubview:self.signInButton];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    //KERNING
    NSMutableAttributedString *usernameAttributedString = [[NSMutableAttributedString alloc] initWithString:@"USERNAME"];
    [usernameAttributedString addAttribute:NSKernAttributeName
                             value:@(2.2)
                             range:NSMakeRange(0, 8)];
    _userNameField.attributedText = usernameAttributedString;
    
    [_userNameField setLeftViewMode:UITextFieldViewModeAlways];
    _userNameField.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"username.png"]];
    
    NSMutableAttributedString *passwordAttributedString = [[NSMutableAttributedString alloc] initWithString:@"PASSWORD"];
    [passwordAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 8)];
    _passwordField.attributedText = passwordAttributedString;
    
    [_passwordField setLeftViewMode:UITextFieldViewModeAlways];
    _passwordField.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password.png"]];
    
    NSMutableAttributedString *labelAttributedString = [[NSMutableAttributedString alloc] initWithString:@"SIGN IN"];
    [labelAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 7)];
    _signInLabel.attributedText = labelAttributedString;
    
    _userId = [[NSString alloc] init];
    
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
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

- (UIButton *)signInButton {
    _signInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _signInButton.frame = CGRectMake(110, 340, 100, 36);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"LOGIN"];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(2.2)
                             range:NSMakeRange(0, 5)];
    [_signInButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    _signInButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:13.f];
    _signInButton.titleLabel.textColor = [UIColor colorWithRed:0.188 green:0.188 blue:0.188 alpha:1];
    
    _signInButton.layer.borderColor = [UIColor colorWithRed:0.188 green:0.188 blue:0.188 alpha:1].CGColor;
    _signInButton.layer.borderWidth = 1.0f;
    _signInButton.layer.cornerRadius = 2.0f;
    
    [_signInButton addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    
    return _signInButton;
}

- (void)signIn {
    [PFUser logInWithUsernameInBackground:self.userNameField.text password:self.passwordField.text
        block:^(PFUser *user, NSError *error) {
        if (user) {
            // Successful login.
            _userId = user.objectId;
            NSLog(@"user id %@", _userId);
            
            // Check if user current trip is still valid
            NSString *tripId = user[@"currentTrip"];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Trip"];
            [query getObjectInBackgroundWithId:tripId block:^(PFObject *trip, NSError *error) {
                BOOL tripExpired = [trip[@"expired"] boolValue];

                if(trip == nil) {
                    // if no trip, take them to create trip view
                    [self performSegueWithIdentifier:@"createTrip" sender:self];
                }
                // if NO, direct user to map view
                else if(!tripExpired) {
                    _tripId = tripId;

                    [self performSegueWithIdentifier:@"loadMain" sender:self];
                }
                else {
                    // if expired, take them to create trip view
                    [self performSegueWithIdentifier:@"createTrip" sender:self];
                }
            }];
                
        } else {
           // The login failed. Check error to see why.
            NSString *errorString = [error userInfo][@"error"];
            _messageLabel.text = errorString;
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createTrip"]) {
        [segue.destinationViewController setUserId:_userId];
    } else if ([segue.identifier isEqualToString:@"loadMain"]) {
        [segue.destinationViewController setTripId:_tripId];
        [segue.destinationViewController setUserId:_userId];
    }
}

@end
