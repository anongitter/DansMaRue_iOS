//
//  LieuIncidentController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "LieuIncidentController.h"
#import "ValidationRapportController.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"

@interface LieuIncidentController (Private)

- (void)updateSatellitePlanButton;

@end


@implementation LieuIncidentController
@synthesize mIncidentCreated;
@synthesize mValRapController;
@synthesize mFicheController;

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
	self = [super initWithNibName:@"LieuIncidentController" bundle:nil];
	if (self) {
		self.mIncidentCreated = _incident;
		self.mValRapController = nil;
		self.mFicheController = nil;
		mCoordinate = [[InfoVoirieContext sharedInfoVoirieContext] mLocation];
		mMapFullView = NO;
	}
	return self;
}

- (id)initWithViewController:(ValidationRapportController *)_valController
{
	self = [super initWithNibName:@"LieuIncidentController" bundle:nil];
	if (self) {
		self.mIncidentCreated = _valController.mIncidentCreated;
		self.mValRapController = _valController;
		self.mFicheController = nil;
		mCoordinate = self.mIncidentCreated.coordinate;
		mMapFullView = NO;
	}
	return self;
}

- (id)initWithFicheViewController:(FicheIncidentController *) _ficheController
{
	self = [super initWithNibName:@"LieuIncidentController" bundle:nil];
	if (self) {
		self.mIncidentCreated = _ficheController.mIncident;
		self.mValRapController = nil;
		self.mFicheController = _ficheController;
		mCoordinate = self.mIncidentCreated.coordinate;
		mMapFullView = NO;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	mLabelSearch.text = NSLocalizedString(@"searching_street", nil);
	mLabelCity.text = @"";
	mLabelStreet.text = @"";
	mReverseGeocodingDone = NO;
	mForwardGeocodingDone = NO;
	mChosePinPosition = NO;
	mButtonValidatePosition.enabled = NO;
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"precise_incident_place", nil)];
	[self.navigationItem setTitleView:label];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(returnToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
	
	if (mValRapController != nil)
	{
		NSString* numAddressStreet = [[[[mValRapController mLabelAddressStreet] text] componentsSeparatedByString:@" "] objectAtIndex:0];
		mTextFieldNumber.text = [NSString stringWithFormat:@"%d", [numAddressStreet intValue]];
		[self textFieldShouldEndEditing:mTextFieldNumber];
	}
	if (mFicheController != nil)
	{
		NSString* numAddressStreet = [[[[mFicheController mLabelAddress] text] componentsSeparatedByString:@" "] objectAtIndex:0];
		mTextFieldNumber.text = [NSString stringWithFormat:@"%d", [numAddressStreet intValue]];
		[self textFieldShouldEndEditing:mTextFieldNumber];
	}
	
	[mMKMapView removeAnnotations:[mMKMapView annotations]];
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
			mTextFieldNumber.text = [mIncidentCreated mStreetNumber];
			mTextFieldStreet.text = [mIncidentCreated mStreet];
			mLabelCity.text = [NSString stringWithFormat:@"%@ %@", [mIncidentCreated mZipCode], [mIncidentCreated mCity]];
		}
		else
		{
		if ([mIncidentCreated maddress] != nil && [[mIncidentCreated maddress] length] != 0)
		{
			NSArray* addressArray = [[mIncidentCreated maddress] componentsSeparatedByString:@"\n"];
			NSLog(@"address = %@", addressArray);
			if (addressArray != nil && [addressArray count] > 0)
			{
				NSMutableString* street = [NSMutableString stringWithString:[addressArray objectAtIndex:0]];
				NSString* number = [[street componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:0];
				
				NSRange range;
				range.location = 0;
				range.length = [number length]+1;
				[street deleteCharactersInRange:range];
				
				mTextFieldNumber.text = number;
				mTextFieldStreet.text = street;
			}
			
			if (addressArray != nil && [addressArray count] > 1)
			{
				mLabelCity.text = [addressArray objectAtIndex:1];
				mLabelSearch.text = @"";
			}
		}
		}
	}
	
	[mMKMapView addAnnotation:annotation];
	
	[annotation release];
	
	NSNumber* mapType = [[NSUserDefaults standardUserDefaults] valueForKey:@"map_type"];
	if (mapType != nil)
	{
		[mMKMapView setMapType:[mapType intValue]];
		
		[self updateSatellitePlanButton];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	MKCoordinateRegion region;
	region.center = [[[mMKMapView annotations] lastObject] coordinate];
	
    //method 1
    region.span = MKCoordinateSpanMake(.001, .001);
	[mMKMapView setRegion:region];
    
    //method 2 - zoomed to 5kms radius
    //mMKMapView.region = MKCoordinateRegionMakeWithDistance(mCoordinate, 1.0f, 1.0f);
	
	mIsLeaving = NO;
	
	if (mFicheController == nil && mValRapController == nil)
	{
		if (mReverseGeocoding == nil)
		{
			mReverseGeocoding = [[ReverseGeocoding alloc] initWithDelegate:self];
		}
		[mLoader startAnimating];
		[mReverseGeocoding launchReverseGeocoding];
		mLabelSearch.text = NSLocalizedString(@"searching_street", nil);
		//mLabelCity.text = @"";
		mLabelStreet.text = @"";
		mReverseGeocodingDone = NO;
		mForwardGeocodingDone = NO;
		if ([mTextFieldNumber.text length] != 0)
		{
			if(mForwardGeocoder == nil)
			{
				mForwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
			}
			// Forward geocode!
			if (mLabelStreet.text != nil || mLabelCity.text != nil)
			{
				[mLoader startAnimating];
				[mForwardGeocoder findLocation:[NSString stringWithFormat:@"%@ %@ %@ %@",
												([mTextFieldNumber.text length] == 0)?@"":mTextFieldNumber.text,
												(mTextFieldStreet.text == nil)?@"":mTextFieldStreet.text,
												(mLabelCity.text == nil)?@"":mLabelCity.text,
												NSLocalizedString(@"country", nil)]];
			}
		}

		mButtonValidatePosition.enabled = NO;
	}
	else
	{
		/*if (mReverseGeocoding == nil)
		{
			mReverseGeocoding = [ReverseGeocoding alloc];
		}
		[mReverseGeocoding initWithDelegate:self andCoordinate:mIncidentCreated.coordinate];
		[mReverseGeocoding launchReverseGeocoding];*/
		mLabelSearch.text = @"";
	}

	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
}

