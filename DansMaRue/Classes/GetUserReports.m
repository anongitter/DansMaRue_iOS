//
//  GetUserReports.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetUserReports.h"
#import "incidentObj.h"

@implementation GetUserReports
@synthesize mReportDelegate;

- (id)initWithDelegate:(NSObject<reportDelegate> *) _reportDelegate
{
	self = [super init];
	if (self)
	{
		self.mReportDelegate = _reportDelegate;
	}
	
	return self;
}

- (void)setReportDelegate:(NSObject<reportDelegate> *) _reportDelegate
{
	if (mReportDelegate != nil)
	{
		[mReportDelegate release];
		mReportDelegate = nil;
	}
	self.mReportDelegate = _reportDelegate;
}

- (void)dealloc
{
	[mReportDelegate release];
	[super dealloc];
}

- (void)generateReports
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:@"getReports" forKey:@"request"];
	[dictionary setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
	
#ifdef kMarseilleTownhallVersion
	if ([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] != nil)
	{
		[dictionary setObject:[[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] forKey:@"authentToken"];
	}
#endif
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[mReportDelegate didReceiveReportsOngoing:nil updated:nil resolved:nil];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	
	NSMutableArray* idRootJson = [mJson objectWithString:filesContent error:nil];
	[filesContent release];
	
	NSLog(@"SCAN: %@", idRootJson);
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary* dicRoot = [jsonRootObject objectAtIndex:0];
		NSMutableDictionary* answerRoot = [dicRoot valueForKey:@"answer"];
		
		NSNumber* status = [answerRoot valueForKey:@"status"];
		if (status != nil)
		{
			if ([status intValue] != 0)
			{
				[self manageErrorOfStatusCode:[status intValue]];
				[mReportDelegate didReceiveReportsOngoing:nil updated:nil resolved:nil];
				
				return;
			}
		}
		
		NSMutableArray* arrayRoot = [answerRoot valueForKey:@"incidents"];
		
		NSMutableDictionary* incidentsByStatus;
		
		incidentsByStatus = [arrayRoot valueForKey:@"updated_incidents"];
		NSMutableArray* arrayUpdated = [NSMutableArray array];
		IncidentObj *incident;
		for(NSMutableDictionary* incidentDic in incidentsByStatus)
		{
			incident = [[IncidentObj alloc] initWithDic:incidentDic];
			[arrayUpdated addObject:incident];
			[incident release];
		}
		
		incidentsByStatus = [arrayRoot valueForKey:@"resolved_incidents"];
		NSMutableArray* arrayResolved = [NSMutableArray array];
		for(NSMutableDictionary* incidentDic in incidentsByStatus)
		{
			incident = [[IncidentObj alloc] initWithDic:incidentDic];
			[arrayResolved addObject:incident];
			[incident release];
		}
		
		incidentsByStatus = [arrayRoot valueForKey:@"declared_incidents"];
		NSMutableArray* arrayOngoing = [NSMutableArray array];
		for(NSMutableDictionary* incidentDic in incidentsByStatus)
		{
			incident = [[IncidentObj alloc] initWithDic:incidentDic];
			NSLog(@"incident ongoing : %@", [incident description]);
			[arrayOngoing addObject:incident];
			[incident release];
		}
		
		NSLog(@"arrayOngoing : %@ count = %d", arrayOngoing, [arrayOngoing count]);
		
		[mReportDelegate didReceiveReportsOngoing:arrayOngoing updated:arrayUpdated resolved:arrayResolved];
	}
	else 
	{
		NSLog(@"Error");
		[mReportDelegate didReceiveReportsOngoing:nil updated:nil resolved:nil];
	}
}

@end
