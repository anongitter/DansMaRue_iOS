//
//  UserAuthentication.m
//  InfoVoirie
//
//  Created by Christophe on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserAuthentication.h"


@implementation UserAuthentication

- (id)initWithDelegate:(NSObject<userAuthenticationDelegate> *) _delegate
{
	self = [super init];
	if (self)
	{
		mDelegate = [_delegate retain];
	}
	return self;
}

- (void)dealloc
{
	[mDelegate release];
	[super dealloc];
}

- (void)generateUserAuthentication
{
	self.mReceivedData = [NSMutableData data];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	
	[dictionary setObject:@"userAuthentication" forKey:@"request"];
	[dictionary setObject:[[InfoVoirieContext sharedInfoVoirieContext] mUserLogin] forKey:@"login"];
	[dictionary setObject:[[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] forKey:@"authentToken"];
	
	mURLConnection = [[InfoVoirieContext launchRequestWithArray:[NSMutableArray arrayWithObject:dictionary] andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[mDelegate didFailedAuthenticationWithStatusCode:-1];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	NSLog(@"SCAN = %@", filesContent );
	id idRootJson = [mJson objectWithString:filesContent error:nil];
	[filesContent release];
	
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
		NSMutableDictionary* jsonRootObject = [((NSMutableArray*)idRootJson) objectAtIndex:0];
		
		NSMutableDictionary* answerRoot = [jsonRootObject objectForKey:@"answer"];
		
		NSNumber* status = [answerRoot valueForKey:@"status"];
		if ([status intValue] == 0)
		{
			[InfoVoirieContext sharedInfoVoirieContext].mUserName = [answerRoot valueForKey:@"name"];
			[InfoVoirieContext sharedInfoVoirieContext].mUserSurname = [answerRoot valueForKey:@"surname"];
			
			[mDelegate didAuthenticate];
		}
		else
		{
			[self manageErrorOfStatusCode:[status intValue]];
			
			[mDelegate didFailedAuthenticationWithStatusCode:[status intValue]];
		}
	}
	else
	{
		NSLog(@"Error");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		[mDelegate didFailedAuthenticationWithStatusCode:-1];
	}
}

@end
