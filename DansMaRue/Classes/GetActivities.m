//
//  GetActivities.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetActivities.h"

@implementation GetActivities

- (id)initWithDelegate:(NSObject<activityDelegate> *) _activityDelegate
{
	self = [super init];
	if (self) 
	{
		mActivityDelegate = [_activityDelegate retain];
	}
	
	return self;
}

- (void)dealloc
{
	[mActivityDelegate release];
	[super dealloc];
}

- (void)generateActivities:(NSMutableDictionary*)_MapLocationCoordinate
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:@"getUsersActivities" forKey:@"request"];
	[dictionary setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"udid"];
	[dictionary setObject:_MapLocationCoordinate forKey:@"position"];
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[mActivityDelegate didReceiveActivities:nil logs:nil];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	//id idRootJson = [mJson objectWithString:filesContent error:nil];
	NSMutableArray* idRootJson = [mJson objectWithString:filesContent error:nil];
	//NSLog(@"idRootJson count : %d", [(NSMutableArray*)idRootJson count]);
	
	[filesContent release];
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary*	dicRoot = [jsonRootObject objectAtIndex:0];
		NSMutableArray*		answerRoot = [dicRoot valueForKey:@"answer"];
		
		NSInteger			status_code = [((NSNumber*)[answerRoot valueForKey:@"status"]) intValue];
		
		if(status_code != 0)
		{
			[self manageErrorOfStatusCode:status_code];
			[mActivityDelegate didReceiveActivities:nil logs:nil];
			return;
		}
		
		NSMutableArray*		arrayRoot = [answerRoot valueForKey:@"incidents"];
		
		NSMutableArray*		arrayIncidents = [NSMutableArray array];
		NSMutableDictionary*	incidentsByStatus;
		
		incidentsByStatus = [arrayRoot valueForKey:@"updated_incidents"];
		for(NSMutableDictionary* incidentDic in incidentsByStatus)
		{
			IncidentObj* incident = [[IncidentObj alloc] initWithDic:incidentDic];
			[arrayIncidents addObject:incident];
			[incident release];
		}
		incidentsByStatus = [arrayRoot valueForKey:@"ongoing_incidents"];
		for(NSMutableDictionary* incidentDic in incidentsByStatus)
		{
			IncidentObj* incident = [[IncidentObj alloc] initWithDic:incidentDic];
			[arrayIncidents addObject:incident];
			[incident release];
		}
		incidentsByStatus = [arrayRoot valueForKey:@"resolved_incidents"];
		for(NSMutableDictionary* incidentDic in incidentsByStatus)
		{
			IncidentObj* incident = [[IncidentObj alloc] initWithDic:incidentDic];
			[arrayIncidents addObject:incident];
			[incident release];
		}
		
		// TODO: logs
		arrayRoot = [answerRoot valueForKey:@"incidentLog"];
		NSMutableArray* arrayIncidentLogs = [NSMutableArray array];
		for(NSMutableDictionary* incidentLogDic in arrayRoot)
		{
			LogObj *incident = [[LogObj alloc] initWithDic:incidentLogDic];
			[arrayIncidentLogs addObject:incident];
			[incident release];
		}
		
		[mActivityDelegate didReceiveActivities:arrayIncidents logs:arrayIncidentLogs];
	}
	else 
	{
		[mActivityDelegate didReceiveActivities:nil logs:nil];
	}
}

@end
