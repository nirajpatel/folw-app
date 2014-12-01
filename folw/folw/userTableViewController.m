//
//  userTableViewController.m
//  folw
//
//  Created by Comyar Zaheri on 11/30/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "userTableViewController.h"
#import <Parse/Parse.h>

@interface userTableViewController () {
    dispatch_queue_t _background_queue;
}

@property (nonatomic) NSMutableArray *usernames;

@end

@implementation userTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _background_queue = dispatch_queue_create("user_background_queue", DISPATCH_QUEUE_SERIAL);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"userTableCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.usernames = nil;
    dispatch_async(_background_queue, ^ {
        NSMutableArray *usernames = [NSMutableArray new];
        for (NSString *userId in self.userList) {
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:@"objectId" equalTo:userId];
            PFObject *object = [query getFirstObject];
            [usernames addObject:object[@"username"]];
        }
        self.usernames = usernames;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.usernames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userTableCell" forIndexPath:indexPath];
    cell.textLabel.text = self.usernames[indexPath.row];
    
    // Configure the cell...
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.usernames removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}






@end
