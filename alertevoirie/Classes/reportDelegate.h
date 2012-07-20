/*
 * reportDelegate.h
 * InfoVoirie
 *
 * Created by Christophe Boivin on 07/06/10.
 * Copyright 2010 C4MProd. All rights reserved.
 *
 */

@protocol reportDelegate

-(void)didReceiveReportsOngoing:(NSArray*)_ongoing updated:(NSArray*)_updated resolved:(NSArray*)_resolved;

@end
