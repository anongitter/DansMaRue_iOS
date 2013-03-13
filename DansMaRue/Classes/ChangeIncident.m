//
//  ChangeIncident.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 12/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ChangeIncident.h"

@implementation ChangeIncident
@synthesize mStatusUpdate;

- (id)initWithDelegate:(NSObject<changeIncidentDelegate> *) _changeIncidentDelegate
{
	self = [super init];
	if (self)
	{
		mChangeIncidentDelegate = [_changeIncidentDelegate retain];
	}
	return self;
}

- (void)dealloc
{
	[mChangeIncidentDelegate release];
	[super dealloc];
}

/*- (void)generateChangeForIncident:(NSNumber *)_incidentId newCategory:(NSNumber *)_incidentCategory newAddress:(NSString*)_incidentAddress
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	
	[dictionary setObject:@"changeIncident" forKey:@"request"];
	[dictionary setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
	[dictionary setObject:(NSNumber*)_incidentId forKey:@"incidentId"];
	[dictionary setObject:(NSNumber *)_incidentCategory forKey:@"categoryId"];
	[dictionary setObject:_incidentAddress forKey:@"address"];
	
	NSNumber* latitude = [NSNumber numberWithDouble:(_incident.coordinate.latitude)];
	NSNumber* longitude = [NSNumber numberWithDouble:(_incident.coordinate.longitude)];
	
	[position setObject:(NSNumber*)latitude forKey:@"latitude"];
	[position setObject:(NSNumber*)longitude forKey:@"longitude"];
	[dictionary setObject:position forKey:@"position"];
	
#ifdef kMarseilleTownhallVersion
	if ([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] != nil)
	{
		[dictionary setObject:[[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] forKey:@"authentToken"];
	}
#endif
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}*/

- (void)generateChangeForIncident:(IncidentObj*)_incident
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary* position = [NSMutableDictionary dictionary];
	
	[dictionary setObject:@"changeIncident" forKey:@"request"];
	[dictionary setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
	[dictionary setObject:[NSNumber numberWithInt:_incident.mid] forKey:@"incidentId"];
	[dictionary setObject:[NSNumber numberWithInt: _incident.mcategory] forKey:@"categoryId"];
	[dictionary setObject:_incident.maddress forKey:@"address"];
	
	NSNumber* latitude = [NSNumber numberWithDouble:(_incident.coordinate.latitude)];
	NSNumber* longitude = [NSNumber numberWithDouble:(_incident.coordinate.longitude)];
	
	[position setObject:(NSNumber*)latitude forKey:@"latitude"];
	[position setObject:(NSNumber*)longitude forKey:@"longitude"];
	[dictionary setObject:position forKey:@"position"];
	
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
- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	NSLog(@"SCAN = %@", filesContent );
	id idRootJson = [mJson objectWithString:filesContent error:nil];
	
	[filesContent release];
	
	// TODO:
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary* dicRoot = [jsonRootObject objectAtIndex:0];
		NSMutableArray* answerRoot = [dicRoot valueForKey:@"answer"];
		
		NSString* status = [answerRoot valueForKey:@"status"];
		
		if([status intValue] != 0)
		{
			[mChangeIncidentDelegate didAchieveChange:NO];
		}
		
		[mChangeIncidentDelegate didAchieveChange:YES];
	}
	else if( [idRootJson isKindOfClass: [NSMutableDictionary class]] )
	{
		NSMutableDictionary* jsonRootObject = (NSMutableDictionary*) idRootJson;
		
		NSNumber *numError = [jsonRootObject valueForKey:@"error"];
		
		[self manageErrorOfStatusCode:[numError intValue]];
	}
	else 
	{
		NSLog(@"Error");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:NSLocalizedString(@"error_modification_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

@end
