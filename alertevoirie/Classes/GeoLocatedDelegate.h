/*
 *  GeoLocatedZipCodeHandler.h
 *  CultureYvelines
 *
 *  Created by Hadrien Blondel on 11/03/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@protocol GeoLocatedDelegate

- (void) geoLocalisationFailedWithError:(NSError *)error;
- (void) geoLocalisationLongitude:(float)_Longitude andLatitude:(float)_Latitude;

@end