#pragma mark -
#pragma mark Actions

- (IBAction) returnToPreviousView:(id)sender
{
	mIsLeaving = YES;
	if (mForwardGeocoder != nil) {
		[mForwardGeocoder setFwdGeocoderDelegate:nil];
	}
	if (mReverseGeocoding != nil) {
		[mReverseGeocoding mReverseGeocoder].delegate = nil;
	}
	[self.navigationController popViewControllerAnimated:YES];
	mMKMapView.delegate = nil;
}

- (IBAction) textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
	[self testValidateButtonEnable];
}

- (IBAction) backgroundTap:(id)sender
{
	[mTextFieldNumber resignFirstResponder];
	[mTextFieldStreet resignFirstResponder];
	[mTextFieldCity resignFirstResponder];
	[mTextFieldCP resignFirstResponder];
	[self testValidateButtonEnable];
}

// avoid an issue with animation sync of height/origin change
- (void)resizeMapControlAfterAnimation
{
	CGRect frame = mMapControl.frame;
	frame.size.height = 199;
	mMapControl.frame = frame;
}

- (IBAction) showMapButtonPressed:(id)sender
{
	if ([mTextFieldNumber isFirstResponder] || [mTextFieldCP isFirstResponder] || [mTextFieldCity isFirstResponder] || [mTextFieldStreet isFirstResponder])
	{
		return;
	}
	
	CGRect frame = mMapControl.frame;
	if (mMapFullView == YES)
	{
		frame.origin.y = 168;
		mMapFullView = NO;
	}
	else
	{
		frame.size.height = 367;
		frame.origin.y = 0;
		mMapFullView = YES;
	}
	[UIView beginAnimations:@"switchFullMapOnOff" context:nil];
	[UIView setAnimationDuration:.2];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	if (mMapFullView == NO)
	{
		[mMapControlButton setImage:[UIImage imageNamed:@"bouton_agrandir.png"] forState:UIControlStateNormal];
		[mMapControlButton setImage:[UIImage imageNamed:@"bouton_agrandir_on.png"] forState:UIControlStateHighlighted];
		[UIView setAnimationDidStopSelector:@selector(resizeMapControlAfterAnimation)];
	}
	else
	{
		[mMapControlButton setImage:[UIImage imageNamed:@"bouton_diminuer.png"] forState:UIControlStateNormal];
		[mMapControlButton setImage:[UIImage imageNamed:@"bouton_diminuer_on.png"] forState:UIControlStateHighlighted];
	}

	mMapControl.frame = frame;
	[UIView commitAnimations];
	
	MKCoordinateRegion region;
	region.center = [[[mMKMapView annotations] objectAtIndex:0] coordinate];
	region.span = [mMKMapView region].span;
	[mMKMapView setRegion:region];
}

