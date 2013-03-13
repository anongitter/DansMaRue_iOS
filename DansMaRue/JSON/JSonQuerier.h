//
//  JSonQuerier.h
//
//  Created by Olivier Bonal on 13/11/09.
//  Copyright 2009 C4M Prod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"
#import "JSonResponseHandler.h"

// PROD
#define kJSonAPIURL @"http://coach-forme.ppd.c4mprod.com/api/"


#define kJsonRequestKeyWord @"request"
#define kJsonAnswerKeyWord @"answer"
#define kJSonDeviceTokenKeyWord @"deviceToken"
#define kJSonUdidKeyWord @"udid"
#define kRegisterPushRequestKeyWord @"subscribe"


@interface JSonQuerier : NSObject {
	NSObject<JSonResponseHandler>	*responseHandler;
	NSURLConnection					*URLConnection;
	NSMutableData					*receivedData;
}

@property (nonatomic, retain) NSObject<JSonResponseHandler> *responseHandler;
@property (nonatomic, retain) NSURLConnection *URLConnection;
@property (nonatomic, retain) NSMutableData *receivedData;


- (void)performRequest:(NSString*)request withParams:(NSMutableDictionary*)params;

@end
