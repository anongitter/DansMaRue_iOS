//
//  LogObj.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kIncidentIdKey		@"incidentId"
#define kIncidentStatusKey	@"status"
#define kIncidentDateKey	@"date"
#define kIncidentUDIDKey	@"udid"

@interface LogObj : NSObject
{
	NSInteger mId;
	NSString* mUdid;
	NSString* mDate;
	NSString* mStatus;
}

@property (nonatomic, retain) NSString* mUdid;
@property (nonatomic, retain) NSString* mDate;
@property (nonatomic, retain) NSString* mStatus;
@property (nonatomic) NSInteger mId;

@end
