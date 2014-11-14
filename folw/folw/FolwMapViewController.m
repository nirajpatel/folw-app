//
//  FolwMapViewController.m
//  folw
//
//  Created by Brandon Lee on 10/20/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "FolwMapViewController.h"
#import <Parse/Parse.h>

@interface FolwMapViewController ()

@end

@implementation FolwMapViewController

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

    self.users = [[NSArray alloc] init];
    
    PFGeoPoint *leaderPoint;
    
    PFQuery *tripQuery = [PFQuery queryWithClassName:@"Trip"];
    [tripQuery whereKey:@"objectId" equalTo:@"Q6GhUgjbEH"];
    [tripQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.users = [object objectForKey:@"users"];
        
        for(int i = 0; i < sizeof(self.users); i++) {
            PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
            [userQuery whereKey:@"objectId" equalTo:self.users[i]];
            
            [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                PFGeoPoint *point = object[@"currentLocation"];
                
                if(i == 0) {
                    __block PFGeoPoint *leaderPoint = point;
                }
                
                NSString *name = object[@"fullName"];
                
                NSNumber *latNumber = [NSNumber numberWithDouble:point.latitude];
                NSLog(@"%@", latNumber);
                NSString *latitudeString = [latNumber stringValue];
                NSAssert(latitudeString, @"No latitude");
                NSNumber *longNumber = [NSNumber numberWithDouble:point.longitude];
                NSLog(@"%@", longNumber);
                
                NSString *longitudeString = [longNumber stringValue];
                NSAssert(longitudeString, @"No longitude");

                // create the annotation and add it to the map
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = CLLocationCoordinate2DMake([latitudeString doubleValue], [longitudeString doubleValue]);
                annotation.title = name;
                [self.mapView addAnnotation:annotation];
                
            }];
        }
        
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.userLocation.location.coordinate, MKCoordinateSpanMake(leaderPoint.latitude, leaderPoint.longitude));
        region.span = MKCoordinateSpanMake(0.5, 0.597129);
        [self.mapView setRegion:region];
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];

    }];
    

    
//    for(NSString *user in users) {
//        NSLog(@"%@", user);
//        PFQuery *userQuery = [PFQuery queryWithClassName:@"User"];
//        [userQuery whereKey:@"objectId" equalTo:user];
//        NSArray *coArray = [userQuery findObjects];
//        PFGeoPoint *coordinates = coArray[0];
//        NSLog(@"%f", coordinates.latitude);
//        
//        //user pin goes here
//        NSNumber *latNumber = [NSNumber numberWithDouble:coordinates.latitude];
//        NSLog(@"%@", latNumber);
//        NSString *latitudeString = [latNumber stringValue];
//        NSAssert(latitudeString, @"No latitude");
//        NSNumber *longNumber = [NSNumber numberWithDouble:coordinates.longitude];
//        NSLog(@"%@", longNumber);
//        
//        NSString *longitudeString = [longNumber stringValue];
//        NSAssert(longitudeString, @"No longitude");
//        
//        // create the annotation and add it to the map
//        
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//        annotation.coordinate = CLLocationCoordinate2DMake([latitudeString doubleValue], [longitudeString doubleValue]);
//        annotation.title = @"driver2";
//        annotation.subtitle = @"driver2";
//        [self.mapView addAnnotation:annotation];
//    }

}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation
{
    self.mapView.centerCoordinate = userLocation.location.coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
