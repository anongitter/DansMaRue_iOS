//
//  SendIncidentPictures.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 11/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "SendIncidentPictures.h"

@implementation SendIncidentPictures

- (id)initWithDelegate:(NSObject<sendingPictureDelegate> *) _sendingPictureDelegate  incidentCreation:(BOOL)_incidentCreation
{
	self = [super init];
	if (self)
	{
		mSendingPictureDelegate = [_sendingPictureDelegate retain];
		mIsCreatingIncident = _incidentCreation;
	}
	
	return self;
}

- (void)dealloc
{
	[mSendingPictureDelegate release];
	
	[super dealloc];
}

/*- (NSString*)base64Encoding:(NSData *)_Data
{
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	if ([_Data length] == 0)
		return @"";
	
	char *characters = malloc((([_Data length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [_Data length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [_Data length])
			buffer[bufferLength++] = ((char *)[_Data bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';    
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}*/

- (void)generateSendPicture:(NSNumber *)_incidentId photo:(UIImage *)_photo type:(NSString*)_type comment:(NSString*)_comment
{
	self.mReceivedData = [NSMutableData data];
	if(_photo == nil)
	{
		UIAlertView * alertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"photo_error", nil) message:NSLocalizedString(@"photo_not_saved", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertTmp show];
		[alertTmp release];
	}
	
	NSData* data = UIImageJPEGRepresentation(_photo, kCompressionQuality);
	if(data == nil)
	{
		UIAlertView * alertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"photo_error", nil) message:NSLocalizedString(@"photo_not_converted", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertTmp show];
		[alertTmp release]; 
		return;
	}
	
	//_comment = [self base64Encoding:[_comment dataUsingEncoding:NSUTF8StringEncoding]];
	_comment = [InfoVoirieContext base64:_comment];
	
	NSString* stringurl = [InfoVoirieContext getServerURL:YES];
	NSURL* url = [NSURL URLWithString:stringurl];
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setTimeoutInterval: kTimeOutIntervalRequest];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:data];
	
	[request setValue:@"binary/octet-stream" forHTTPHeaderField:@"Content-type"];
	[request addValue:[[UIDevice currentDevice] uniqueDeviceIdentifier] forHTTPHeaderField:@"udid"];
	[request setValue:_comment forHTTPHeaderField:@"img_comment"];
	[request setValue:[NSString stringWithFormat:@"%d", [_incidentId integerValue]] forHTTPHeaderField:@"incident_id"];
	[request setValue:_type forHTTPHeaderField:@"type"];
	
	if (mIsCreatingIncident == YES)
	{
		[request setValue:@"YES" forHTTPHeaderField:@"incident_creation"];
	}
	
	C4MLog(@"request header = %@", [request allHTTPHeaderFields]);
	

	
	mURLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	[request release];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[mSendingPictureDelegate didSendPictureOk:NO];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	BOOL success;
	
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	C4MLog(@"<<-- didReceiveData : %@", filesContent);
	
	NSMutableDictionary* rootJson = [mJson objectWithString:filesContent error:nil];
	NSMutableDictionary* answer = [rootJson objectForKey:@"answer"];
	if(answer == nil)
	{
		success = NO;
	}
	else
	{
		NSNumber *status_code = [answer objectForKey:@"status"];
		if ([status_code intValue] == 0)
		{
			success = YES;
		}
		else
		{
			success = NO;
			[self manageErrorOfStatusCode:[status_code intValue]];
		}
	}
	
	[filesContent release];
	[mSendingPictureDelegate didSendPictureOk:success];
}


@end
