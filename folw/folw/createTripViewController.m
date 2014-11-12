//
//  createTripViewController.m
//  folw
//
//  Created by Memo on 11/11/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "createTripViewController.h"
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
    [self.addUser addTarget:self action:@selector(addUsers) forControlEvents:UIControlEventTouchUpInside];
    [self.createTrip addTarget:self action:@selector(makeTrip) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addUsers {
    
    // Add people by username
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:self.userToAdd.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            // Should only be one object (one user)
            for (PFObject *object in objects) {
                [self.userList addObject:object.objectId];
            }
        } else {
            // Log details of the failure
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
        trip[@"expired"] = false;
        [trip saveInBackground];
        
        // Take trip id and add to each user
        for (NSString *userId in self.userList) {
            PFQuery *query = [PFQuery queryWithClassName:@"User"];
            [query getObjectInBackgroundWithId:userId block:^(PFObject *user, NSError *error) {
                // Do something with the returned PFObject in the gameScore variable.
                user[@"currentTrip"] = trip.objectId;
            }];
        }
        
        // Take them to map view
        [self performSegueWithIdentifier:@"loadMain" sender:self];
        
    } else {
        self.message.text = @"enter a trip name";
    }
    
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
