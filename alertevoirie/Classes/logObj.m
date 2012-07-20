//
//  LogObj.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "logObj.h"

@implementation LogObj
@synthesize mUdid;
@synthesize mDate;
@synthesize mId;
@synthesize mStatus;

- (id)initWithDic:(NSMutableDictionary*) _Dictionnary
{
    self = [super init];
    if (self)
	{
		/*
		 {	
		 "id":2						//the id of the incident
		 "category":3,					// the category id of the incident
		 "state":"resolved",				// the incident state
		 "address":"2 rue colbert...",			// the address where the incident
		 "descriptive":"un gros trou",			// the incident description
		 "date":"yyyy-mm-dd hh:ss",			// the incident declaration date
		 }
		 */
		//	 {"category": "bosses", "status": "R", "date": "2010-04-23 05:03:13.424182", "descriptive": "un panneau cass\u00e9", "address": "2 rue colbert", "lat": 30.359089999999998, "lng": 9.3852100000000007, "id": 18}}
		//NSLog(@"%@",_Dictionnary);
		
		self.mId  = ((NSNumber*)[_Dictionnary valueForKey:kIncidentIdKey]).intValue;
		self.mStatus  = [_Dictionnary valueForKey:kIncidentStatusKey];
		self.mDate  = [_Dictionnary valueForKey:kIncidentDateKey];
		self.mUdid = [_Dictionnary valueForKey:kIncidentUDIDKey];
	}
	return self;
}

-(NSComparisonResult)compareDateWithDateOf:(LogObj*)_log
{
	NSComparisonResult result = [self.mDate compare:(_log.mDate)];
	if (result == NSOrderedAscending)
		return NSOrderedDescending;
	
	if (result == NSOrderedDescending)
		return NSOrderedAscending;
	
	return result;
}

@end
