//
//  BasicRequest.h
//  InfoVoirie
//
//  Created by Christophe on 12/01/11.
//  Copyright 2011 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"

@interface BasicRequest : NSObject <NSURLConnectionDelegate>
{
	SBJSON*                 mJson;
	NSMutableData*			mReceivedData;
	NSURLConnection*		mURLConnection;
}

- (void)manageErrorOfStatusCode:(NSInteger)_status;

- (void)cancelRequest;

@property (nonatomic, retain) NSURLConnection*	mURLConnection;
@property (nonatomic, retain) NSMutableData*		mReceivedData;
@property (nonatomic, retain) SBJSON*			mJson;

@end
