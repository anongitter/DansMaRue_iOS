/*
 * incidentStatsDelegate.h
 * InfoVoirie
 *
 * Created by Christophe Boivin on 08/06/10.
 * Copyright 2010 C4MProd. All rights reserved.
 *
 */


@protocol incidentStatsDelegate

- (void)didReceiveIncidentStats:(NSString*)_nbOngoingIncidents :(NSString*)_nbUpdatedIncidents :(NSString*)_nbResolvedIncidents;

@end
