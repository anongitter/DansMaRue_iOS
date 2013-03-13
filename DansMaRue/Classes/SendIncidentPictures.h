//
//  SendIncidentPictures.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 11/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "sendingPictureDelegate.h"

// Values from 0.0 to 1.0
#define kCompressionQuality			0.85

@interface SendIncidentPictures : BasicRequest
{
	NSObject<sendingPictureDelegate> *mSendingPictureDelegate;
	
	// YES if the photo is sent during the incident creation process
	BOOL mIsCreatingIncident;
}

- (id)initWithDelegate:(NSObject<sendingPictureDelegate> *) _sendingPictureDelegate  incidentCreation:(BOOL)_incidentCreation;
- (void)generateSendPicture:(NSNumber *)_incidentId photo:(UIImage *)_photo type:(NSString*)_type comment:(NSString*)_comment;

@end
