//
//  InfoVoirieContext.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


#error COPY THIS FILE INTO DansMaRue/Classes/InfoVoireContext.h and fill the values
#warning TO BE DEFINED


#define AV_URL_PROD                             @"http://yourServerURL.com"


#define kHockeyAppBetaId                        @"YOUR_BETA_HOCKEY_APP_ID"
#define kHockeyAppLiveId                        @"YOUR_LIVE_HOCKEY_APP_ID"


#define kServer                                 AV_URL_PROD

#define kChosenDigestLength                     CC_SHA1_DIGEST_LENGTH

#define kServerPrivateKey                       @"SERVER PRIVATE KEY"
#define kEncodeTokenKey                         @"ENCODE TOKEN KEY"


#define kTimeBetweenTokenReComputation          1800		// 1/2 hr

@interface InfoVoirieContext : NSObject
<UITabBarControllerDelegate>
{
	CLLocationCoordinate2D	mLocation;
	NSMutableDictionary		*mCategory;
	UIColor					*mTextBlueColor;
	UIColor					*mTextBlueShadowColor;
	UILabel					*mNavBarTitle;
	
	NSString*				mUserLogin;
	NSString*				mUserPassword;
	
	NSString*				mUserName;
	NSString*				mUserSurname;
	
	NSString*				mAuthenticationToken;
	NSInteger				mLastTokenComputationTimestamp;
	
	BOOL					mLocationFound;
	
	BOOL					mCreatingNewReport;
}

+ (InfoVoirieContext *)sharedInfoVoirieContext;
+ (BOOL)deviceCanMakePhoneCalls;
+ (NSString*)capitalisedFirstLetter:(NSString*)_string;
+ (UIView *)createLoadingView;
+ (UIButton *)createNavBarBackButton;
+ (UILabel *)createNavBarUILabelWithTitle:(NSString*)_title;
+ (NSString*)getServerURL:(BOOL)_photo;

+ (NSURLConnection*)launchRequestWithArray:(NSArray*)_array andDelegate:(id)_delegate;
+ (void)fillHTTPHeadersOfRequest:(NSMutableURLRequest*)_request WithJsonStream:(NSString*)_jsonStream;

+ (NSString*)getSHA1HashBytes:(NSString*)_plainText;
+ (NSString*)base64:(NSString*)inputString;

- (void)deconnectUser;
- (void)saveUserInfo;
- (void)loadUserInfo;

- (NSString*)computeAuthenticationTokenWithLogin:(NSString*)_login andPassword:(NSString*)_password;

@property (nonatomic) CLLocationCoordinate2D mLocation;
@property (nonatomic, retain) NSMutableDictionary* mCategory;
@property (nonatomic, retain) UIColor *mTextBlueColor;
@property (nonatomic, retain) UIColor *mTextBlueShadowColor;
@property (nonatomic, retain) UILabel *mNavBarTitle;
@property (nonatomic, retain) NSString* mUserLogin;
@property (nonatomic, retain) NSString* mUserPassword;
@property (nonatomic, retain) NSString* mUserName;
@property (nonatomic, retain) NSString* mUserSurname;
@property (nonatomic, retain) NSString* mAuthenticationToken;
@property (nonatomic) NSInteger mLastTokenComputationTimestamp;

@property (nonatomic) BOOL mLocationFound;
@property (nonatomic, assign) BOOL	mCreatingNewReport;
@end
