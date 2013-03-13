//
//  InfoVoirieContext.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "InfoVoirieContext.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "SBJSON.h"

@implementation InfoVoirieContext
@synthesize mLocation;
@synthesize mCategory;
@synthesize mTextBlueColor;
@synthesize mTextBlueShadowColor;
@synthesize mNavBarTitle;
@synthesize mLocationFound;
@synthesize mUserLogin;
@synthesize mUserPassword;
@synthesize mUserName;
@synthesize mUserSurname;
@synthesize mLastTokenComputationTimestamp;
@synthesize mCreatingNewReport;

static InfoVoirieContext *	sharedInfoVoirieContextInstance = nil;

+ (InfoVoirieContext *)sharedInfoVoirieContext
{
	if (sharedInfoVoirieContextInstance == nil)
	{
		sharedInfoVoirieContextInstance = [[InfoVoirieContext alloc] init];
	}
	return sharedInfoVoirieContextInstance;
}


- (id) init
{
	if (self = [super init])
	{
		//Loading Categories in local file
        /*
        SBJSON *json = [[SBJSON alloc] init];
		NSString* path  = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"json"];
		NSString* filesContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		NSMutableDictionary* dic =  [json objectWithString:filesContent error:nil];
		[json release];
		self.mCategory = dic;
         */
		
		self.mTextBlueColor = [UIColor colorWithRed:0.1764 green:0.549 blue:0.7804 alpha:1.0];
		self.mTextBlueShadowColor = [UIColor colorWithRed:0.1764 green:0.549 blue:0.7804 alpha:0.5];
		
		
		UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		title.backgroundColor = [UIColor clearColor];
		title.font = [UIFont boldSystemFontOfSize:20.0];
		title.textColor = self.mTextBlueColor;
		title.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		title.textAlignment = UITextAlignmentCenter;
		self.mNavBarTitle = title;
		[title release];
		
		self.mLocationFound = NO;
		
		mLastTokenComputationTimestamp = 0;
		
		[self loadUserInfo];
	}
	return self;
}

+ (UIView *)createLoadingView
{
	UIView *loadingView = nil;
	NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil];
	for (id oneObject in nib)
	{
		if ([oneObject isKindOfClass:[UIView class]])
		{
			loadingView = (UIView*)oneObject;
		}
	}
	
	return loadingView;
}

+ (UIButton *)createNavBarBackButton
{
	UIButton *buttonView = [[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 65, 44)] autorelease];
	[buttonView setImage:[UIImage imageNamed:@"hdr_btn_back_off.png"] forState:UIControlStateNormal];
	[buttonView setImage:[UIImage imageNamed:@"hdr_btn_back_on.png"] forState:UIControlStateHighlighted];
	return buttonView;
}

+ (UILabel *)createNavBarUILabelWithTitle:(NSString*)_title
{
	UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
	title.backgroundColor = [UIColor clearColor];
	title.font = [UIFont boldSystemFontOfSize:20.0];
	title.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
	//title.shadowColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueShadowColor];
	title.shadowColor = [UIColor clearColor];
	title.textAlignment = UITextAlignmentCenter;
	title.text = _title;
	return title;
}


+ (NSString*)capitalisedFirstLetter:(NSString*)_string
{
	if ([_string length] == 0)
	{
		return _string;
	}
	NSString* capitalisedSentence = [_string stringByReplacingCharactersInRange:NSMakeRange(0,1)  
																	 withString:[[_string substringToIndex:1] capitalizedString]];
	return capitalisedSentence;
}

+ (BOOL)deviceCanMakePhoneCalls
{
	NSString* modelName = [[UIDevice currentDevice] model];
	
	if (modelName == nil)
		return NO;
	
	BOOL result = ([modelName rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].location != NSNotFound);
	
	if (result == YES)
		return ([modelName rangeOfString:@"Simulator" options:NSCaseInsensitiveSearch].location == NSNotFound);
	
	return NO;
}

+ (NSString*)getServerURL:(BOOL)_photo
{
	if (_photo == YES)
	{
		return [NSString stringWithFormat:@"%@%@", kServer, @"photo/"];
	}
	return kServer;
}

