//
//  FullscreenLieuIncidentController.h
//  ParisDansMaRue
//
//  Created by Damien Praca on 10/25/13.
//
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "MapKit/MKAnnotation.h"
#import "incidentObj.h"
#import "ReverseGeocoding.h"
#import "ValidationRapportController.h"
#import "FicheIncidentController.h"

#define kMapZoom		0.001

@interface FullscreenLieuIncidentController : UIViewController <ReverseGeocodingDelegate, UIAlertViewDelegate, MKMapViewDelegate, UITextFieldDelegate> {
    
    IBOutlet MKMapView *mMapView;
    IBOutlet UIButton *mCancelBtn;
    IBOutlet UITextField *mSearchField;
    IBOutlet UIView *mBottonBar;
    IBOutlet UILabel *mStreetLabel;
    IBOutlet UILabel *mCityLabel;
    IBOutlet UIButton *mMyLocationBtn;
    IBOutlet UIButton *mValidateBtn;

    CLLocationCoordinate2D			mCoordinate;
    
    IncidentObj*					mIncidentCreated;
	ValidationRapportController*	mValRapController;
	FicheIncidentController*		mFicheController;
	ReverseGeocoding*				mReverseGeocoding;
    
    BOOL							mReverseGeocodingDone;
	BOOL							mForwardGeocodingDone;
	BOOL							mChosePinPosition;
    BOOL							mIsLeaving;
    
}

@property (retain, nonatomic) IBOutlet MKMapView *mMapView;
@property (retain, nonatomic) IBOutlet UIButton *mCancelBtn;
@property (retain, nonatomic) IBOutlet UITextField *mSearchField;
@property (retain, nonatomic) IBOutlet UIView *mBottonBar;
@property (retain, nonatomic) IBOutlet UILabel *mStreetLabel;
@property (retain, nonatomic) IBOutlet UILabel *mCityLabel;
@property (retain, nonatomic) IBOutlet UIButton *mMyLocationBtn;
@property (retain, nonatomic) IBOutlet UIButton *mValidateBtn;

-(void)animateBottomBarUp;
-(void)animateBottomBarDown;

- (id)initWithIncident:(IncidentObj *)_incident;
- (id)initWithFicheViewController:(FicheIncidentController *) _ficheController;
- (id)initWithViewController:(ValidationRapportController *)_valController;

- (IBAction)backgroundTap:(id)sender;
- (IBAction)onCancelAction:(id)sender;
- (IBAction)onLocationAction:(id)sender;
- (IBAction)onValidateAction:(id)sender;

@property (nonatomic, retain) IncidentObj*					mIncidentCreated;
@property (nonatomic, retain) ValidationRapportController*	mValRapController;
@property (nonatomic, retain) FicheIncidentController*		mFicheController;

@end
