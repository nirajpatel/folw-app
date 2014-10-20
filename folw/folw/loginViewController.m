//
//  loginViewController.m
//  folw
//
//  Created by Niraj Patel on 10/20/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "loginViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface loginViewController ()

@end

@implementation loginViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addSubview:self.loginButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)loginButton {
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginButton.frame = CGRectMake(110, 440, 100, 36);
    [_loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:13.f];
    _loginButton.titleLabel.textColor = [UIColor colorWithRed:0.188 green:0.188 blue:0.188 alpha:1];
    
    _loginButton.layer.borderColor = [UIColor blackColor].CGColor;
    _loginButton.layer.borderWidth = 1.0f;
    _loginButton.layer.cornerRadius = 2.0f;
    
    return _loginButton;
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
