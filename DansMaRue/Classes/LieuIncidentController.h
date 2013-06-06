//
//  LieuIncidentController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "MapKit/MKAnnotation.h"
#import "incidentObj.h"
#import "ReverseGeocoding.h"
#import "ValidationRapportController.h"
#import "FicheIncidentController.h"
//#import "BSForwardGeocoder.h"

#define kMapZoom		0.001

@interface LieuIncidentController : UIViewController
<ReverseGeocodingDelegate, UIAlertViewDelegate, MKMapViewDelegate, UITextFieldDelegate/*, BSForwardGeocoderDelegate*/>
{
	IBOutlet UITextField*			mTextFieldNumber;
	IBOutlet UITextField*			mTextFieldStreet;
	IBOutlet UITextField*			mTextFieldCP;
	IBOutlet UITextField*			mTextFieldCity;
	
	IBOutlet UILabel*				mLabelStreet;
	IBOutlet UILabel*				mLabelCity;
	
	IBOutlet UILabel*				mLabelSearch;
	
	IBOutlet UIButton*				mButtonValidatePosition;
	IBOutlet UIButton*				mMapControlButton;
	IBOutlet UIButton*				mSatellitePlanButton;
	
	IBOutlet UIView*				mMapControl;
	
	IBOutlet MKMapView*				mMKMapView;
	
	IBOutlet UIActivityIndicatorView*	mLoader;
	
	IncidentObj*					mIncidentCreated;
	ValidationRapportController*	mValRapController;
	FicheIncidentController*		mFicheController;
	
	//BSForwardGeocoder*				mForwardGeocoder;
	ReverseGeocoding*				mReverseGeocoding;
	
	BOOL							mReverseGeocodingDone;
	BOOL							mForwardGeocodingDone;
	BOOL							mChosePinPosition;
	
	CLLocationCoordinate2D			mCoordinate;
	
	BOOL							mIsLeaving;
	
	BOOL							mMapFullView;
}

- (id)initWithIncident:(IncidentObj *)_incident;

- (IBAction) validateButtonPressed:(id)sender;
- (IBAction) backgroundTap:(id)sender;
- (IBAction) textFieldDoneEditing:(id)sender;
- (IBAction) returnToPreviousView:(id)sender;
- (IBAction) showMapButtonPressed:(id)sender;
- (IBAction)changeMapMode;
- (void) testValidateButtonEnable;

@property (nonatomic, retain) IncidentObj*					mIncidentCreated;
@property (nonatomic, retain) ValidationRapportController*	mValRapController;
@property (nonatomic, retain) FicheIncidentController*		mFicheController;

@end