#pragma mark -
#pragma mark Authentication Methods
- (void)saveUserInfo
{
	[[NSUserDefaults standardUserDefaults] setValue:mUserLogin forKey:@"user_login"];
	[[NSUserDefaults standardUserDefaults] setValue:mUserPassword forKey:@"user_password"];
	
	[[NSUserDefaults standardUserDefaults] setValue:mUserName forKey:@"user_name"];
	[[NSUserDefaults standardUserDefaults] setValue:mUserSurname forKey:@"user_surname"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadUserInfo
{
	mUserLogin = [[[NSUserDefaults standardUserDefaults] valueForKey:@"user_login"] retain];
	mUserPassword = [[[NSUserDefaults standardUserDefaults] valueForKey:@"user_password"] retain];
	
	mUserName = [[[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"] retain];
	mUserSurname = [[[NSUserDefaults standardUserDefaults] valueForKey:@"user_surname"] retain];
}

- (void)deconnectUser
{
	[mAuthenticationToken release];
	mAuthenticationToken = nil;
	
	if (mUserLogin != nil)
	{
		[mUserLogin release];
		mUserLogin = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_login"];
		[mUserPassword release];
		mUserPassword = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_password"];
		
		[mUserName release];
		mUserName = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_name"];
		[mUserSurname release];
		mUserSurname = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_surname"];
		
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"map_type"];
	}
}


- (void)setMAuthenticationToken:(NSString *)_token
{
	if (mAuthenticationToken != nil)
	{
		[mAuthenticationToken release];
		mAuthenticationToken = nil;
	}
	mAuthenticationToken = [_token retain];
}


- (NSString*)mAuthenticationToken
{
	//NSLog(@"%f", [[NSDate date] timeIntervalSince1970] - mLastTokenComputationTimestamp);
	
	if ([[NSDate date] timeIntervalSince1970] - mLastTokenComputationTimestamp >= kTimeBetweenTokenReComputation)
	{
		return [self computeAuthenticationTokenWithLogin:mUserLogin andPassword:mUserPassword ];
	}
	
	//NSLog(@"mAuthenticationToken = %@", mAuthenticationToken);
	
	return mAuthenticationToken;
}

- (NSString*)computeAuthenticationTokenWithLogin:(NSString*)_login andPassword:(NSString*)_password
{
	if (_login == nil || _password == nil)
	{
		return nil;
	}
	
	NSLog(@"generate new authentication token");
	
	if (mUserLogin != nil)
	{
		[mUserLogin release];
		mUserLogin = nil;
		[mUserPassword release];
		mUserPassword = nil;
	}
	mUserLogin = [_login retain];
	mUserPassword = [_password retain];
	
	NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
	mLastTokenComputationTimestamp = timestamp;
	
	// step1
	NSString* encodedPassword = [InfoVoirieContext getSHA1HashBytes:_password];
	// step2
	NSString* concatenatedString = [NSString stringWithFormat:@"%@%d%@", [encodedPassword lowercaseString], timestamp, kEncodeTokenKey];
	// step3
	NSString* encryptedString = [InfoVoirieContext getSHA1HashBytes:concatenatedString];
	// step4
	NSString* finalString = [NSString stringWithFormat:@"token=%@;ts=%d;login=%@", [encryptedString lowercaseString], timestamp, _login];
	// step5
	mAuthenticationToken = [[InfoVoirieContext base64:finalString] retain];
	
	return mAuthenticationToken;
}

#pragma mark -
#pragma mark Requests
+ (void)fillHTTPHeadersOfRequest:(NSMutableURLRequest*)_request WithJsonStream:(NSString*)_jsonStream
{
	//NSString* base64_jsonStream = [InfoVoirieContext base64:_jsonStream];
	
	NSString* concatenated_signature_items = [NSString stringWithFormat:@"%@%@", kServerPrivateKey, _jsonStream];
	NSString* signature = [[InfoVoirieContext getSHA1HashBytes:concatenated_signature_items] lowercaseString];
	[_request setValue:signature forHTTPHeaderField:@"x-app-request-signature"];
	NSLog(@"x-app-request-signature : %@", signature);
	
	[_request setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forHTTPHeaderField:@"x-app-version"];
    NSLog(@"x-app-version : %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
    
	[_request setValue:@"iphone_family" forHTTPHeaderField:@"x-app-platform"];
    NSLog(@"x-app-platform : %@", @"iphone_family");
    
	[_request setValue:[[UIDevice currentDevice] model] forHTTPHeaderField:@"x-app-device-model"];
    NSLog(@"x-app-device-model : %@", [[UIDevice currentDevice] model]);
    
    
}

+ (NSURLConnection*)launchRequestWithArray:(NSArray*)_array andDelegate:(id)_delegate
{
	SBJSON* json = [[SBJSON alloc] init];
	
	NSString* jsonStream = [json stringWithObject:_array];
	[json release];
	
	
	NSString* json_string = [NSString stringWithFormat:@"jsonStream=%@", jsonStream];
	
	NSLog(@"%@",json_string);
	
	NSData *request_body = [json_string dataUsingEncoding:NSUTF8StringEncoding];
	NSString* stringurl = [InfoVoirieContext getServerURL:NO];
	NSURL * url=[NSURL URLWithString:stringurl];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setTimeoutInterval: kTimeOutIntervalRequest];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:request_body];
	[InfoVoirieContext fillHTTPHeadersOfRequest:request WithJsonStream:jsonStream];
	
	NSURLConnection* connection = [[[NSURLConnection alloc] initWithRequest:request delegate:_delegate startImmediately:YES] autorelease];
	[request release];
    
	return connection;
}

#pragma mark -
#pragma mark Encryption Methods

#pragma mark Secure Hash Algorithm
+ (NSString*) getSHA1HashBytes:(NSString*)_plainText
{
	//NSLog(@"input sha1:%@", plainText);
	CC_SHA1_CTX ctx;
	uint8_t * hashBytes = NULL;
	const char *cStr = [_plainText UTF8String];
	
	// Malloc a buffer to hold hash.
	hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
	memset((void *)hashBytes, 0x0, sizeof(uint8_t));
	
	// Initialize the context.
	CC_SHA1_Init(&ctx);
	// Perform the hash.
	CC_SHA1_Update(&ctx, cStr, [_plainText length]);
	// Finalize the output.
	CC_SHA1_Final(hashBytes, &ctx);
	
	// Build up the SHA1 blob.
	NSString* string = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						hashBytes[0], hashBytes[1], hashBytes[2], hashBytes[3], hashBytes[4], hashBytes[5], hashBytes[6], hashBytes[7],
						hashBytes[8], hashBytes[9], hashBytes[10], hashBytes[11], hashBytes[12], hashBytes[13], hashBytes[14], hashBytes[15],
						hashBytes[16], hashBytes[17], hashBytes[18], hashBytes[19]
						];
	
	//NSLog(@"output sha1:%@", string);
	//hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)sizeof(uint8_t)];
	
	if (hashBytes)
	{
		free(hashBytes);
	}
	
	return string;
}

#pragma mark Base64
+ (NSString*)base64Encoding:(NSData *)_data
{
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	if ([_data length] == 0)
		return @"";
	
	char *characters = malloc((([_data length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [_data length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [_data length])
			buffer[bufferLength++] = ((char *)[_data bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';    
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

+ (NSString*)base64:(NSString*)_string
{
	return [InfoVoirieContext base64Encoding:[_string dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Tab Bar Delegate Methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if (tabBarController.selectedIndex == 0 && viewController == [[tabBarController viewControllers] objectAtIndex:0] && mCreatingNewReport == YES)
	{
		return NO;
	}
	
	return YES;
}

#pragma mark -
#pragma mark Dealloc methods
- (void) dealloc 
{
	[mCategory release];
	[mTextBlueColor release];
	[mTextBlueShadowColor release]; 
	[mNavBarTitle release];
	
	if (mAuthenticationToken != nil)
	{
		[mAuthenticationToken release];
	}
	if (mUserLogin != nil)
	{
		[mUserLogin release];
	}
	if (mUserPassword != nil)
	{
		[mUserPassword release];
	}
	
	[mUserName release];
	[mUserSurname release];
	
	[super dealloc];
}

@end
