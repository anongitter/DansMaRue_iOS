//
//  JSonQuerier.m
//
//  Created by Olivier Bonal on 13/11/09.
//  Copyright 2009 C4M Prod. All rights reserved.
//

#import "JSonQuerier.h"


@implementation JSonQuerier

@synthesize responseHandler;
@synthesize URLConnection;
@synthesize receivedData;


- (void)performRequest:(NSString*)requestKeyWord withParams:(NSMutableDictionary*)params {
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:params];
	
	C4MLog(@"Sending %@ with params:%@", requestKeyWord, params);
	
	[dic setObject:requestKeyWord forKey:kJsonRequestKeyWord];
	SBJSON *json = [[SBJSON alloc] init];
	
	// Wrap in an array as jSon is structured to allow several requests	on one call
	//NSArray* wrapper_array = [NSArray arrayWithObject:dic];
	
	//NSString* json_string = [NSString stringWithFormat:@"jsonStream=%@", [json stringWithObject:wrapper_array]];
	NSString* json_string = [NSString stringWithFormat:@"jsonStream=%@", [json stringWithObject:dic]];
	[json release];
	
	C4MLog(@"Sending %@", json_string);

	
	NSData *body = [json_string dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:kJSonAPIURL];

	
	// Perform Request
	self.receivedData = [NSMutableData data];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	[URLConnection cancel];
	[request setTimeoutInterval: kTimeOutIntervalRequest];
		
	[request setHTTPMethod:@"POST"];
	if (body != nil) {
		[request setHTTPBody:body];
	}
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	self.URLConnection = connection;
	[connection release];
	[request release];
	
}

#pragma mark -
#pragma mark Connection Delegate Methods

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	C4MLog(@"JSonQuerier connection failed -- %@", [error localizedDescription]);
	C4MLog(@"JSonQuerier code:%d  ------  domain:%@", [error code], [error domain]);
	
	// This commented code can be used in the response handler for instance.
	//if ([error code] == NSURLErrorNotConnectedToInternet) {
	//if ( [[[self cacheManager] allArticles] count] <= 0) {
	
	//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message.info.no_connection.title",nil)
	//														message:NSLocalizedString(@"message.info.no_connection.body",nil)
	//													   delegate:self cancelButtonTitle:NSLocalizedString(@"message.info.no_connection.button.title",nil)
	//											  otherButtonTitles:nil];
	//	[alertView show];
	//	[alertView release];
	
	
	//}

	[responseHandler jsonRequestFailed:error];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.receivedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    /* Append the new data to the received data. */
	[self.receivedData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
		
	NSString* filesContent = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	//NSLog(@"JSonQuerier: JSON Response String: %@", filesContent);
	
	[responseHandler parseJSonResponse:filesContent];
	[filesContent release];
}

# pragma mark -
# pragma mark Memory dealloc
- (void)dealloc {
	[responseHandler release];
	[URLConnection release];
	[receivedData release];
	[super dealloc];
}

@end
