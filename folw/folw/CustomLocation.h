//
//  CustomLocation.h
//  folw
//
//  Created by Niraj Patel on 11/14/14.
//  Copyright (c) 2014 CS378. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface CustomLocation : NSObject <MKAnnotation>

@property (nonatomic) NSNumber * isMainUser;

- (id)initWithName:(NSString*)name distance:(NSString*)distance coordinate:(CLLocationCoordinate2D)coordinate mainuser:(NSNumber*)number;
- (MKMapItem*)mapItem;

@end
