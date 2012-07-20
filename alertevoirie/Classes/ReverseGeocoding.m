//
//  ReverseGeocoding.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ReverseGeocoding.h"

@implementation ReverseGeocoding
@synthesize mReverseGeocoder;

- (id) initWithDelegate:(NSObject<MKReverseGeocoderDelegate> *)_delegate
{
	self = [super init];
	if (self)
	{
		self.mReverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:[[InfoVoirieContext sharedInfoVoirieContext] mLocation]] autorelease];
		self.mReverseGeocoder.delegate = _delegate;
	}
	return self;
}

- (id) initWithDelegate:(NSObject <MKReverseGeocoderDelegate>*)_delegate andCoordinate:(CLLocationCoordinate2D)_coordinate
{
	self = [super init];
	if (self)
	{
		self.mReverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:_coordinate] autorelease];
		self.mReverseGeocoder.delegate = _delegate;
	}
	return self;
}

-(void) launchReverseGeocoding
{
	[mReverseGeocoder start];
}

- (void)dealloc
{
	[mReverseGeocoder release];
	[super dealloc];
}

@end
