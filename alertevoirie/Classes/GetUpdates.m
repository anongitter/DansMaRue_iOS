//
//  GetUpdates.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetUpdates.h"

@implementation GetUpdates
@synthesize mUpdateIncidentDelegate;

- (id)initWithUpdateDelegate:(NSObject<getUpdatesDelegate> *) _updateIncidentDelegate
{
	self = [super init];
	if (self)
	{
		self.mUpdateIncidentDelegate = _updateIncidentDelegate;
	}
	return self;
}

- (void)generateUpdatesForIncident:(NSNumber *)_incidentId
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	
	[dictionary setObject:@"getIncidentPhotos" forKey:@"request"];
	[dictionary setObject:(NSNumber*)_incidentId forKey:@"incidentId"];
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}

- (void)setUpdateDelegate:(NSObject<getUpdatesDelegate> *)_delegate
{
	self.mUpdateIncidentDelegate = _delegate;
}

- (void)dealloc
{
	[mUpdateIncidentDelegate release];
	[super dealloc];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[mUpdateIncidentDelegate didReceiveUpdates:nil];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"SCAN = %@", filesContent );
	id idRootJson = [mJson objectWithString:filesContent error:nil];
	
	[filesContent release];
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		///[{"answer": {"updates": [{"photo": @"", "comment": @"", "date": @""}]}}]
		NSDictionary* lDicRoot = [jsonRootObject objectAtIndex:0];
		NSDictionary* lAnswerRoot = [lDicRoot valueForKey:@"answer"];
		
		NSArray* lUpdates = [lAnswerRoot objectForKey:@"photos"];
		
		//NSLog(@"%@", lUpdates);
		
		[mUpdateIncidentDelegate didReceiveUpdates:lUpdates];
	}
	else if( [idRootJson isKindOfClass: [NSMutableDictionary class]] )
	{
		/*NSMutableDictionary* jsonRootObject = (NSMutableDictionary*) idRootJson;
		
		NSNumber *numError = [jsonRootObject valueForKey:@"error"];
		NSInteger tmp;
		*/
		
	}
	else 
	{
		[mUpdateIncidentDelegate didReceiveUpdates:nil];
		NSLog(@"Error");
	}
}

@end