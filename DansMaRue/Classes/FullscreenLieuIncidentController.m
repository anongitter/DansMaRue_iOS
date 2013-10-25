//
//  FullscreenLieuIncidentController.m
//  ParisDansMaRue
//
//  Created by Damien Praca on 10/25/13.
//
//

#import "FullscreenLieuIncidentController.h"
#import "ValidationRapportController.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "InfoVoirieContext.h"
#import <AddressBook/AddressBook.h>

@interface FullscreenLieuIncidentController ()

@end

@implementation FullscreenLieuIncidentController

@synthesize mIncidentCreated;
@synthesize mValRapController;
@synthesize mFicheController;
@synthesize mMapView;
@synthesize mCancelBtn;
@synthesize mSearchField;
@synthesize mBottonBar;
@synthesize mStreetLabel;
@synthesize mCityLabel;
@synthesize mMyLocationBtn;
@synthesize mValidateBtn;

-(BOOL) shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (id)initWithIncident:(IncidentObj *)_incident
{
	self = [self initWithNibName:@"FullscreenLieuIncidentController" bundle:nil];
	if (self) {
		self.mIncidentCreated = _incident;
		self.mValRapController = nil;
		self.mFicheController = nil;
		mCoordinate = [[InfoVoirieContext sharedInfoVoirieContext] mLocation];
	}
	return self;
}

- (id)initWithViewController:(ValidationRapportController *)_valController
{
	self = [self initWithNibName:@"FullscreenLieuIncidentController" bundle:nil];
	if (self) {
		self.mIncidentCreated = _valController.mIncidentCreated;
		self.mValRapController = _valController;
		self.mFicheController = nil;
		mCoordinate = self.mIncidentCreated.coordinate;
	}
	return self;
}

