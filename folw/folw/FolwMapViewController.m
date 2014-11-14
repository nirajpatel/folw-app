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
    [tripQuery whereKey:@"objectId" equalTo:_tripId];
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
        
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = leaderPoint.latitude; // your latitude value
        zoomLocation.longitude= leaderPoint.longitude; // your longitude value
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=0.18; // change as per your zoom level
        span.longitudeDelta=0.18;
        region.span=span;
        region.center= zoomLocation;
        
        [self.mapView setRegion:region animated:YES];
        [self.mapView regionThatFits:region];


    }];
    
}

-(void)setTripId:(NSString *)tripId
{
    _tripId = tripId;
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
