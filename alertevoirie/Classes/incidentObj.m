//
//  IncidentObj.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "incidentObj.h"


@implementation IncidentObj

@synthesize	mstate;
@synthesize	maddress;
@synthesize mStreetNumber;
@synthesize mStreet;
@synthesize mZipCode;
@synthesize mCity;
@synthesize	mdescriptive;
@synthesize	mdate;	
@synthesize	coordinate;
@synthesize mpicturesFar;
@synthesize mpicturesClose;
@synthesize mid;
@synthesize mcategory;
@synthesize mconfirms;
@synthesize minvalid;
@synthesize mPriorityId;
@synthesize mEmail;

- (NSString*)description
{
	return [NSString stringWithFormat:@"%d %@", mid, mdescriptive];
}

- (id)initWithDic:(NSMutableDictionary*) _dictionary
{
    self = [super init];
    if (self)
	{
		/*
		 {	
		 "id":2						//the id of the incident
		 "categoryId":3,					// the category id of the incident
		 "state":"resolved",				// the incident state
		 "invalidations":0					// invalidated incident?
		 "address":"2 rue colbert...",			// the address where the incident
		 "lat":3.359089999999998,
		 "lng":53.3852100000000007,
		 "descriptive":"un gros trou",			// the incident description
		 "date":"yyyy-mm-dd hh:ss",			// the incident declaration date
		 "confirms":3,						// number of confirmations
		 "pictures": {
			"far":[]
			"close":[]
		 }
         "priorityId": 1
		 }
		 */
	//	 {"category": 32, "status": "R", "date": "2010-04-23 05:03:13.424182", "descriptive": "un panneau cass\u00e9", "address": "2 rue colbert", "lat": 30.359089999999998, "lng": 9.3852100000000007, "id": 18}}
		NSLog(@"%@",_dictionary);
		
		self.mEmail = @"";
		self.mid  = ((NSNumber*)[_dictionary valueForKey:kIdKey]).intValue;
		self.mcategory  = ((NSNumber*)[_dictionary valueForKey:kCategoryKey]).intValue;
		self.mconfirms = ((NSNumber*)[_dictionary valueForKey:kConfirmsKey]).intValue;
		self.mstate  = [_dictionary valueForKey:kStateKey];
		self.maddress  = [_dictionary valueForKey:kAddressKey];
        self.mdate = [_dictionary valueForKey:kDateKey];
		NSString* address = [_dictionary valueForKey:kAddressKey];
		
		NSArray* addressComponents = [address componentsSeparatedByString:@"\n"];
		if ([addressComponents count] > 1)
		{
			NSMutableString* street = [NSMutableString stringWithString:[addressComponents objectAtIndex:0]];
			NSArray* streetComponents = [street componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			
			if ([((NSString*)[streetComponents objectAtIndex:0]) rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound)
			{
				self.mStreetNumber = [streetComponents objectAtIndex:0];
				[street replaceOccurrencesOfString:[NSString stringWithFormat:@"%@ ", [streetComponents objectAtIndex:0]] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [street length])];
				self.mStreet = street;
			}
			else
			{
				self.mStreet = street;
			}
			
			NSMutableString* city = [NSMutableString stringWithString:[addressComponents objectAtIndex:1]];
			NSArray* cityComponents = [city componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			
			self.mZipCode = [cityComponents objectAtIndex:0];
			self.mCity = [cityComponents objectAtIndex:1];
		}
		
		self.mdescriptive = [_dictionary valueForKey:kDescriptionKey];
		NSArray* componentsDate = [[_dictionary valueForKey:kDateKey] componentsSeparatedByString:@"."];
		self.mdate = [componentsDate objectAtIndex:0];
		
		NSDictionary* photos = [_dictionary valueForKey:kPicturesKey];
		NSNumber *invalid = [_dictionary valueForKey:kInvalidKey];
		if (invalid != nil && [invalid intValue] == 1) {
			self.minvalid = YES;
		}
		else {
			self.minvalid = NO;
		}

		//self.mphotos = [_dictionary valueForKey:@"pictures"];
		self.mpicturesFar = [photos objectForKey:kFarPhotosKey];
		self.mpicturesClose = [photos objectForKey:kClosePhotosKey];
		
		//NSMutableDictionary* lPosition = [_dictionary valueForKey:@"position"];
		coordinate.latitude = ((NSNumber*)[_dictionary valueForKey:kLatitudeKey]).doubleValue;
		coordinate.longitude = ((NSNumber*)[_dictionary valueForKey:kLongitudeKey]).doubleValue;
        
        if ([_dictionary objectForKey:kPriorityKey]){
            
            if ([[_dictionary objectForKey:kPriorityKey] isKindOfClass:[NSDictionary class]]){
                
                NSDictionary* priorityDic = (NSDictionary*)[_dictionary valueForKey:kPriorityKey];
                self.mPriorityId = ((NSNumber*)[priorityDic objectForKey:@"id"]).intValue;
                
            } if ([[_dictionary objectForKey:kPriorityKey] isKindOfClass:[NSNumber class]]){
                
                self.mPriorityId = ((NSNumber*)[_dictionary valueForKey:kPriorityKey]).intValue;
            }
                
        } else {
            self.mPriorityId = 3;
        }
        
	}
	return self;
}

- (NSString*)maddress
{
	if (mStreet != nil && mCity != nil)
	{
		return [NSString stringWithFormat:@"%@%@\n%@ %@", mStreetNumber?[NSString stringWithFormat:@"%@ ", mStreetNumber] : @"", mStreet, mZipCode, mCity];
	}
	else
	{
		return maddress;
	}
}

- (NSString*)title 
{
	return mdescriptive;
}

//Not here :
- (NSString*)formattedDate
{
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:kDateFormat];
	
	NSDate *formatterDate = [inputFormatter dateFromString:self.mdate];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"'le' EEEE d MMMM"];
	[dateFormatter setLocale:locale];
	NSString* newDateString = [dateFormatter stringFromDate:formatterDate];
	NSString* date = [NSString stringWithFormat:@"%@.", newDateString];
	
	[dateFormatter release];
	[inputFormatter release];
	[locale release];
	return date;
}

-(NSComparisonResult)compareDateWithDateOf:(IncidentObj*)incident
{
	NSComparisonResult result = [self.mdate compare:(incident.mdate)];
	if(result == NSOrderedAscending)
		return NSOrderedDescending;
	if(result == NSOrderedDescending)
		return NSOrderedAscending;
	
	return result;
}

@end