- (void)updateSatellitePlanButton
{
	if ([mMKMapView mapType] == MKMapTypeSatellite)
	{
		[mSatellitePlanButton setImage:[UIImage imageNamed:@"bouton_carte_off.png"] forState:UIControlStateNormal];
		[mSatellitePlanButton setImage:[UIImage imageNamed:@"bouton_carte_on.png"] forState:UIControlStateHighlighted];
	}
	else
	{
		[mSatellitePlanButton setImage:[UIImage imageNamed:@"bouton_satellite_off.png"] forState:UIControlStateNormal];
		[mSatellitePlanButton setImage:[UIImage imageNamed:@"bouton_satellite_on.png"] forState:UIControlStateHighlighted];
	}
}

- (IBAction)changeMapMode
{
	if ([mMKMapView mapType] == MKMapTypeStandard)
	{
		[mMKMapView setMapType:MKMapTypeSatellite];
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:MKMapTypeSatellite] forKey:@"map_type"];
	}
	else
	{
		[mMKMapView setMapType:MKMapTypeStandard];
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:MKMapTypeStandard] forKey:@"map_type"];
	}
	
	[self updateSatellitePlanButton];
}

- (IBAction)validateButtonPressed:(id)sender
{
	NSString* city;
	if ([mTextFieldCity.text length] == 0)
	{
		city = mLabelCity.text;
	}
	else
	{
		city = mTextFieldCP.text;
		city = [city stringByAppendingFormat:@" %@", mTextFieldCity.text];
	}
	
	mIncidentCreated.mStreetNumber = mTextFieldNumber.text;
	mIncidentCreated.mStreet = mTextFieldStreet.text;
	if ([mLabelCity.text length] > 0)
	{
		NSArray* cityComponents = [city componentsSeparatedByString:@" "];
		mIncidentCreated.mZipCode = [cityComponents objectAtIndex:0];
		mIncidentCreated.mCity = [cityComponents objectAtIndex:1];
	}
	else
	{
		mIncidentCreated.mZipCode = mTextFieldCP.text;
		mIncidentCreated.mCity = mTextFieldCity.text;
	}
	
	//mIncidentCreated.maddress = [NSString stringWithFormat:@"%@ %@,%@", mTextFieldNumber.text, mTextFieldStreet.text, city];
	mIncidentCreated.coordinate = [[[mMKMapView annotations] objectAtIndex:0] coordinate];
	
	if(mValRapController == nil)
	{
		if (mFicheController == nil)
		{
			ValidationRapportController *nextController = [[ValidationRapportController alloc] initWithIncident:mIncidentCreated];
			[self.navigationController pushViewController:nextController animated:YES];
			[nextController release];
		}
		else
		{
			mFicheController.mLabelAddress.text = [[mFicheController mIncident] maddress];
			[mFicheController changeIncident];
			//[self.navigationController popToViewController:mFicheController animated:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	else
	{
		mValRapController.mLabelAddressStreet.text = [NSString stringWithFormat:@"%@ %@", mTextFieldNumber.text, mTextFieldStreet.text];
		mValRapController.mLabelAddressCity.text = city;
		//[self.navigationController popToViewController:mValRapController animated:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

//TODO: conditions with new text fields.
- (void)testValidateButtonEnable
{
	if ([mTextFieldNumber isFirstResponder] || [mTextFieldStreet isFirstResponder] || [mTextFieldCity isFirstResponder] || [mTextFieldCP isFirstResponder])
	{
		mButtonValidatePosition.enabled = NO;
		return;
	}
	
	if (/*(mReverseGeocodingDone == YES) && 
		([[mTextFieldNumber text] length] > 0) &&*/ ([[mTextFieldStreet text] length] > 0) &&
		(([[mTextFieldCity text] length] > 0 && [[mTextFieldCP text] length] > 0) || ([[mLabelCity text] length] > 0)) /*&&
		((mChosePinPosition == YES) || (mForwardGeocodingDone == YES))*/ )
	{
		mButtonValidatePosition.enabled = YES;
	}
	else
	{
		mButtonValidatePosition.enabled = NO;
	}
}

#pragma mark -
#pragma mark Memory Management Methods
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	mTextFieldNumber = nil;
	mTextFieldStreet = nil;
	mTextFieldCity = nil;
	mTextFieldCP = nil;
	mMKMapView = nil;
	mLabelCity = nil;
	mLabelStreet = nil;
	mButtonValidatePosition = nil;
	mMapControlButton = nil;
}


- (void)dealloc
{
	//NSLog(@"dealloc");
	[mMapControlButton release];
	[mTextFieldStreet release];
	[mTextFieldCity release];
	[mTextFieldCP release];
	[mMKMapView release];
	[mLabelCity release];
	[mLabelStreet release];
	[mButtonValidatePosition release];
	[mMapControlButton release];
	
	[mIncidentCreated release];
	[mForwardGeocoder release];
	[mReverseGeocoding release];
		
	[super dealloc];
}

#pragma mark -
#pragma mark Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != alertView.cancelButtonIndex)
	{
		ReverseGeocoding* lreverseGeocoding = [[ReverseGeocoding alloc] initWithDelegate:self];
		[lreverseGeocoding launchReverseGeocoding];
		[lreverseGeocoding release];
		mLabelSearch.text = NSLocalizedString(@"searching_street", nil);
		mLabelCity.text = @"";
		mLabelStreet.text = @"";
		mReverseGeocodingDone = NO;
		
		[self testValidateButtonEnable];
	}
}

#pragma mark -
#pragma mark Reverse Geocoder Delegate Methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"reverseGeocoder didFail");
	/*UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"impossible_geolocalization", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
	[lAlertTmp show];
	[lAlertTmp release];*/
	
	mTextFieldCity.hidden = NO;
	mTextFieldCP.hidden = NO;
	mLabelCity.text = @"";
	mLabelSearch.text = @"";
	
	[mLoader stopAnimating];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	NSLog(@"didFindPlacemark : %@", placemark.thoroughfare);
	mLabelSearch.text = @"";
	if (placemark.postalCode != nil && placemark.locality != nil)
	{
		mLabelCity.text = [NSString stringWithFormat:@"%@ %@", placemark.postalCode, placemark.locality];
	}
	else
	{
		mTextFieldNumber.text = @"";
		mTextFieldStreet.text = @"";
		[mTextFieldCP setHidden:NO];
		[mTextFieldCity setHidden:NO];
		mLabelCity.text = @"";
		mLabelSearch.text = @"";
	}

	
	if ([placemark.subThoroughfare rangeOfString:@"-"].location == NSNotFound)
	{
		mTextFieldNumber.text = placemark.subThoroughfare;
	}
	mLabelStreet.text = placemark.thoroughfare;
	mTextFieldStreet.text = mLabelStreet.text;
	
	if ([mLabelCity.text length] == 0)
	{
		mTextFieldCP.hidden = NO;
		mTextFieldCity.hidden = NO;
	}
	else
	{
		mTextFieldCP.hidden = YES;
		mTextFieldCity.hidden = YES;
	}

	
	mReverseGeocodingDone = YES;
	[self testValidateButtonEnable];
	[mLoader stopAnimating];
	//mButtonValidatePosition.enabled = YES;
}


#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{
	DDAnnotation *annotation = notification.object;
	if (mReverseGeocoding == nil) {
		mReverseGeocoding = [[ReverseGeocoding alloc] initWithDelegate:self];
	}
	mReverseGeocoding.mReverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:annotation.coordinate] autorelease];
	mReverseGeocoding.mReverseGeocoder.delegate = self;
	[mLoader startAnimating];
	[mReverseGeocoding launchReverseGeocoding];
	mChosePinPosition = YES;
	[self testValidateButtonEnable];
}


