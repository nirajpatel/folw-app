//
//  createTripViewController.m
//  folw
//
//  Created by Memo on 11/11/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "createTripViewController.h"
#import "FolwMapViewController.h"
#import <Parse/Parse.h>

@interface createTripViewController ()

@end

@implementation createTripViewController

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
    
    // Add user button
    [_addUser addTarget:self action:@selector(addUsers) forControlEvents:UIControlEventTouchUpInside];
    // Make trip button
    [_createTrip addTarget:self action:@selector(makeTrip) forControlEvents:UIControlEventTouchUpInside];
    
    // Initialize user list
    _userList = [[NSMutableArray alloc] init];
    _tripId = [[NSString alloc] init];
    
    [_userList addObject:_userId];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [_tripName resignFirstResponder];
    [_userToAdd resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addUsers {
    // Add people by username
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:self.userToAdd.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSLog(@"HERE");
            // The find succeeded.
            // Should only be one object (one user)
            if (![self.userList containsObject:object.objectId]) {
                [self.userList addObject:object.objectId];
            }
        } else {
            // Show details on the message label
            self.message.text = @"username not found";
        }
    }];
    
}

- (void)makeTrip {
    
    if ([self.tripName hasText]) {
        // Save trip
        PFObject *trip = [PFObject objectWithClassName:@"Trip"];
        trip[@"name"] = self.tripName.text;
        trip[@"users"] = self.userList;
        trip[@"expired"] = @NO;
        [trip save];
        
        self.tripId = [trip objectId];
        
        // Take trip id and add to each user
        for (NSString *userId in self.userList) {
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            [query getObjectInBackgroundWithId:userId block:^(PFObject *user, NSError *error) {
                // Do something with the returned PFObject in the gameScore variable.
                user[@"currentTrip"] = trip.objectId;
                [user save];
            }];
        }
        
        // Take them to map view
        [self performSegueWithIdentifier:@"loadMain" sender:self];
        
    } else {
        self.message.text = @"enter a trip name";
    }
    
}

-(void)setUserId:(NSString *)userId
{
    _userId = userId;
    NSLog(@"id: %@", _userId);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"loadMain"]) {
        [segue.destinationViewController setTripId:self.tripId];
        [segue.destinationViewController setUserId:self.userId];
    }
}

@end
