//
//  saveIncidentDelegate.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol saveIncidentDelegate

-(void)didSaveIncident:(NSInteger)_incidentId;
-(void)didSaveIncident:(NSInteger)_incidentId withMessage:(NSString*) _msg;

@end