#pragma mark -
#pragma mark Map View Delegate Methods
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (oldState == MKAnnotationViewDragStateDragging)
	{
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		//annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
		if (mReverseGeocoding == nil)
		{
			mReverseGeocoding = [[ReverseGeocoding alloc] initWithDelegate:self];
		}
		[mLoader startAnimating];
	
		if (mReverseGeocoding.mReverseGeocoder != nil)
		{
			mReverseGeocoding.mReverseGeocoder.delegate = nil;
			[mReverseGeocoding.mReverseGeocoder cancel];
			//[mReverseGeocoding.mReverseGeocoder release];
			mReverseGeocoding.mReverseGeocoder = nil;
		}
		
		mReverseGeocoding.mReverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:annotation.coordinate] autorelease];
		mReverseGeocoding.mReverseGeocoder.delegate = self;
		[mReverseGeocoding launchReverseGeocoding];
		mChosePinPosition = YES;
		[self testValidateButtonEnable];
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
#pragma mark Text Field Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	mButtonValidatePosition.enabled = NO;
	mForwardGeocodingDone = NO;
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	if (mIsLeaving == YES)
	{
		return YES;
	}
	if(mForwardGeocoder == nil)
    {
        mForwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
    }
    // Forward geocode!
    if (/*[mTextFieldNumber.text length] != 0 && */[mTextFieldStreet.text length] != 0 && ([mTextFieldCity.text length] != 0 || [mLabelCity.text length] != 0) )
    {
		NSString* city = nil;
		if ([mTextFieldCity.text length] == 0)
		{
			city = mLabelCity.text;
		}
		else
		{
			city = mTextFieldCP.text;
			city = [city stringByAppendingFormat:@" %@", mTextFieldCity.text];
		}
		[mLoader startAnimating];
		[mForwardGeocoder findLocation:[NSString stringWithFormat:@"%@ %@ %@ %@",
											([mTextFieldNumber.text length] == 0)?@"":mTextFieldNumber.text,
											(mTextFieldStreet.text == nil)?@"":mTextFieldStreet.text,
											city,
											NSLocalizedString(@"country", nil)]];
    }
	return YES;
}

