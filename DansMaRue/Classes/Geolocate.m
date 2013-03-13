//
//  PlayerItem.m
//  PlayGround
//
//  Created by Prigent roudaut on 26/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Geolocate.h"

@implementation Geolocate

//@synthesize mCLLocationManager;
@synthesize coordinate; 
@synthesize mDelegate;

- (id)initWithDelegate:(NSObject<GeoLocatedDelegate>*)_delegate
{
    if (self = [super init])
	{
		self.mDelegate	   = _delegate;
		mCLLocationManager = [[CLLocationManager alloc] init];
		mCLLocationManager.delegate = self;
		mCLLocationManager.distanceFilter = kCLDistanceFilterNone;
		mCLLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)startSimpleLocation
{
    [mCLLocationManager startUpdatingLocation];
    mSimpleLocation = TRUE;
}

- (void)startInfiniteLocation
{
    [mCLLocationManager startUpdatingLocation];
    mSimpleLocation = FALSE;
}

- (void)stopLocation
{
    [mCLLocationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[mDelegate geoLocalisationFailedWithError:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
	if (([newLocation.timestamp timeIntervalSince1970] - [oldLocation.timestamp timeIntervalSince1970]) > 3)
	{
		double longitude = newLocation.coordinate.longitude;
		double latitude  = newLocation.coordinate.latitude;
        //longitude = 5.365850;							//prod:
        //latitude  = 43.308547;
        [mDelegate geoLocalisationLongitude:longitude andLatitude:latitude];
        if (mSimpleLocation)
        {
            [mCLLocationManager stopUpdatingLocation];
        }
	}
}

#pragma mark -
#pragma mark Dealloc methods
- (void) dealloc
{	
	//[mDelegate release];
	mCLLocationManager.delegate = nil;
	[mCLLocationManager release];
	[super dealloc];
}

@end
