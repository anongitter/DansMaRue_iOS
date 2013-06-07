//
//  SaveIncident.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "SaveIncident.h"


@implementation SaveIncident
@synthesize mStatusUpdate;

- (id)initWithDelegate:(NSObject<saveIncidentDelegate> *) _saveIncidentDelegate
{
	self = [super init];
	
	if (self)
	{
		mSaveIncidentDelegate = [_saveIncidentDelegate retain];
	}
	
	return self;
}

- (void)dealloc
{
	[mSaveIncidentDelegate release];
	[super dealloc];
}

- (void)generateSaveForIncident:(IncidentObj *)_incident
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary* incidentLog = [NSMutableDictionary dictionary];
	NSMutableDictionary* position = [NSMutableDictionary dictionary];
	
	[dictionary setObject:@"saveIncident" forKey:@"request"];
    
    [dictionary setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"udid"];
    
    [dictionary setObject:_incident.mEmail forKey:@"email"];
	
#ifdef kMarseilleTownhallVersion
	if ([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] != nil)
	{
		[dictionary setObject:[[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] forKey:@"authentToken"];
	}
#endif
	
	NSNumber* category = [NSNumber numberWithInteger:_incident.mcategory];
	[incidentLog setObject:category forKey:@"categoryId"];
	[incidentLog setObject:[_incident maddress] forKey:@"address"];
	[incidentLog setObject:_incident.mdescriptive forKey:@"descriptive"];
    [incidentLog setObject:[NSNumber numberWithInt:_incident.mPriorityId] forKey:@"priorityId"];
	
	NSNumber* latitude = [NSNumber numberWithDouble:(_incident.coordinate.latitude)];
	NSNumber* longitude = [NSNumber numberWithDouble:(_incident.coordinate.longitude)];
	
	[position setObject:(NSNumber*)latitude forKey:@"latitude"];
	[position setObject:(NSNumber*)longitude forKey:@"longitude"];
	
	[dictionary setObject:incidentLog forKey:@"incident"];
	[dictionary setObject:position forKey:@"position"];
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[mSaveIncidentDelegate didSaveIncident:-1];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	NSLog(@"connectionDidFinishLoading = %@", filesContent );
	id idRootJson = [mJson objectWithString:filesContent error:nil];
	
	[filesContent release];
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		
		NSMutableDictionary* dicRoot = [jsonRootObject objectAtIndex:0];
        
        if ([dicRoot objectForKey:@"answer"])
        {
            NSMutableArray* answerRoot = [dicRoot valueForKey:@"answer"];
            NSString* status = [answerRoot valueForKey:@"status"];
            if([status intValue] != 0)
            {
                [mSaveIncidentDelegate didSaveIncident:-1];
            }
            else
            {
                NSString* stringIncidentId = [answerRoot valueForKey:@"incidentId"];
                NSInteger incidentId = [stringIncidentId integerValue];
                
                [mSaveIncidentDelegate didSaveIncident:incidentId];
            }
        } else if ([dicRoot objectForKey:@"error_message"]){
            //connectionDidFinishLoading = [{"error":7,"error_message":"l'arrondissement n'est pas trouvé pour cette latitude et longitude. Etes vous bien dans Paris ? lat,lng : 43.31747,5.3599353"}]
            
            [mSaveIncidentDelegate didSaveIncident:-1 withMessage:[dicRoot objectForKey:@"error_message"]];
        }
		
	}
	else 
	{
		[mSaveIncidentDelegate didSaveIncident:-1];
		NSLog(@"Error");
	}
}

@end
