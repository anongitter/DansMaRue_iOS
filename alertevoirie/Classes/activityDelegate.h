/*
 * activityDelegate.h
 * InfoVoirie
 *
 * Created by Christophe Boivin on 07/06/10.
 * Copyright 2010 C4MProd. All rights reserved.
 *
 */

@protocol activityDelegate

-(void)didReceiveActivities:(NSArray*)_incidents logs:(NSArray*)_incidentLogs;

@end
