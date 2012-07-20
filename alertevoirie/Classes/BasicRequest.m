//
//  BasicRequest.m
//  InfoVoirie
//
//  Created by Christophe on 12/01/11.
//  Copyright 2011 C4MProd. All rights reserved.
//

#import "BasicRequest.h"


@implementation BasicRequest
@synthesize mURLConnection;
@synthesize mReceivedData;
@synthesize mJson;

- (id)init
{
	self = [super init];
	if (self)
	{
		mJson = [[SBJSON alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[mJson release];
	if (mURLConnection != nil)
	{
		[mURLConnection cancel];
		[mURLConnection release];
	}
	if (mReceivedData != nil)
	{
		[mReceivedData release];
	}
	
	[super dealloc];
}

#pragma mark -
#pragma mark Error Management
/*
kErrorNoIncidentForUser ?

kErrorEmptyIncidentID				
kErrorBadIncidentID				
kErrorBadUserID					
kErrorEmptyUserID
*/
- (void)manageErrorOfStatusCode:(NSInteger)_status
{
	UIAlertView* alertView = nil;
	BOOL generalError = NO;
	
	switch (_status)
	{
		case kErrorEmptyJsonRequest:
			NSLog(@"Error: Empty Json Request");
			generalError = YES;
			break;
		case kErrorBadJsonRequest:
			NSLog(@"Error: Bad Json Request");
			generalError = YES;
			break;
		case kErrorBadRequestSubElement:
			NSLog(@"Error: Bar Request Sub-Element");
			generalError = YES;
			break;
		case kErrorEmptyDeviceIdentifier:
			NSLog(@"Error: Empty Device Identifier");
			generalError = YES;
			break;
		case kErrorBadDeviceIdentifier:
			NSLog(@"Error: Bad Device Identifier");
			generalError = YES;
			break;
		case kEmptyPositionParameter:
			NSLog(@"Empty Position Parameter");
			generalError = YES;
			break;
		case kErrorBadPositionParameter:
			NSLog(@"Bad Position Parameter");
			generalError = YES;
			break;

		case kErrorBadCategoryID:
			NSLog(@"Error: Bad Category ID");
			break;
		case kErrorEmptyCategoryID:
			NSLog(@"Error: Empty Category ID");
			break;
		case kErrorBadAddressParameter:
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_bad_address_parameter", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;

#ifdef kMarseilleTownhallVersion
		case kErrorAuthenticationFailed_BadLogin:
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_authentication_failed_bad_login", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;
		case kErrorBadUserLogin:
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_authentication_failed_bad_login", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;
		case kErrorEmptyUserLogin:
			NSLog(@"Error: Empty User Login");
			generalError = YES;
			break;
		case kErrorBadPassword:
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_authentication_failed_bad_login", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;
		case kErrorEmptyPassword:
			NSLog(@"Error: Empty Password");
			generalError = YES;
			break;
		case kErrorBadAuthentToken:
			NSLog(@"Error: Bad Authentication Token sent to Server");
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_authentication_failed_bad_login", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;
		case kErrorEmptyAuthentToken:
			NSLog(@"Error: No Authentication Token sent to Server");
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_authentication_failed_bad_login", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;
#endif
		
		case kErrorBadRadius:
			NSLog(@"Error: Bad Radius");
			generalError = YES;
			break;
		case kErrorEmptyRadius:
			NSLog(@"Error: Empty Radius");
			break;
			
		case kErrorBadIncidentPictureContent:
			NSLog(@"Error: Bad Incident Picture Content");
			break;
		case kErrorReadingTempPictureFile:
			NSLog(@"Error: Error Reading Temp Picture File");
			break;
			
		case kErrorBadJsonRequestToken:
			NSLog(@"Error: Bad Json Request Token");
			break;
		default:
			break;
	}
	if (generalError == YES)
	{
		alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
	}
	
	if (alertView != nil)
	{
		[alertView show];
		[alertView release];
	}
	
}

#pragma mark -
#pragma mark Cancel Connection
- (void)cancelRequest
{
	if (mURLConnection != nil)
	{
		[mURLConnection cancel];
	}
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"connexion_error_title", nil) message:NSLocalizedString(@"connexion_error_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
	[lAlertTmp show];
	[lAlertTmp release]; 	
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	[self.mReceivedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[self.mReceivedData appendData:data];
}


@end
