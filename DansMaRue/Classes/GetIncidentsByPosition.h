//
//  GetIncidentsByPosition.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "incidentDelegate.h"

@interface GetIncidentsByPosition : BasicRequest
{
	NSObject<incidentDelegate> *mIncidentDelegate;
}
- (id)initWithDelegate:(NSObject<incidentDelegate> *) _incidentDelegate;
- (void)generatIncident:(NSMutableDictionary*)_MapLocationCoordinate farRadius:(BOOL)_farRadius;
- (void)changeDelegateTo:(NSObject<incidentDelegate> *) _newIncidentDelegate;

@end
