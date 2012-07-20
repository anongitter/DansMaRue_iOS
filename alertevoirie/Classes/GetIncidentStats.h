//
//  GetIncidentStats.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 08/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "incidentStatsDelegate.h"
#import "reportDelegate.h"

#define kJSONUpdateIncidentKey			@"updated_incidents"
#define kJSONOngoingIncidentKey			@"ongoing_incidents"
#define kJSONResolvedIncidentKey		@"resolved_incidents"

#define kJSONIncidentsKey				@"incidents"

@interface GetIncidentStats : BasicRequest
{
	NSObject<incidentStatsDelegate> *mIncidentStatsDelegate;
	NSObject<reportDelegate> *mReportDelegate;
}

- (id)initWithStatsDelegate:(NSObject<incidentStatsDelegate> *) _incidentStatsDelegate andReportDelegate:(NSObject<reportDelegate> *) _reportDelegate;
- (void)generateIncidentStats:(NSMutableDictionary*)_MapLocationCoordinate;

@end
