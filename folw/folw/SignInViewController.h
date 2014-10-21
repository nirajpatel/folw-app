//
//  SignInViewController.h
//  folw
//
//  Created by Memo on 10/19/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *background;

@end
