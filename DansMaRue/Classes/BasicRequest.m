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
			C4MLog(@"Error: Empty Json Request");
			generalError = YES;
			break;
		case kErrorBadJsonRequest:
			C4MLog(@"Error: Bad Json Request");
			generalError = YES;
			break;
		case kErrorBadRequestSubElement:
			C4MLog(@"Error: Bar Request Sub-Element");
			generalError = YES;
			break;
		case kErrorEmptyDeviceIdentifier:
			C4MLog(@"Error: Empty Device Identifier");
			generalError = YES;
			break;
		case kErrorBadDeviceIdentifier:
			C4MLog(@"Error: Bad Device Identifier");
			generalError = YES;
			break;
		case kEmptyPositionParameter:
			C4MLog(@"Empty Position Parameter");
			generalError = YES;
			break;
		case kErrorBadPositionParameter:
			C4MLog(@"Bad Position Parameter");
			generalError = YES;
			break;

		case kErrorBadCategoryID:
			C4MLog(@"Error: Bad Category ID");
			break;
		case kErrorEmptyCategoryID:
			C4MLog(@"Error: Empty Category ID");
			break;
		case kErrorBadAddressParameter:
			alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"error_bad_address_parameter", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
			break;		
		case kErrorBadRadius:
			C4MLog(@"Error: Bad Radius");
			generalError = YES;
			break;
		case kErrorEmptyRadius:
			C4MLog(@"Error: Empty Radius");
			break;
			
		case kErrorBadIncidentPictureContent:
			C4MLog(@"Error: Bad Incident Picture Content");
			break;
		case kErrorReadingTempPictureFile:
			C4MLog(@"Error: Error Reading Temp Picture File");
			break;
			
		case kErrorBadJsonRequestToken:
			C4MLog(@"Error: Bad Json Request Token");
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
