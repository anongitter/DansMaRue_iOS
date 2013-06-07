//
//  GetIncidentStats.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 08/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetIncidentStats.h"

@implementation GetIncidentStats

- (id)initWithStatsDelegate:(NSObject<incidentStatsDelegate> *) _incidentStatsDelegate andReportDelegate:(NSObject<reportDelegate> *) _reportDelegate
{
	self = [super init];
	if (self)
	{
		mIncidentStatsDelegate = [_incidentStatsDelegate retain];
		mReportDelegate = [_reportDelegate retain];
	}
	
	return self;
}

- (void)dealloc
{
	[mIncidentStatsDelegate release];
	[mReportDelegate release];
	[super dealloc];
}

- (void)generateIncidentStats:(NSMutableDictionary*)_MapLocationCoordinate
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableArray* requests = [NSMutableArray array];
	
	NSMutableDictionary* dictionnary = [NSMutableDictionary dictionary];
	[dictionnary setObject:@"getIncidentStats" forKey:@"request"];
	[dictionnary setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"udid"];
	[dictionnary setObject:_MapLocationCoordinate forKey:@"position"];
	[requests addObject:dictionnary];
	
	NSMutableDictionary* dictionnaryReports = [NSMutableDictionary dictionary];
	[dictionnaryReports setObject:@"getReports" forKey:@"request"];
	[dictionnaryReports setObject:(id)[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"udid"];
	
#ifdef kMarseilleTownhallVersion
	if ([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] != nil)
	{
		[dictionnaryReports setObject:[[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] forKey:@"authentToken"];
	}
#endif
	[requests addObject:dictionnaryReports];
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:requests andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[super connection:connection didFailWithError:error];
	
	[mIncidentStatsDelegate didReceiveIncidentStats:nil :nil :nil];
	[mReportDelegate didReceiveReportsOngoing:nil updated:nil resolved:nil];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	NSLog(@"SCAN = %@", filesContent );
	NSMutableArray* idRootJson = [mJson objectWithString:filesContent error:nil];
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary* dicRoot = [jsonRootObject objectAtIndex:0];
		NSMutableArray* answerRoot = [dicRoot valueForKey:@"answer"];
		NSString* updatedIncidents = [NSString stringWithFormat:@"%@", [answerRoot valueForKey:kJSONUpdateIncidentKey]];
		
		NSInteger numOngoingIncidents = [[answerRoot valueForKey:kJSONOngoingIncidentKey] intValue];
		NSString* ongoingIncidents = [NSString stringWithFormat:@"%d", numOngoingIncidents];
		NSString* resolvedIncidents = [NSString stringWithFormat:@"%@", [answerRoot valueForKey:kJSONResolvedIncidentKey]];
		
		[mIncidentStatsDelegate didReceiveIncidentStats:ongoingIncidents :updatedIncidents :resolvedIncidents];
		
        if ([jsonRootObject count] > 1)
        {
            dicRoot = [jsonRootObject objectAtIndex:1];
            answerRoot = [dicRoot valueForKey:@"answer"];
            NSMutableArray* arrayRoot = [answerRoot valueForKey:kJSONIncidentsKey];
            NSMutableArray* incidentsByStatus = [arrayRoot valueForKey:kJSONResolvedIncidentKey];
            NSMutableArray* arrayResolved = [[NSMutableArray alloc] init];
            IncidentObj *incident;
            for(NSMutableDictionary* incidentDic in incidentsByStatus)
            {
                incident = [[IncidentObj alloc] initWithDic:incidentDic];
                [arrayResolved addObject:incident];
                [incident release];
            }
            
            [mReportDelegate didReceiveReportsOngoing:nil updated:nil resolved:arrayResolved];
            [arrayResolved release];
        }
	}
	else 
	{
		NSLog(@"Error : %@", filesContent);
		[mIncidentStatsDelegate didReceiveIncidentStats:@"" :@"" :@""];
		[mReportDelegate didReceiveReportsOngoing:nil updated:nil resolved:nil];
	}
	[filesContent release];
}

@end
