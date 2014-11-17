//
//  FolwMapViewController.m
//  folw
//
//  Created by Brandon Lee on 10/20/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import "FolwMapViewController.h"
#import <Parse/Parse.h>
#import "CustomLocation.h"
#import "createTripViewController.h"

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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.hidesBackButton = YES;

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
                
                //TO DO
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

                CLLocationCoordinate2D coordinate;
                coordinate.latitude = point.latitude;
                coordinate.longitude = point.longitude;
                CustomLocation *annotation = [[CustomLocation alloc] initWithName:name distance:@"0" coordinate:coordinate] ;
                [_mapView addAnnotation:annotation];
            }];
        }
        
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        self.mapView.showsPointsOfInterest = NO;
        
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
    
    _endTrip.target = self;
    _endTrip.action = @selector( endTrip: );
    
}

-(void) endTrip:(id)sender {
    PFQuery *tripQuery = [PFQuery queryWithClassName:@"Trip"];
    [tripQuery whereKey:@"objectId" equalTo:_tripId];
    [tripQuery getFirstObjectInBackgroundWithBlock:^(PFObject *trip, NSError *error) {
        [trip setObject:@YES forKey:@"expired"];
        [trip saveInBackground];
    }];
    
    createTripViewController *createTripController = [[createTripViewController alloc] init];
    createTripController.userId = self.userId;
    
    NSLog(@"user id %@", self.userId);
    
    [self performSegueWithIdentifier:@"newTrip" sender:self];
}

-(void)setUserId:(NSString *)userId
{
    _userId = userId;
}

-(void)setTripId:(NSString *)tripId
{
    _tripId = tripId;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newTrip"]) {
        [segue.destinationViewController setUserId:self.userId];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"CustomLocation";
    if ([annotation isKindOfClass:[CustomLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"car.png"];
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
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
