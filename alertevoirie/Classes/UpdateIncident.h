//
//  UpdateIncident.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 08/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "updateIncidentDelegate.h"

@interface UpdateIncident : BasicRequest
{
	NSString* mStatusUpdate;
	
	NSObject<updateIncidentDelegate> *mUpdateIncidentDelegate;
}

- (id)initWithDelegate:(NSObject<updateIncidentDelegate> *) _activityDelegate;
- (void)generateUpdateForIncident:(NSNumber *)_incidentId status:(NSString*)_status;

@property (nonatomic, retain) NSString* mStatusUpdate;

@end
