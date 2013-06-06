//
//  ReverseGeocoding.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ReverseGeocodingDelegate.h"


@interface ReverseGeocoding : NSObject
{
}


@property (retain, nonatomic) CLGeocoder* mGeocoder;
@property (retain, nonatomic) NSObject<ReverseGeocodingDelegate>* mDelegate;


- (id) initWithDelegate:(NSObject<ReverseGeocodingDelegate>*)_Delegate;

- (void)launchReverseGeocodingForLocation:(CLLocationCoordinate2D)_Location;
- (void)launchFowardGeocoderWithDictionary:(NSDictionary*)_Dictionary;
- (void)cancelCurrentReverseGeocoding;

@end
