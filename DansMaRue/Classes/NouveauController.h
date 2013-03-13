//
//  NouveauController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import "incidentStatsDelegate.h"
#import "GetIncidentStats.h"
#import "UserAuthentication.h"
#import "ConfirmDeclarationController.h"
#import "reportDelegate.h"
#import "categoriesDelegate.h"
#import "C4MInfo.h"

//#define kTitleImageName							@"title.png"
#define kTitleImageName							@"dans_ma_rue.jpg"

@interface NouveauController : UIViewController
	<incidentStatsDelegate, reportDelegate, userAuthenticationDelegate, UITextFieldDelegate, categoriesDelegate>
{
	IBOutlet UIView*						mViewWelcomeUser;
	IBOutlet UILabel*						mLabelWelcomeUser;
	IBOutlet UIButton*					mButtonDeconnexion;
	
	IBOutlet UIButton*					mButtonNewIncident;
	IBOutlet UIButton*					mButtonInfo;
	IBOutlet UIButton*					mButtonLogin;
	
	IBOutlet UILabel*						mLabelTextIncidents;
	
	IBOutlet UILabel*						mLabelOngoingIncidents;
	IBOutlet UILabel*						mLabelUpdatedIncidents;
	IBOutlet UILabel*						mLabelResolvedIncidents;
	
	IBOutlet UILabel*						mLabelTextOngoingIncidents;
	IBOutlet UILabel*						mLabelTextUpdatedIncidents;
	IBOutlet UILabel*						mLabelTextResolvedIncidents;
	
	IBOutlet UIActivityIndicatorView*		mIndicatorView;
	
	IBOutlet UIView*						mViewLogin;
	IBOutlet UITextField*					mTextFieldLogin;
	IBOutlet UITextField*					mTextFieldPassword;
	
	NSInteger							mLoadingOngoing;
	BOOL								mHasBeenGeolocated;
}

- (IBAction)infoButtonPressed;
- (IBAction)createReportButtonPressed;
- (IBAction)launchLoginButtonPressed;
- (IBAction)loginButtonPressed;
- (IBAction)deconnexionButtonPressed;
- (IBAction)textFieldEndEditing:(id)sender;

- (void)reloadIncidentStats;

@end
