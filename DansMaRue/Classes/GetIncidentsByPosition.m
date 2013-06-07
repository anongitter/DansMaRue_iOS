//
//  GetIncidentsByPosition.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetIncidentsByPosition.h"

@implementation GetIncidentsByPosition

- (id)init
{
	mJson = [[SBJSON alloc] init] ;	
	return self;
}

- (id)initWithDelegate:(NSObject<incidentDelegate> *) _incidentDelegate
{
	self = [super init];
	if (self)
	{
		mIncidentDelegate = [_incidentDelegate retain];
	}
	return self;
}

- (void)changeDelegateTo:(NSObject<incidentDelegate> *) _newIncidentDelegate
{
	if (mIncidentDelegate != nil)
	{
		[mIncidentDelegate release];
		mIncidentDelegate = nil;
	}
	mIncidentDelegate = [_newIncidentDelegate retain];
}

- (void)dealloc
{
	[mIncidentDelegate release];
	[super dealloc];
}

- (void)generatIncident:(NSMutableDictionary*)_MapLocationCoordinate farRadius:(BOOL)_farRadius
{	
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary]; //	NSNumber
	[dictionary setObject:@"getIncidentsByPosition" forKey:@"request"];
	[dictionary setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"udid"];
	
	if (_farRadius == YES)
	{
		[dictionary setObject:@"far" forKey:@"radius"];
	}
	else
	{
		[dictionary setObject:@"close" forKey:@"radius"];
	}
	
	[dictionary setObject:[NSNumber numberWithInt:20] forKey:@"limit"];
	[dictionary setObject:_MapLocationCoordinate forKey:@"position"];
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	if (mIncidentDelegate == nil)
	{
		return;
	}
	
	[mIncidentDelegate didReceiveIncidents:nil];
	
	[super connection:connection didFailWithError:error];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	if (mIncidentDelegate == nil)
	{
		NSLog(@"incident delegate nil");
		return;
	}
	
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	NSMutableArray* idRootJson = [mJson objectWithString:filesContent error:nil];
	
	[filesContent release];
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary* dicRoot = [jsonRootObject objectAtIndex:0];

		NSMutableArray* answerRoot = [dicRoot valueForKey:@"answer"];
		
		NSInteger		status_code = [[answerRoot valueForKey:@"status"] intValue];
		
		if (status_code != 0)
		{
			[self manageErrorOfStatusCode:status_code];
			[mIncidentDelegate didReceiveIncidents:nil];
			return;
		}
		
		NSMutableArray* arrayRoot = [answerRoot valueForKey:@"closest_incidents"];
		NSMutableArray* array = [NSMutableArray array];
		
		for(NSMutableDictionary* dic in arrayRoot)
		{
			IncidentObj * incident = [[IncidentObj alloc] initWithDic:dic];
			[array addObject:incident];
			[incident release];
		}
		[mIncidentDelegate didReceiveIncidents:array];
	}
	else 
	{
		NSLog(@"Error");
		[mIncidentDelegate didReceiveIncidents:nil];
	}
}

@end
