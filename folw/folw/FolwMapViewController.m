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
@property (nonatomic) CustomLocation *destination;

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
    //[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x067AB5)];
    self.navigationItem.hidesBackButton = YES;
    
    self.users = [[NSArray alloc] init];
    
    //PFGeoPoint *leaderPoint;
    
    PFQuery *tripQuery = [PFQuery queryWithClassName:@"Trip"];
    [tripQuery whereKey:@"objectId" equalTo:_tripId];
    [tripQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.users = [object objectForKey:@"users"];
        
        //main user
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
            
            [_mapView addAnnotation:annotation];
            
            _mapView.delegate = self;
            _mapView.showsUserLocation = NO;
            _mapView.showsPointsOfInterest = NO;
            
            CLLocationCoordinate2D zoomLocation;
            zoomLocation.latitude = coordinate.latitude; // your latitude value
            zoomLocation.longitude= coordinate.longitude; // your longitude value
            
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta=0.005;
            span.longitudeDelta=0.005;
            region.span=span;
            region.center= zoomLocation;
            
            [_mapView setRegion:region animated:YES];
            [_mapView regionThatFits:region];
        }];
        
        //get location for all other users
        for(int i = 0; i < sizeof(self.users); i++) {
            if(![self.users[i] isEqualToString:self.userId]) {
                PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
                [userQuery whereKey:@"objectId" equalTo:self.users[i]];
                
                [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    PFGeoPoint *point = object[@"currentLocation"];
                    
//                    //TO DO
//                    if(i == 0) {
//                        __block PFGeoPoint *leaderPoint = point;
//                    }
                    
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
                    
                    [_mapView addAnnotation:annotation];
                }];
            }
        }
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
        
        _destination = annotation;
        
        [_mapView addAnnotation:annotation];
    }];
    
    _endTrip.target = self;
    _endTrip.action = @selector( endTrip: );
    
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0 target:self selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
    
    NSLog(@"count %i", [self.users count]);
}

-(void) callAfterSixtySecond:(NSTimer*) t
{
    //main user
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery whereKey:@"objectId" equalTo:self.userId];
    
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
            if([self.userId isEqualToString:[annotation userId]]) {
                //store user location
                _userLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
                [annotation setCoordinate:coordinate];
                [annotation setDistance:@""];
            }
        }
    }];
    
    //get location for all other users
    for(int i = 0; i < [self.users count]; i++) {
        if(![self.users[i] isEqualToString:self.userId]) {
            NSLog(@"HEREEEEE");
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
                        //get this users location
                        CLLocation *thisUserLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
                        
                        //get distance from main user to this user
                        CLLocationDistance distance = [_userLocation distanceFromLocation:thisUserLocation];
                        NSString *distanceString = [NSString stringWithFormat:@"%.1f %@",(distance/1609.344), @"mi."];
                        NSLog(@"distance %@", distanceString);
                        
                        [annotation setCoordinate:coordinate];
                        [annotation setDistance:distanceString];
                    }
                }
            }];
        }
    }
    
    //destination distance
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:_destination.coordinate.latitude longitude:_destination.coordinate.longitude];
    
    //get distance from main user to this user
    CLLocationDistance distance = [_userLocation distanceFromLocation:destinationLocation];
    NSString *distanceString = [NSString stringWithFormat:@"%.1f %@",(distance/1609.344), @"mi."];
    
    [_destination setDistance:distanceString];
    
    NSLog(@"count %i", [_mapView.annotations count]);
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
    } else if ([segue.identifier isEqualToString:@"currentPeopleSegue"]){
        [segue.destinationViewController setUserList:[self.users mutableCopy]];
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
