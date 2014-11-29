#import "CustomLocation.h"
#import <AddressBook/AddressBook.h>

@interface CustomLocation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation CustomLocation

- (id)initWithName:(NSString*)name distance:(NSString*)distance coordinate:(CLLocationCoordinate2D)coordinate mainuser:(NSNumber*)number userid:(NSString*)userid {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            _name = name;
        } else {
            _name = @"Unknown charge";
        }
        _distance = distance;
        _coordinate = coordinate;
        _isMainUser = number;
        _userId = userid;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _distance;
}

- (void) setDistance:(NSString*)distance {
    _distance = distance;
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _distance};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end