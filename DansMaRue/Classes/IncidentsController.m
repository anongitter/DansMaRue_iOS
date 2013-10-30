//
//  IncidentsController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "IncidentsController.h"
#import "GetIncidentsByPosition.h"
#import "FicheIncidentController.h"

@implementation IncidentsController


@synthesize mIncidentsOngoing;
@synthesize mIncidentsUpdated;
@synthesize mIncidentsResolved;


-(BOOL) shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //fix iOS7 to vaid layout go underneath the navBar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7(x)
	
	mIncidentsOngoing = [[NSMutableArray alloc] init];
	mIncidentsResolved = [[NSMutableArray alloc] init];
	mIncidentsUpdated = [[NSMutableArray alloc] init];
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"incidents_map_navbar_title", nil)];
	[self.navigationItem setTitleView:label];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	
	mLabelOngoing.text = NSLocalizedString(@"ongoing", nil);
	mLabelUpdated.text = NSLocalizedString(@"updated", nil);
	mLabelResolved.text = NSLocalizedString(@"resolve", nil);
	
	mLoadingView.frame = CGRectMake(0, 60, 320, 44);
	[self.view addSubview:mLoadingView];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
  
    if (mLoadingOngoing == NO)
    {
        GetIncidentsByPosition * lGetIncidentsByPosition = [[GetIncidentsByPosition alloc] initWithDelegate:self];
        
        NSMutableDictionary* lPosition =	[NSMutableDictionary dictionary];
        [lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].latitude] forKey:@"latitude"];
        [lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].longitude] forKey:@"longitude"];
        
        [lGetIncidentsByPosition generatIncident:lPosition farRadius:YES];
        [lGetIncidentsByPosition release];
        
        [mMKMapView setCenterCoordinate:[[InfoVoirieContext sharedInfoVoirieContext] mLocation]];
        MKCoordinateRegion region;
        region.center = [[InfoVoirieContext sharedInfoVoirieContext] mLocation];
        region.span = MKCoordinateSpanMake(.01, .01);
        [mMKMapView setRegion:region];
        //mMKMapView.region = MKCoordinateRegionMakeWithDistance(region.center, 1.0f, 1.0f);
        
        [self showLoadingView:YES];
    }    
}

- (void) showLoadingView:(BOOL)show
{
	mLoadingView.hidden = !show;
	mLoadingOngoing = show;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	mLabelOngoing = nil;
	mLabelNumOngoing = nil;
	mLabelUpdated = nil;
	mLabelNumUpdated = nil;
	mLabelResolved = nil;
	mLabelNumResolved = nil;
	
	mSegmentedControl = nil;
	mMKMapView = nil;
	
	mViewNotConnected = nil;
	
	[super viewDidUnload];
}