- (id)initWithFicheViewController:(FicheIncidentController *) _ficheController
{
	self = [self initWithNibName:@"FullscreenLieuIncidentController" bundle:nil];
	if (self) {
		self.mIncidentCreated = _ficheController.mIncident;
		self.mValRapController = nil;
		self.mFicheController = _ficheController;
		mCoordinate = self.mIncidentCreated.coordinate;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mReverseGeocoding = [[ReverseGeocoding alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mStreetLabel.text = @"";
	self.mCityLabel.text = @"";
    self.mSearchField.text = @"";
    self.mMyLocationBtn.hidden = NO;
    mReverseGeocodingDone = NO;
	mForwardGeocodingDone = NO;
	mChosePinPosition = NO;
    
    UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"precise_incident_place", nil)];
	[self.navigationItem setTitleView:label];
    UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(returnToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
    
    [self.mMapView setShowsUserLocation:YES];
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(backgroundTap:)];
    [self.mMapView addGestureRecognizer:tapRec];
    [tapRec release];
    
    UILongPressGestureRecognizer* longTapRec = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longTap:)];
    [self.mMapView addGestureRecognizer:longTapRec];
    [longTapRec release];
    
    // By default, set coordinate to paris notre dame
    [self.mMapView removeAnnotations:[self.mMapView annotations]];
    if (mCoordinate.longitude == 0.0f && mCoordinate.latitude == 0.0f)
    {
        mCoordinate = CLLocationCoordinate2DMake(48.853433,2.348308);
    }
    DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:mCoordinate addressDictionary:nil];
    
    if (mFicheController == nil && mValRapController == nil)
	{
		annotation.title = NSLocalizedString(@"position_of_your_incident", nil);
	}
	else
	{
		if ([mIncidentCreated mdescriptive] == nil || [[mIncidentCreated mdescriptive] length] == 0 || [[mIncidentCreated mdescriptive] isEqualToString:NSLocalizedString(@"comment_needed", nil)])
		{
			annotation.title = NSLocalizedString(@"position_of_your_incident", nil);
		}
		else
		{
			annotation.title = mIncidentCreated.mdescriptive;
		}
		
		if ([mIncidentCreated mStreet] != nil && [mIncidentCreated mCity] != nil)
		{
			mStreetLabel.text = [NSString stringWithFormat:@"%@ %@", [mIncidentCreated mStreetNumber], [mIncidentCreated mStreet]];
			mCityLabel.text = [NSString stringWithFormat:@"%@ %@", [mIncidentCreated mZipCode], [mIncidentCreated mCity]];
		}
		else
		{
            if ([mIncidentCreated maddress] != nil && [[mIncidentCreated maddress] length] != 0)
            {
                NSArray* addressArray = [[mIncidentCreated maddress] componentsSeparatedByString:@"\n"];
                
                if (addressArray != nil && [addressArray count] > 0)
                {
                    NSMutableString* street = [NSMutableString stringWithString:[addressArray objectAtIndex:0]];
                    NSString* number = [[street componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:0];
                    
                    NSRange range;
                    range.location = 0;
                    range.length = [number length]+1;
                    [street deleteCharactersInRange:range];
                    
                    mStreetLabel.text = [NSString stringWithFormat:@"%@ %@", number, street];
                }
                
                if (addressArray != nil && [addressArray count] > 1)
                {
                    mCityLabel.text = [addressArray objectAtIndex:1];
                }
            }
		}
	}
    [self.mMapView addAnnotation:annotation];
	
	[annotation release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    
    //Set default location
	MKCoordinateRegion region;
	region.center = [[[self.mMapView annotations] lastObject] coordinate];
    if (region.center.longitude == 0.0f && region.center.latitude == 0.0f)
    {
        region.center = CLLocationCoordinate2DMake(48.853433,2.348308);
    }
    region.span = MKCoordinateSpanMake(.001, .001);
	[self.mMapView setRegion:region];
    
    
    
    if (mFicheController == nil && mValRapController == nil)
	{
        [mReverseGeocoding launchReverseGeocodingForLocation:[[InfoVoirieContext sharedInfoVoirieContext] mLocation]];
		mReverseGeocodingDone = NO;
		mForwardGeocodingDone = NO;
		
        // Forward geocode!
        if (mStreetLabel.text != nil || mCityLabel.text != nil)
        {
            [self launchFowardGeocoderWithAddress:[NSString stringWithFormat:@"%@ %@", mStreetLabel.text, mCityLabel.text]];
        }
		
		mValidateBtn.enabled = NO;
	}
    
    CGRect b = mBottonBar.frame;
    b.origin.y += 66;
    mBottonBar.frame = b;
    
}

#pragma mark -
#pragma mark Annimations

-(void)animateBottomBarUp
{
    CGRect fromFrame = self.mBottonBar.frame;
    fromFrame.origin.y = self.view.frame.size.height-fromFrame.size.height;
    CGRect toFrame = fromFrame;
    [UIView animateWithDuration:0.3
                          delay:0.3
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.mBottonBar.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];

}

-(void)animateBottomBarDown
{
    CGRect fromFrame = self.mBottonBar.frame;
    fromFrame.origin.y = self.view.frame.size.height-fromFrame.size.height+66;
    CGRect toFrame = fromFrame;
    [UIView animateWithDuration:0.3
                          delay:0.3
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.mBottonBar.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


#pragma mark -
#pragma mark Actions

- (IBAction) returnToPreviousView:(id)sender
{
	mIsLeaving = YES;
    
	if (mReverseGeocoding != nil)
    {
        mReverseGeocoding.mDelegate = nil;
		[mReverseGeocoding cancelCurrentReverseGeocoding];
	}
    
	[self.navigationController popViewControllerAnimated:YES];
	self.mMapView.delegate = nil;
}

- (IBAction)onCancelAction:(id)sender {
    
    self.mSearchField.text = @"";
    
}

- (IBAction)onLocationAction:(id)sender {
    
    CLLocationCoordinate2D location = [[[self.mMapView userLocation] location] coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(.001, .001));
    [self.mMapView setRegion:region animated:YES];
    
}

- (IBAction)onValidateAction:(id)sender {
}


- (IBAction) textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	mForwardGeocodingDone = NO;
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    C4MLog(@"textFieldShouldEndEditing start");
	if (mIsLeaving == YES)
	{
		return YES;
	}
	
    // Forward geocode!
    if ([self.mSearchField.text length] != 0)
    {
		[self launchFowardGeocoderWithAddress:self.mSearchField.text];
    }
    C4MLog(@"textFieldShouldEndEditing end");
	return YES;
}

- (IBAction) backgroundTap:(id)sender
{
	[self.mSearchField resignFirstResponder];
    
    //TODO : animate down
    [self animateBottomBarDown];
    self.mValidateBtn.enabled = NO;

    
}

- (IBAction) longTap:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self.mSearchField resignFirstResponder];
        [self.mMapView removeAnnotations:[self.mMapView annotations]];
        CGPoint touchLocation = [gestureRecognizer locationInView:self.mMapView];
        
        CLLocationCoordinate2D coordinate;
        coordinate = [self.mMapView convertPoint:touchLocation toCoordinateFromView:self.mMapView];
        
        DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil];
        annotation.title = NSLocalizedString(@"position_of_your_incident", nil);
        [self.mMapView addAnnotation:annotation];
        [annotation release];
        
        [mReverseGeocoding launchReverseGeocodingForLocation:coordinate];
    }
}

