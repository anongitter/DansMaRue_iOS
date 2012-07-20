//
//  GetActivities.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "logObj.h"
#import "activityDelegate.h"

@interface GetActivities : BasicRequest
{
	NSObject<activityDelegate> *mActivityDelegate;
}

- (id)initWithDelegate:(NSObject<activityDelegate> *) _activityDelegate;
- (void)generateActivities:(NSMutableDictionary*)_MapLocationCoordinate;

@end