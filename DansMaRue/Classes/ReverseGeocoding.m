//
//  ReverseGeocoding.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ReverseGeocoding.h"
#import <AddressBook/AddressBook.h>


@implementation ReverseGeocoding


@synthesize mGeocoder;
@synthesize mDelegate;



#pragma mark -
#pragma mark Object Life Cycle Methods



- (id) initWithDelegate:(NSObject<ReverseGeocodingDelegate>*)_Delegate
{
	self = [super init];
	if (self)
	{
		mGeocoder = [[CLGeocoder alloc] init];
		self.mDelegate = _Delegate;
	}
	return self;
}

- (void)dealloc
{
	[mGeocoder release];
    [mDelegate release];
	[super dealloc];
}



#pragma mark -
#pragma mark Data Management Methods



- (void)launchReverseGeocodingForLocation:(CLLocationCoordinate2D)_Location
{
    C4MLog(@"launchReverseGeocodingForLocation");
    [mGeocoder cancelGeocode];
    
    
    CLLocation* loc = [[CLLocation alloc] initWithLatitude:_Location.latitude longitude:_Location.longitude];
    
    [mGeocoder reverseGeocodeLocation:loc completionHandler:^(NSArray* _Placemarks, NSError* _Error)
     {
         C4MLog(@"mDelegate %@", mDelegate);
         if (_Error)
         {
             [mDelegate reverseGeocoder:mGeocoder didFailWithError:_Error];
         }
         else
         {
             [mDelegate reverseGeocoder:mGeocoder didFindPlacemark:_Placemarks];
         }
     }];
    [loc release];
}


// Dictionary with keys contained ABPerson/Addresses keys
- (void)launchFowardGeocoderWithDictionary:(NSDictionary*)_Dictionary
{    
    [mGeocoder geocodeAddressDictionary:_Dictionary completionHandler:^(NSArray* _Placemarks, NSError* _Error)
     {
         NSLog(@"_Placemarks %@, _Error %@", _Placemarks, _Error);
         if (_Error)
         {
             [mDelegate fowardGeocoder:mGeocoder didFailWithError:_Error];
         }
         else
         {
             [mDelegate fowardGeocoder:mGeocoder didFindPlacemark:_Placemarks];
         }
     }];
}


- (void)cancelCurrentReverseGeocoding
{
    [mGeocoder cancelGeocode];
}



@end
