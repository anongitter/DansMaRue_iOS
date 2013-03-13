//
//  PlayerItem.h
//  PlayGround
//
//  Created by Prigent roudaut on 26/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GeoLocatedDelegate.h"

@interface Geolocate: NSObject <MKAnnotation,CLLocationManagerDelegate>
{
	CLLocationManager *mCLLocationManager;
	CLLocationCoordinate2D coordinate;
	NSObject<GeoLocatedDelegate> *mDelegate;
	BOOL mSimpleLocation;
}

- (void)startSimpleLocation;
- (void)startInfiniteLocation;
- (void)stopLocation;
- (id)initWithDelegate:(NSObject<GeoLocatedDelegate>*)_delegate;

@property(nonatomic, retain) NSObject<GeoLocatedDelegate> *mDelegate;
//@property(nonatomic, retain) CLLocationManager *mCLLocationManager;
@property(nonatomic) CLLocationCoordinate2D coordinate;

@end
