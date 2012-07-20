//
//  SaveIncident.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "saveIncidentDelegate.h"
#import "incidentObj.h"

@interface SaveIncident : BasicRequest
{
	NSString* mStatusUpdate;
	
	NSObject<saveIncidentDelegate> *mSaveIncidentDelegate;
}

- (id)initWithDelegate:(NSObject<saveIncidentDelegate> *) _saveIncidentDelegate;
- (void)generateSaveForIncident:(IncidentObj *)_incident;

@property (nonatomic, retain) NSString* mStatusUpdate;

@end