#pragma mark -
#pragma mark Alert View Delegate Methods



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != alertView.cancelButtonIndex)
	{
        
	}
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{
	DDAnnotation *annotation = notification.object;
	[mReverseGeocoding launchReverseGeocodingForLocation:annotation.coordinate];
}

#pragma mark -
#pragma mark Map View Delegate Methods

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self animateBottomBarUp];
    self.mValidateBtn.enabled = YES;
}

- (void)mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)annotationViews
{
    for (MKAnnotationView *annView in annotationViews)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:0.5
                         animations:^{ annView.frame = endFrame; }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (oldState == MKAnnotationViewDragStateDragging)
	{
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
        [mReverseGeocoding launchReverseGeocodingForLocation:annotation.coordinate];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString* annotationViewIdentifier = @"annotationViewIdentifier";
	
	MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
	if (view == nil)
	{
		view = [[[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier] autorelease];
		
		if ([view isKindOfClass:[DDAnnotationView class]])
		{
			((DDAnnotationView *)view).mapView = mapView;
		} else
		{
			// NOTE: view will be draggable enabled MKPinAnnotationView when running under iOS 4.
		}
	}
	[view setCanShowCallout:YES];
	
	return view;
}


#pragma mark -
#pragma mark Reverse Geocoder Delegate Methods  lon,lat ----> address

- (void)reverseGeocoder:(CLGeocoder*)_Geocoder didFailWithError:(NSError*)_Error
{
	C4MLog(@"reverseGeocoder didFail");
}


- (void)reverseGeocoder:(CLGeocoder*)_Geocoder didFindPlacemark:(NSArray*)_Placemarks
{
    CLPlacemark* lPacemark = nil;
    
    if ([_Placemarks count] > 0)
    {
        lPacemark = [_Placemarks objectAtIndex:0];
    }
    
	C4MLog(@"didFindPlacemark : %@", lPacemark);
	if (lPacemark.postalCode != nil && lPacemark.locality != nil)
	{
		self.mCityLabel.text = [NSString stringWithFormat:@"%@ %@", lPacemark.postalCode, lPacemark.locality];
	}
	
    NSString* num = @"";
	if ([lPacemark.subThoroughfare rangeOfString:@"-"].location == NSNotFound)
	{
		num = lPacemark.subThoroughfare;
	}
    self.mStreetLabel.text = [NSString stringWithFormat:@"%@ %@", num, lPacemark.thoroughfare];
	
    //TODO : animate up
    [self animateBottomBarUp];
    self.mValidateBtn.enabled = YES;
	mReverseGeocodingDone = YES;
}


#pragma mark -
#pragma mark Geocoder     address -->  long,lat


- (void)launchFowardGeocoderWithAddress:(NSString *) address
{
    NSMutableDictionary* locationDictionary = [NSMutableDictionary dictionary];
    
    if ([address length] > 0)
    {
        [locationDictionary setValue:address forKey:(NSString *)kABPersonAddressStreetKey];
    }
    
    [locationDictionary setValue:NSLocalizedString(@"city", nil) forKey:(NSString *)kABPersonAddressCityKey];
    //[locationDictionary setValue:mTextFieldCP.text forKey:(NSString *)kABPersonAddressZIPKey];
    [locationDictionary setValue:NSLocalizedString(@"country", nil) forKey:(NSString *)kABPersonAddressCountryKey];
    
    [mReverseGeocoding launchFowardGeocoderWithDictionary:locationDictionary];
}


- (void)fowardGeocoder:(CLGeocoder*)_Geocoder didFailWithError:(NSError*)_Error
{
    [self displayGeolocationReverseFail];
    
	mForwardGeocodingDone = YES;
    //TODO : animate down
    [self animateBottomBarDown];
    self.mValidateBtn.enabled = NO;
}


- (void)fowardGeocoder:(CLGeocoder*)_Geocoder didFindPlacemark:(NSArray*)_Placemarks
{
	mForwardGeocodingDone = YES;
    
    C4MLog(@"_Placemarks %@", _Placemarks);
    CLPlacemark* lPacemark = nil;
    
    if ([_Placemarks count] > 0)
    {
        lPacemark = [_Placemarks objectAtIndex:0];
        
        //define zoom
        [[[self.mMapView annotations] objectAtIndex:0] setCoordinate:CLLocationCoordinate2DMake(lPacemark.location.coordinate.latitude, lPacemark.location.coordinate.longitude)];
		mCoordinate = CLLocationCoordinate2DMake(lPacemark.location.coordinate.latitude, lPacemark.location.coordinate.longitude);
        
        //Move to this point
        MKCoordinateRegion region = MKCoordinateRegionMake(lPacemark.location.coordinate, MKCoordinateSpanMake(.001, .001));
        [self.mMapView setRegion:region animated:YES];
        
        //fill address
        if (lPacemark.postalCode != nil && lPacemark.locality != nil)
        {
            self.mCityLabel.text = [NSString stringWithFormat:@"%@ %@", lPacemark.postalCode, lPacemark.locality];
        }
        
        NSString* num = @"";
        if ([lPacemark.subThoroughfare rangeOfString:@"-"].location == NSNotFound)
        {
            num = lPacemark.subThoroughfare;
        }
        self.mStreetLabel.text = [NSString stringWithFormat:@"%@ %@", num, lPacemark.thoroughfare];
        
        mReverseGeocodingDone = YES;
        //TODO : animate up
        [self animateBottomBarUp];
        self.mValidateBtn.enabled = YES;
    }
    else
    {
		[self displayGeolocationReverseFail];
		mForwardGeocodingDone = NO;
    }
    
}


- (void)displayGeolocationReverseFail
{
    NSString* message = @"";
    NSString* content = [NSString stringWithFormat:@"%@ : %@.", NSLocalizedString(@"cant_find", nil), message];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"information", nil) message:content delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
    [alert show];
    [alert release];
}


#pragma mark -
#pragma mark Dealoc

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [mMapView release];
    [mCancelBtn release];
    [mSearchField release];
    [mBottonBar release];
    [mCityLabel release];
    [mStreetLabel release];
    [mMyLocationBtn release];
    [mValidateBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMMapView:nil];
    [self setMCancelBtn:nil];
    [self setMSearchField:nil];
    [self setMBottonBar:nil];
    [self setMCityLabel:nil];
    [self setMStreetLabel:nil];
    [self setMMyLocationBtn:nil];
    [self setMValidateBtn:nil];
    [super viewDidUnload];
}




@end
