//
//  ChangeIncident.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 12/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "changeIncidentDelegate.h"

@interface ChangeIncident : BasicRequest
{
	NSObject<changeIncidentDelegate>*	mChangeIncidentDelegate;
	NSString*							mStatusUpdate;
}

- (id)initWithDelegate:(NSObject<changeIncidentDelegate> *) _activityDelegate;
//- (void)generateChangeForIncident:(NSNumber *)_incidentId newCategory:(NSNumber *)_incidentCategory newAddress:(NSString*)_incidentAddress;
- (void)generateChangeForIncident:(IncidentObj*)_incident;

@property (nonatomic, retain) NSString* mStatusUpdate;

@end