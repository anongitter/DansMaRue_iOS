//
//  UpdateIncident.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 08/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "UpdateIncident.h"

@implementation UpdateIncident
@synthesize mStatusUpdate;

- (id)initWithDelegate:(NSObject<updateIncidentDelegate> *) _updateIncidentDelegate
{
	self = [super init];
	if (self)
	{
		mUpdateIncidentDelegate = [_updateIncidentDelegate retain];
	}
	return self;
}

- (void)dealloc
{
	[mUpdateIncidentDelegate release];
	[super dealloc];
}

- (void)generateUpdateForIncident:(NSNumber *)_incidentId status:(NSString*)_status
{
	self.mReceivedData = [NSMutableData data];
	
	self.mStatusUpdate = _status;
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary* incidentLog = [NSMutableDictionary dictionary];
	
	[dictionary setObject:@"updateIncident" forKey:@"request"];

	
	[incidentLog setObject:(NSNumber*)_incidentId forKey:@"incidentId"];
	[incidentLog setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"udid"];
	[incidentLog setObject:_status forKey:@"status"];
	
	[dictionary setObject:incidentLog forKey:@"incidentLog"];
	
	NSString* jsonStream =  [mJson stringWithObject:[NSMutableArray arrayWithObject:dictionary]];
	
	NSString* json_string = [NSString stringWithFormat:@"jsonStream=%@", jsonStream];
	
	//NSLog(@"%@",json_string);
	
	NSData *request_body = [json_string dataUsingEncoding:NSUTF8StringEncoding];
	NSString* stringurl = [InfoVoirieContext getServerURL:NO];
	NSURL * url=[NSURL URLWithString:stringurl];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setTimeoutInterval: kTimeOutIntervalRequest];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:request_body];
	[InfoVoirieContext fillHTTPHeadersOfRequest:request WithJsonStream:jsonStream];
	
	mURLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[request release];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	C4MLog(@"<<-- didReceiveData : %@", filesContent);
    
	id idRootJson = [mJson objectWithString:filesContent error:nil];
	[filesContent release];
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary* dicRoot = [jsonRootObject objectAtIndex:0];
		NSMutableArray* answerRoot = [dicRoot valueForKey:@"answer"];
		
		NSString* status = [answerRoot valueForKey:@"status"];
		
		if([status intValue] != 0)
		{
			int status_code = [status intValue];
			if(status_code == kErrorDoubleResolved)
			{
				[mUpdateIncidentDelegate didAchieveUpdateFor:(@"DoubleResolved")];
				return;
			}
			else if(status_code == kErrorDoubleConfirm)
			{
				[mUpdateIncidentDelegate didAchieveUpdateFor:(@"DoubleConfirmed")];
				return;
			}
			else if(status_code == kErrorDoubleInvalidate)
			{
				[mUpdateIncidentDelegate didAchieveUpdateFor:(@"DoubleInvalidate")];
				return;
			}
		}
			
		[mUpdateIncidentDelegate didAchieveUpdateFor:(self.mStatusUpdate)];
	}
	else 
	{
		C4MLog(@"Error");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:NSLocalizedString(@"error_modification_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

@end
