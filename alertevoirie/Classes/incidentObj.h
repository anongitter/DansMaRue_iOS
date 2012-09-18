//
//  IncidentObj.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UpdateImageCellDelegate.h"
#import "UpdateFormPictureDelegate.h"

#define kIdKey					@"id"
#define kCategoryKey			@"categoryId"
#define kConfirmsKey				@"confirms"
#define kStateKey				@"state"
#define kAddressKey				@"address"
#define kDescriptionKey			@"descriptive"
#define kDateKey				@"date"
#define kPicturesKey				@"pictures"
#define kInvalidKey				@"invalidations"

#define kFarPhotosKey			@"far"
#define kClosePhotosKey			@"close"

#define kLatitudeKey				@"lat"
#define kLongitudeKey			@"lng"
#define kPriorityKey			@"priorityId"

@interface IncidentObj : NSObject
	<MKAnnotation>
{
	CLLocationCoordinate2D	coordinate;
	NSInteger  mid;
	NSInteger  mcategory;
	NSUInteger mconfirms;
    
	BOOL minvalid;
	
	NSString* 	mstate;
	NSString* 	maddress;
	NSString*	mStreetNumber;
	NSString*	mStreet;
	NSString*	mZipCode;
	NSString*	mCity;
    
    NSInteger   mPriorityId;
    NSString*	mEmail;
	
	NSString* 	mdescriptive;
	NSString* 	mdate;
	
	NSArray* mpicturesFar;
	NSArray* mpicturesClose;
}



/*
 {	
 "id":2						//the id of the incident
 "categoryId":3,					// the category id of the incident
 "state":"resolved",				// the incident state
 "address":"2 rue colbert...",			// the address where the incident
 "descriptive":"un gros trou",			// the incident description
 "date":"yyyy-mm-dd hh:ss",			// the incident declaration date
 }
 */
- (id)initWithDic:(NSMutableDictionary*) _Dictionnary;
- (NSString*)formattedDate;
-(NSComparisonResult)compareDateWithDateOf:(IncidentObj*)incident;
@property (nonatomic) CLLocationCoordinate2D	coordinate;

@property (nonatomic, retain) NSString* 	mstate;
@property (nonatomic, retain) NSString* 	maddress;
@property (nonatomic, retain) NSString*	mStreetNumber;
@property (nonatomic, retain) NSString*	mStreet;
@property (nonatomic, retain) NSString*	mZipCode;
@property (nonatomic, retain) NSString*	mCity;

@property (nonatomic, retain) NSString* 	mdescriptive;
@property (nonatomic, retain) NSString* 	mdate;

//@property (nonatomic, retain) NSDictionary* 		mphotos;
@property (nonatomic, retain) NSArray* mpicturesFar;
@property (nonatomic, retain) NSArray* mpicturesClose;

@property (nonatomic) NSInteger mid;
@property (nonatomic) NSInteger mcategory;
@property (nonatomic) NSUInteger mconfirms;
@property (nonatomic) BOOL minvalid;

@property (nonatomic) NSInteger mPriorityId;
@property (nonatomic, retain) NSString* 	mEmail;

@end
