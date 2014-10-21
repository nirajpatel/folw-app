//
//  folwViewController.m
//  folw
//
//  Created by Niraj Patel on 10/16/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "FolwViewController.h"
#import <Parse/Parse.h>

@interface FolwViewController ()

@end

@implementation FolwViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
