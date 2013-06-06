//
//  ReverseGeocodingDelegate.h
//  ParisDansMaRue
//
//  Created by Raphael Pinto on 06/06/13.
//
//

#import <Foundation/Foundation.h>

@protocol ReverseGeocodingDelegate <NSObject>


- (void)reverseGeocoder:(CLGeocoder*)_Geocoder didFailWithError:(NSError*)_Error;
- (void)reverseGeocoder:(CLGeocoder*)_Geocoder didFindPlacemark:(NSArray*)_Placemarks;

- (void)fowardGeocoder:(CLGeocoder*)_Geocoder didFailWithError:(NSError*)_Error;
- (void)fowardGeocoder:(CLGeocoder*)_Geocoder didFindPlacemark:(NSArray*)_Placemarks;
@end