- (void)dealloc
{
	[mIncidentsOngoing release];
	[mIncidentsResolved release];
	[mIncidentsUpdated release];
	[mLabelOngoing release];
	[mLabelUpdated release];
	[mLabelResolved release];
	[mLabelNumOngoing release];
	[mLabelNumUpdated release];
	[mLabelNumResolved release];
	[mMKMapView release];
	
	[mViewNotConnected release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Toggle Incidents Status Methods
- (void)changeLabelsColor:(NSInteger)_index
{
	if(_index == kSwitchOngoingIndex)
	{
		[mLabelOngoing setTextColor:[UIColor whiteColor]];
		[mLabelNumOngoing setTextColor:[UIColor whiteColor]];
		[mLabelUpdated setTextColor:[UIColor grayColor]];
		[mLabelNumUpdated setTextColor:[UIColor grayColor]];
		[mLabelResolved setTextColor:[UIColor grayColor]];
		[mLabelNumResolved setTextColor:[UIColor grayColor]];
	}
	else if(_index == kSwitchDeclaredIndex)
	{
		[mLabelOngoing setTextColor:[UIColor grayColor]];
		[mLabelNumOngoing setTextColor:[UIColor grayColor]];
		[mLabelUpdated setTextColor:[UIColor whiteColor]];
		[mLabelNumUpdated setTextColor:[UIColor whiteColor]];
		[mLabelResolved setTextColor:[UIColor grayColor]];
		[mLabelNumResolved setTextColor:[UIColor grayColor]];
	}
	else
	{
		[mLabelOngoing setTextColor:[UIColor grayColor]];
		[mLabelNumOngoing setTextColor:[UIColor grayColor]];
		[mLabelUpdated setTextColor:[UIColor grayColor]];
		[mLabelNumUpdated setTextColor:[UIColor grayColor]];
		[mLabelResolved setTextColor:[UIColor whiteColor]];
		[mLabelNumResolved setTextColor:[UIColor whiteColor]];
	}
}

- (void)changeMapAnnotations:(NSInteger)_index
{
	NSMutableArray* annotationsToDelete = [NSMutableArray array];
    
	for(NSObject<MKAnnotation> *annotation in [mMKMapView annotations])
    {
		if([annotation isKindOfClass:[IncidentObj class]])
		{
            [annotationsToDelete addObject:annotation];
        }
    }    
	[mMKMapView removeAnnotations:annotationsToDelete];
    
    
	NSMutableArray* annotations;
	if(_index == kSwitchOngoingIndex)
		annotations = self.mIncidentsOngoing;
	else if (_index == kSwitchDeclaredIndex)
		annotations = self.mIncidentsUpdated;
	else
		annotations = self.mIncidentsResolved;
	
	// Add proper annotations to the MapView
	[mMKMapView addAnnotations:annotations];
}

- (IBAction)toggleControls:(id)sender
{
	[self changeLabelsColor:[sender selectedSegmentIndex]];
	[self changeMapAnnotations:[sender selectedSegmentIndex]];
}

#pragma mark -
#pragma mark Incident Delegate Methods
-(void)didReceiveIncidents:(NSArray*)_incidents
{
	if (_incidents == nil)
	{
		[self showLoadingView:NO];
		// TODO: Message erreur ?
		return;
	}
	
	NSString* lstatus;
	
	[self.mIncidentsOngoing removeAllObjects];
	[self.mIncidentsResolved removeAllObjects];
	[self.mIncidentsUpdated removeAllObjects];
	
	for(IncidentObj *lincident in _incidents)
	{
		lstatus = lincident.mstate;
		if([lstatus isEqualToString:@"R"])
		{
			[self.mIncidentsResolved addObject:lincident];
		}
		else if([lstatus isEqualToString:@"U"])
		{
			if (lincident.minvalid == NO)
			{
				[self.mIncidentsUpdated addObject:lincident];
			}
		}
		else if([lstatus isEqualToString:@"O"])
		{
			[self.mIncidentsOngoing addObject:lincident];
		}
		else
		{
			C4MLog(@"ERROR : invalid status (%@)", lstatus);
		}
	}
	
	//[mIncidentsOngoing addObjectsFromArray:mIncidentsUpdated];
	
	if ([self.mIncidentsResolved count] < 2) {
		[mLabelResolved setText:NSLocalizedString(@"resolve", nil)];
	}
	else {
		[mLabelResolved setText:NSLocalizedString(@"resolves", nil)];
	}
	
	mLabelOngoing.text = [mIncidentsOngoing count] < 2 ? NSLocalizedString(@"ongoing", nil) : NSLocalizedString(@"ongoing_plural", nil);
	
	mLabelNumOngoing.text = [NSString stringWithFormat:@"%d", [self.mIncidentsOngoing count]];
	mLabelNumUpdated.text = [NSString stringWithFormat:@"%d", [self.mIncidentsUpdated count]];
	mLabelNumResolved.text = [NSString stringWithFormat:@"%d", [self.mIncidentsResolved count]];
	
	[self showLoadingView:NO];
	[self changeMapAnnotations:[mSegmentedControl selectedSegmentIndex]];
}


#pragma mark -
#pragma mark Map View Delegate Methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString  * annotationViewId = @"AnnotationView";
	MKAnnotationView * annotationView = nil;
    
    // If it's the user position anotation, do NOT return a callout anotation
    if ([[InfoVoirieContext sharedInfoVoirieContext] mLocation].latitude == [annotation coordinate].latitude &&
        [[InfoVoirieContext sharedInfoVoirieContext] mLocation].longitude == [annotation coordinate].longitude)
    {
        return annotationView;
    }
	
	annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewId];
	
	if( [annotation isKindOfClass:[IncidentObj class]])
	{
		if (annotationView == nil) 
		{
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewId] autorelease];
		}
		
		annotationView.canShowCallout = YES;
		// Create the pick up button as the right accessory view
		UIButton* pickUpButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[pickUpButton setFrame:CGRectMake(0, 0, 30, 30) ];
		annotationView.rightCalloutAccessoryView = pickUpButton;
		
		[annotationView setImage:[UIImage imageNamed:@"map_cursor.png"]];
		if([mSegmentedControl selectedSegmentIndex] == kSwitchResolvedIndex)
		{
			annotationView.rightCalloutAccessoryView = nil;
		}
		
		[annotationView setCenterOffset:CGPointMake(0, -([annotationView frame].size.height)/2.0)];
	}
	
	return annotationView;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	IncidentObj *lincident = ((IncidentObj*)view.annotation);

	FicheIncidentController *nextController = [[FicheIncidentController alloc] initWithIncident:lincident];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}


@end
