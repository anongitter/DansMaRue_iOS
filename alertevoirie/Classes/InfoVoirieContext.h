//
//  InfoVoirieContext.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//#define kTestServer							@"http://test.dev.playtomo.com/tools/testpost.php"
//#define kPreProdServer						@"http://alerte-voirie.ppd.c4mprod.com/api/"
//#define kProdServer							@"http://www.alertevoirie.com/api/"

#define AV_URL_DEV_LUTECE_SIRA_INTEG            @"http://dev.lutece.paris.fr/sira-integ/rest/signalement/api/"
#define AV_URL_DEV_LUTECE_SIRA_R7               @"http://dev.lutece.paris.fr/sira/rest/signalement/api/"
#define AV_URL_DEV_LUTECE_R57_SIRA              @"http://r57-sira-ws.rec.apps.paris.fr/sira/rest/signalement/api/"

#if build_configuration == 2 //appstore
    #define kDev_CociteServer						AV_URL_DEV_LUTECE_R57_SIRA
#else
    #define kDev_CociteServer						AV_URL_DEV_LUTECE_SIRA_INTEG
#endif

#define kServer								kDev_CociteServer

#define kChosenDigestLength					CC_SHA1_DIGEST_LENGTH

#define kServerPrivateKey					@"TBD"
#define kEncodeTokenKey						@"avSZ0Wg2pEeXg6YUnF"

#define kMarseilleTownhallVersion

#define kTimeBetweenTokenReComputation	1800		// 1/2 hr

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
