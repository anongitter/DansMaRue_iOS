//
//  ReverseGeocoding.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ReverseGeocoding : NSObject {
	MKReverseGeocoder *mReverseGeocoder;
}

- (id) initWithDelegate:(NSObject<MKReverseGeocoderDelegate> *)_delegate;
- (id) initWithDelegate:(NSObject <MKReverseGeocoderDelegate>*)_delegate andCoordinate:(CLLocationCoordinate2D)_coordinate;
- (void) launchReverseGeocoding;

@property (nonatomic, retain) MKReverseGeocoder *mReverseGeocoder;

@end
