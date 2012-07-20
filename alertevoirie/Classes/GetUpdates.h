//
//  GetUpdates.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "getUpdatesDelegate.h"

@interface GetUpdates : BasicRequest
{
	NSObject<getUpdatesDelegate> *mUpdateIncidentDelegate;
}

- (id)initWithUpdateDelegate:(NSObject<getUpdatesDelegate> *) _activityDelegate;
- (void)generateUpdatesForIncident:(NSNumber *)_incidentId;
- (void)setUpdateDelegate:(NSObject<getUpdatesDelegate> *)_delegate;

@property (nonatomic, retain) NSObject<getUpdatesDelegate> *mUpdateIncidentDelegate;

@end
