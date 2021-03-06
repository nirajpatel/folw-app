//
//  createTripViewController.h
//  folw
//
//  Created by Memo on 11/11/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface createTripViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tripName;
@property (weak, nonatomic) IBOutlet UITextField *userToAdd;
@property (weak, nonatomic) IBOutlet UITextField *destination;

@property (weak, nonatomic) IBOutlet UIButton *addUser;
@property (weak, nonatomic) IBOutlet UIButton *createTrip;
@property (weak, nonatomic) IBOutlet UIButton *currentPeople;

@property (nonatomic, strong) NSMutableArray *userList;
@property (weak, nonatomic) IBOutlet UILabel *message;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *tripId;

@property (nonatomic, strong) NSString *latDest;
@property (nonatomic, strong) NSString *lonDest;


- (void)addUsers;

@end
