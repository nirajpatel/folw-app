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
    
    NSMutableAttributedString *passwordAttributedString = [[NSMutableAttributedString alloc] initWithString:@"PASSWORD"];
    [passwordAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 8)];
    _passwordField.attributedText = passwordAttributedString;
    
    NSMutableAttributedString *labelAttributedString = [[NSMutableAttributedString alloc] initWithString:@"SIGN IN"];
    [labelAttributedString addAttribute:NSKernAttributeName
                                     value:@(2.2)
                                     range:NSMakeRange(0, 7)];
    _signInLabel.attributedText = labelAttributedString;
    
    _background.image = [self blurWithCoreImage:_background.image];
    
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

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@10 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
