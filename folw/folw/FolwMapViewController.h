//
//  FolwMapViewController.h
//  folw
//
//  Created by Brandon Lee on 10/20/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define kSomethingHappened @"SomethingHappened"

@interface FolwMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *tripId;

@property (strong, nonatomic) NSMutableArray *annotations;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *endTrip;

@end
