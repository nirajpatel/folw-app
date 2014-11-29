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
#import "LocationTracker.h"

@interface FolwMapViewController ()

@property (nonatomic) CLLocation *userLocation;

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
    self.annotations = [[NSMutableArray alloc] init];
    
    PFGeoPoint *leaderPoint;
    
    PFQuery *tripQuery = [PFQuery queryWithClassName:@"Trip"];
    [tripQuery whereKey:@"objectId" equalTo:_tripId];
    [tripQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.users = [object objectForKey:@"users"];
        
        //leader
        PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
        [userQuery whereKey:@"objectId" equalTo:self.userId];
        
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFGeoPoint *point = object[@"currentLocation"];
            
            NSString *name = object[@"fullName"];
            
            NSNumber *latNumber = [NSNumber numberWithDouble:point.latitude];
            NSLog(@"%@", latNumber);
            NSString *latitudeString = [latNumber stringValue];
            NSAssert(latitudeString, @"No latitude");
            NSNumber *longNumber = [NSNumber numberWithDouble:point.longitude];
            NSLog(@"%@", longNumber);
            
            NSString *longitudeString = [longNumber stringValue];
            NSAssert(longitudeString, @"No longitude");
            
            //store user location
            _userLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = point.latitude;
            coordinate.longitude = point.longitude;
            CustomLocation *annotation = [[CustomLocation alloc] initWithName:name distance:@"" coordinate:coordinate mainuser:[NSNumber numberWithInt:1] userid:self.userId];
            
            [self.annotations addObject:annotation];
            
            
            [_mapView addAnnotation:annotation];
        }];
        
        //get location for all other users
        for(int i = 0; i < sizeof(self.users); i++) {
            if(self.users[i] != self.userId) {
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
                    
                    //get this users location
                    CLLocation *thisUserLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
                    
                    //get distance from main user to this user
                    CLLocationDistance distance = [_userLocation distanceFromLocation:thisUserLocation];
                    NSString *distanceString = [NSString stringWithFormat:@"%.1f %@",(distance/1609.344), @"mi."];
                    
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = point.latitude;
                    coordinate.longitude = point.longitude;
                    CustomLocation *annotation = [[CustomLocation alloc] initWithName:name distance:distanceString coordinate:coordinate mainuser:[NSNumber numberWithInt:0] userid:self.users[i]];
                    
                    [self.annotations addObject:annotation];
                    
                    [_mapView addAnnotation:annotation];
                }];
            }
        }
        
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.showsPointsOfInterest = NO;
        
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
    
    //destination
    PFQuery *userQuery = [PFQuery queryWithClassName:@"Trip"];
    [userQuery whereKey:@"objectId" equalTo:self.tripId];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFGeoPoint *point = object[@"destination"];
        
        NSNumber *latNumber = [NSNumber numberWithDouble:point.latitude];
        NSLog(@"%@", latNumber);
        NSString *latitudeString = [latNumber stringValue];
        NSAssert(latitudeString, @"No latitude");
        NSNumber *longNumber = [NSNumber numberWithDouble:point.longitude];
        NSLog(@"%@", longNumber);
        
        NSString *longitudeString = [longNumber stringValue];
        NSAssert(longitudeString, @"No longitude");
        
        //get this users location
        CLLocation *thisUserLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        
        //get distance from main user to this user
        CLLocationDistance distance = [_userLocation distanceFromLocation:thisUserLocation];
        NSString *distanceString = [NSString stringWithFormat:@"%.1f %@",(distance/1609.344), @"mi."];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = point.latitude;
        coordinate.longitude = point.longitude;
        CustomLocation *annotation = [[CustomLocation alloc] initWithName:@"Destination" distance:distanceString coordinate:coordinate mainuser:[NSNumber numberWithInt:2] userid:@"-1"];
        [_mapView addAnnotation:annotation];
    }];
    
    _endTrip.target = self;
    _endTrip.action = @selector( endTrip: );
    
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0 target:self selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
}

-(void) callAfterSixtySecond:(NSTimer*) t
{
    //get location for all other users
    for(int i = 0; i < [self.users count]; i++) {
        PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
        [userQuery whereKey:@"objectId" equalTo:self.users[i]];
        
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFGeoPoint *point = object[@"currentLocation"];
            
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
            
            for(CustomLocation *annotation in [_mapView annotations]) {
                if([self.users[i] isEqualToString:[annotation userId]]) {
                    NSLog(@"userid: %@", self.users[i]);
                    NSLog(@"annotation userid: %@", [annotation userId]);
                    [annotation setCoordinate:coordinate];
                }
            }
        }];
    }
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomLocation *)annotation {
    static NSString *identifier = @"CustomLocation";
    if ([annotation isKindOfClass:[CustomLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            //main user
            if([annotation.isMainUser isEqualToNumber:[NSNumber numberWithInt:1]]) {
                annotationView.image = [UIImage imageNamed:@"mainCar.png"];
            } else if([annotation.isMainUser isEqualToNumber:[NSNumber numberWithInt:2]]) {
                annotationView.image = [UIImage imageNamed:@"flag.png"];
            } else {
                annotationView.image = [UIImage imageNamed:@"car.png"];
            }
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation
{
    _mapView.centerCoordinate = userLocation.location.coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