#pragma mark -
#pragma mark Forward Geocoder Delegate Methods
- (void)forwardGeocoderError:(NSString*)errorMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
	[alert show];
	[alert release];
	mForwardGeocodingDone = YES;
	[self testValidateButtonEnable];
	[mLoader stopAnimating];
}

- (void)forwardGeocoderFoundLocation
{
	mForwardGeocodingDone = YES;
	if(mForwardGeocoder.status == G_GEO_SUCCESS && [mForwardGeocoder.results count] == 1)
	{
        //define zoom
        BSKmlResult *place = [mForwardGeocoder.results objectAtIndex:0];
        [[[mMKMapView annotations] objectAtIndex:0] setCoordinate:place.coordinateRegion.center];
		mCoordinate = place.coordinateRegion.center;
		
        //method 1
        MKCoordinateRegion region = place.coordinateRegion;
		region.span = MKCoordinateSpanMake(.001, .001);
        [mMKMapView setRegion:region animated:YES];
        
        //method 2 - zoomed to 5kms radius
        //mMKMapView.region = MKCoordinateRegionMakeWithDistance(mCoordinate, 25.0f, 25.0f);
        //[mMKMapView setRegion:mMKMapView.region animated:YES];
        
//        int components = [place.addressComponents count];
//        for(int i = 0; i < components; i++)
//        {
//            BSAddressComponent *component = [place.addressComponents objectAtIndex:i];
//            if(component.types != nil)
//            {
//                NSLog(@"component %d= %@", i, component.longName);
//            }
//        }
//        
//        NSLog(@"place.address= %@", place.address);
//        mTextFieldCity.text = place.address;
        
	}
    else
    {
		NSString* message = @"";
        switch (mForwardGeocoder.status)
        {
            case G_GEO_SUCCESS:
                message = NSLocalizedString(@"too_much_results_found", nil);
                break;
            case G_GEO_BAD_KEY:
                message = NSLocalizedString(@"incorrect_api_key", nil);
                break;
            case G_GEO_UNKNOWN_ADDRESS:
                message = [NSString stringWithFormat:@"%@ : %@.", NSLocalizedString(@"cant_find", nil), mForwardGeocoder.searchQuery];
                break;
            case G_GEO_TOO_MANY_QUERIES:
                message = NSLocalizedString(@"too_much_requests_send_with_this_API", nil);
                break;
            case G_GEO_SERVER_ERROR:
                message = NSLocalizedString(@"server_error_please_retry", nil);
                break;
            default:
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"information", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
        [alert show];
        [alert release];
		mForwardGeocodingDone = NO;
    }
	[self testValidateButtonEnable];
	[mLoader stopAnimating];
}

@end
