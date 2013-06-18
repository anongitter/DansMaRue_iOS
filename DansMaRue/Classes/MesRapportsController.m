//
//  MesRapportsController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "MesRapportsController.h"
#import "FicheIncidentController.h"
#import "MesRapportsCell.h"
#import "GetUserReports.h"
#import "incidentObj.h"

@implementation MesRapportsController

@synthesize mLabelInfo;
@synthesize mArrayCurrentTable;
@synthesize mReportsOngoing;
@synthesize mReportsUpdated;
@synthesize mReportsResolved;

-(BOOL) shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
	mDictionnaryReportsOngoing = [[NSMutableDictionary alloc] init];
	mArrayCurrentTable = [[NSMutableArray alloc] init];
	mOrderedKeys = [[NSMutableArray alloc] init];
	mReportsOngoing = [[NSMutableArray alloc] init];
	mReportsUpdated = [[NSMutableArray alloc] init];
	mReportsResolved = [[NSMutableArray alloc] init];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	mLoadingView.frame = CGRectMake(0, 60, 320, 44);
	[self.view addSubview:mLoadingView];
	
	UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:mMapButtonView];
	self.navigationItem.rightBarButtonItem = mapButton;
	[mapButton release];
	
	mLabelOngoing.text = NSLocalizedString(@"ongoing", nil);
	mLabelUpdated.text = NSLocalizedString(@"updated", nil);
	mLabelResolved.text = NSLocalizedString(@"resolve", nil);
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"my_reports_nav_bar_title", nil)];
	[self.navigationItem setTitleView:label];
	
	mMapShown = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
#ifdef kMarseilleTownhallVersion
	/*if ([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] == nil)
	{
		[mViewNotConnected setHidden:NO];
		[mLoadingView setHidden:YES];
		[mLabelInfo setHidden:YES];
		return;
	}
	else
	{*/
		[mViewNotConnected setHidden:YES];
	//}
	
#endif
	
	if (mLoadingOngoing == NO)
	{
		GetUserReports * mGetUserReports = [[GetUserReports alloc] initWithDelegate:self];
		[mGetUserReports generateReports];
		[mGetUserReports release];
		[self showLoadingView:YES];
	}
}

- (void) showLoadingView:(BOOL)show
{
	mLoadingView.hidden = !show;
	
	if ( show)
	{
		UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		mTableView.tableHeaderView = tmp;
		[tmp release];
		mLoadingOngoing = YES;
	}
	else
	{
		mTableView.tableHeaderView = nil;
		mLoadingOngoing = NO;
	}
}

- (IBAction)mapButtonPressed:(id)sender
{
	if (mMapShown == NO)
	{
		CGRect frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60);
		
		UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:mListButtonView];
		self.navigationItem.rightBarButtonItem = mapButton;
		[mapButton release];
		
		[UIView beginAnimations:@"show_map" context:nil];
		[UIView setAnimationDuration:.2];
		
		[self disableSegmentsLabel];
		[mMapView setFrame:frame];
		
		[UIView commitAnimations];
		
		mMapShown = YES;
	}
	else
	{
		CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - 60);
		
		UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:mMapButtonView];
		self.navigationItem.rightBarButtonItem = mapButton;
		[mapButton release];
		
		[UIView beginAnimations:@"hide_map" context:nil];
		[UIView setAnimationDuration:.2];
		[self disableSegmentsLabel];
		
		[mMapView setFrame:frame];
		[mSegmentedControl setEnabled:YES forSegmentAtIndex:kSwitchOngoingIndex];
		[mSegmentedControl setEnabled:YES forSegmentAtIndex:kSwitchUpdatedIndex];
		[mSegmentedControl setEnabled:YES forSegmentAtIndex:kSwitchResolvedIndex];
		[self changeLabelsColor:[mSegmentedControl selectedSegmentIndex]];
		
		[UIView commitAnimations];
		
		mMapShown = NO;
	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	mLabelOngoing = nil;
	mLabelNumOngoing = nil;
	mLabelUpdated = nil;
	mLabelNumUpdated = nil;
	mLabelResolved = nil;
	mLabelNumResolved = nil;
	mSegmentedControl = nil;
	mTableView = nil;
	self.mReportsOngoing = nil;
	self.mReportsUpdated = nil;
	self.mReportsResolved = nil;
	
	mViewNotConnected = nil;
	[super viewDidUnload];
}


- (void)dealloc
{
	[mLabelOngoing release];
	[mLabelUpdated release];
	[mLabelResolved release];
	[mLabelNumOngoing release];
	[mLabelNumUpdated release];
	[mLabelNumResolved release];
	[mSegmentedControl release];
	[mTableView release];
	[mReportsOngoing release];
	[mReportsUpdated release];
	[mReportsResolved release];
	[mMapButtonView release];
	[mListButtonView release];
	
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
	else if(_index == kSwitchUpdatedIndex)
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

- (void)changeTableContent:(NSInteger)_index
{
	if(_index == kSwitchOngoingIndex)
	{
		self.mArrayCurrentTable = self.mReportsOngoing;
	}
	else if(_index == kSwitchUpdatedIndex)
	{
		self.mArrayCurrentTable = self.mReportsUpdated;
	}
	else
	{
		NSNumber *nbResolved = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDictionaryKeyNumberResolved];
		if(nbResolved == nil)
		{
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:kUserDictionaryKeyNumberResolved];
			//nbResolved = [NSNumber numberWithInt:0];
		}
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.mReportsResolved count]] forKey:kUserDictionaryKeyNumberResolved];
		NSArray* items = [self.tabBarController.tabBar items];
		UITabBarItem *reports = [items objectAtIndex:3];
		reports.badgeValue = nil;
		
		self.mArrayCurrentTable = self.mReportsResolved;
	}
	
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"locale", nil)];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:kDateFormat];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM"];
	[dateFormatter setLocale:locale];
	
	[mDictionnaryReportsOngoing removeAllObjects];
	[mOrderedKeys removeAllObjects];
	
	for(IncidentObj *lincident in mArrayCurrentTable)
	{
		BOOL toRelease = NO;
		NSDate *date2format = [inputFormatter dateFromString:lincident.mdate];
		NSString* newDateString = [dateFormatter stringFromDate:date2format];
		NSString* date = [NSString stringWithFormat:@"%@", newDateString];
		NSMutableArray* lincidentAtDate = [mDictionnaryReportsOngoing valueForKey:date];
		
		if(lincidentAtDate == nil)
		{
			lincidentAtDate = [[NSMutableArray alloc] init];
			toRelease = YES;
		}
		[lincidentAtDate addObject:lincident];
		[mDictionnaryReportsOngoing setObject:lincidentAtDate forKey:date];
		if(toRelease == YES)
			[lincidentAtDate release];
	}
	
	[self orderDictionaryAccordingToDate];
	
	mLabelNumOngoing.text = [NSString stringWithFormat:@"%d", [self.mReportsOngoing count]];
	mLabelNumUpdated.text = [NSString stringWithFormat:@"%d", [self.mReportsUpdated count]];
	mLabelNumResolved.text = [NSString stringWithFormat:@"%d", [self.mReportsResolved count]];
	
	//[self toggleControls:mSegmentedControl];
	[self showLoadingView:NO];
	[locale release];
	[inputFormatter release];
	[dateFormatter release];
	
	[mTableView reloadData];
}

- (IBAction)toggleControls:(id)sender
{
	[self changeLabelsColor:[sender selectedSegmentIndex]];
	[self changeTableContent:[sender selectedSegmentIndex]];
	[self changeMapAnnotations:[sender selectedSegmentIndex]];
	// placed here to avoid a bug that occured when the cells are not loaded
	if ([self.mArrayCurrentTable count] > 0)
	{
//		[mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	
	if ([self.mArrayCurrentTable count] == 0)
	{
		mTableView.hidden = YES;
		if (mLabelInfo == nil)
		{
			mLabelInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 207)];
			mLabelInfo.hidden = NO;
			[self.view addSubview:mLabelInfo];
		}
		else
		{
			mLabelInfo.hidden = NO;
		}
		
		NSString* info;
		switch ([sender selectedSegmentIndex])
		{
			case kSwitchOngoingIndex:
				info = @"ongoing";
				break;
			case kSwitchUpdatedIndex:
				info = @"updated";
				break;
			case kSwitchResolvedIndex:
				info = @"resolved";
				break;
			default:
				info = @"ongoing";
				break;
		}
		NSString* string = [NSString stringWithFormat:@"no_report_%@", info];
		mLabelInfo.text = NSLocalizedString(string, nil);
		mLabelInfo.font = [UIFont systemFontOfSize:22.0];
		mLabelInfo.textAlignment = UITextAlignmentCenter;
		mLabelInfo.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
		mLabelInfo.backgroundColor = [UIColor clearColor];
	}
	else
	{
		mTableView.hidden = NO;
		if(mLabelInfo != nil)
			mLabelInfo.hidden = YES;
	}
}

- (void)disableSegmentsLabel
{
	if ([mReportsOngoing count] == 0)
	{
		[mSegmentedControl setEnabled:NO forSegmentAtIndex:kSwitchOngoingIndex];
		[mLabelNumOngoing setTextColor:[UIColor lightGrayColor]];
		[mLabelOngoing setTextColor:[UIColor lightGrayColor]];
	}
	else
	{
		[mSegmentedControl setEnabled:YES forSegmentAtIndex:kSwitchOngoingIndex];
	}
	
	if ([mReportsUpdated count] == 0)
	{
		[mSegmentedControl setEnabled:NO forSegmentAtIndex:kSwitchUpdatedIndex];
		[mLabelNumUpdated setTextColor:[UIColor lightGrayColor]];
		[mLabelUpdated setTextColor:[UIColor lightGrayColor]];
	}
	else
	{
		[mSegmentedControl setEnabled:YES forSegmentAtIndex:kSwitchUpdatedIndex];
	}
	
	if ([mReportsResolved count] == 0)
	{
		[mSegmentedControl setEnabled:NO forSegmentAtIndex:kSwitchResolvedIndex];
		[mLabelNumResolved setTextColor:[UIColor lightGrayColor]];
		[mLabelResolved setTextColor:[UIColor lightGrayColor]];
	}
	else
	{
		[mSegmentedControl setEnabled:YES forSegmentAtIndex:kSwitchResolvedIndex];
	}
}

- (void)changeMapAnnotations:(NSInteger)_index
{
	NSArray* lannotations;
	if(_index == kSwitchOngoingIndex)
		lannotations = self.mReportsOngoing;
	else if (_index == kSwitchUpdatedIndex)
		lannotations = self.mReportsUpdated;
	else
		lannotations = self.mReportsResolved;
	
	NSMutableArray* annotationsToDelete = [NSMutableArray array];
	for(NSObject<MKAnnotation> *annotation in [mMapView annotations])
	{
		if([annotation isKindOfClass:[IncidentObj class]])
		{
			[annotationsToDelete addObject:annotation];
		}
	}
	
	[mMapView removeAnnotations:annotationsToDelete];
	// Add proper annotations to the MapView
	[mMapView addAnnotations:lannotations];
	
	MKCoordinateRegion region;
	CLLocationCoordinate2D maxCoordinate;
	CLLocationCoordinate2D minCoordinate;
	CLLocationCoordinate2D newCoordinate;
	
	maxCoordinate.latitude = -1000;
	maxCoordinate.longitude = -1000;
	minCoordinate.latitude = 1000;
	minCoordinate.longitude = 1000;
	
	for (IncidentObj *incObj in mArrayCurrentTable)
	{
		if ([incObj coordinate].latitude > maxCoordinate.latitude)
		{
			maxCoordinate.latitude = [incObj coordinate].latitude;
		}
		if ([incObj coordinate].longitude > maxCoordinate.longitude)
		{
			maxCoordinate.longitude = [incObj coordinate].longitude;
		}
		if ([incObj coordinate].latitude < minCoordinate.latitude)
		{
			minCoordinate.latitude = [incObj coordinate].latitude;
		}
		if ([incObj coordinate].longitude < minCoordinate.longitude)
		{
			minCoordinate.longitude = [incObj coordinate].longitude;
		}
	}
	
	CLLocationCoordinate2D userLocation = [[InfoVoirieContext sharedInfoVoirieContext] mLocation];
	
	if (userLocation.latitude < minCoordinate.latitude)
	{
		minCoordinate.latitude = userLocation.latitude;
	}
	if (userLocation.longitude < minCoordinate.longitude)
	{
		minCoordinate.longitude = userLocation.longitude;
	}
	if (userLocation.latitude > maxCoordinate.latitude)
	{
		maxCoordinate.latitude = userLocation.latitude;
	}
	if (userLocation.longitude > maxCoordinate.longitude)
	{
		maxCoordinate.longitude = userLocation.longitude;
	}
	
	newCoordinate.latitude = minCoordinate.latitude + (maxCoordinate.latitude - minCoordinate.latitude)/2.;
	newCoordinate.longitude = minCoordinate.longitude + (maxCoordinate.longitude - minCoordinate.longitude)/2.;
	region.center = newCoordinate; //[[InfoVoirieContext sharedInfoVoirieContext] mLocation]; //newCoordinate;
	if([mArrayCurrentTable count] > 0)
	{
		region.span = MKCoordinateSpanMake((maxCoordinate.latitude - minCoordinate.latitude)*1.1, (maxCoordinate.longitude - minCoordinate.longitude)*1.1);
	}
	else
	{
		region.span = MKCoordinateSpanMake(0.001, 0.001);
	}

	//
	[mMapView setRegion:region];
}


#pragma mark -
#pragma mark Ordering Dictionary Methods
NSComparisonResult compareDateDescendingOrderReports(id _date1, id _date2, void *context)
{
	NSComparisonResult result = [(NSDate *)_date1 compare:((NSDate *)_date2)];
	if(result == NSOrderedAscending)
		return NSOrderedDescending;
	if(result == NSOrderedDescending)
		return NSOrderedAscending;
	return result;
}

- (void)orderDictionaryKeysAccordingToDate
{
	NSArray* keys = [mDictionnaryReportsOngoing allKeys];
	NSMutableArray* toOrder = [[NSMutableArray alloc] init];
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"locale", nil)];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:kDateFormat];
	
	for(NSString* key in keys)
	{
		NSMutableArray* section = [mDictionnaryReportsOngoing objectForKey:key];
		IncidentObj *lincident = [section objectAtIndex:0];
        C4MLog(@"Date : %@", lincident.mdate);
        if ([inputFormatter dateFromString:lincident.mdate] != nil)
        {
            [toOrder addObject:[inputFormatter dateFromString:lincident.mdate]];
        }
		
	}
    
	[toOrder sortUsingFunction:(compareDateDescendingOrderReports) context:nil];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM"];
	[dateFormatter setLocale:locale];
	
	for(NSDate *date in toOrder)
	{
		NSString* newDateString = [dateFormatter stringFromDate:date];
		[mOrderedKeys addObject:newDateString];
	}
	
	[locale release];
	[inputFormatter release];
	[dateFormatter release];
	[toOrder release];
}

- (void)orderDictionaryAccordingToDate
{
	[self orderDictionaryKeysAccordingToDate];
	NSArray* keys = [mDictionnaryReportsOngoing allKeys];
	for(NSString* key in keys)
	{
		[[mDictionnaryReportsOngoing objectForKey:key] sortUsingSelector:@selector(compareDateWithDateOf:)];
	}
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* key;
	NSArray* reportSection = nil;
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		NSUInteger section = [indexPath section];
		key = [mOrderedKeys objectAtIndex:section];
		reportSection = [mDictionnaryReportsOngoing objectForKey:key];
	}
	NSUInteger row = [indexPath row];
	
	static NSString* myReportsCell = @"MyReportsCellIdentifier";
	//static NSString* myReportsUpdateCell = @"MyReportsUpdateCellIdentifier";
	
	MesRapportsCell *cell;
	//if ([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex || [mSegmentedControl selectedSegmentIndex] == kSwitchResolvedIndex)
	{
		cell = (MesRapportsCell *)[tableView dequeueReusableCellWithIdentifier:myReportsCell];
		if(cell == nil)
		{
			NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"MesRapportsCell" owner:self options:nil];
			
			for(id oneObject in nib)
				if([oneObject isKindOfClass:[MesRapportsCell class]])
					cell = (MesRapportsCell *)oneObject;
		}
	}
	/*else
	{
		cell = (MesRapportsCell *)[tableView dequeueReusableCellWithIdentifier:myReportsUpdateCell];
		if(cell == nil)
		{
			NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"MesRapportsUpdateCell" owner:self options:nil];
			
			for(id oneObject in nib)
				if([oneObject isKindOfClass:[MesRapportsCell class]])
					cell = (MesRapportsCell *)oneObject;
		}
	}*/
	
	IncidentObj *rowData;
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		rowData = [reportSection objectAtIndex:row];
	}
	/*else
	{
		rowData = [self.mArrayCurrentTable objectAtIndex:row];
	}*/
	cell.mIncidentDescriptive.text = [InfoVoirieContext capitalisedFirstLetter:[rowData mdescriptive]];
	cell.mIncidentAddress.text = [InfoVoirieContext capitalisedFirstLetter:[rowData maddress]];
	cell.mIncidentDate.text = [InfoVoirieContext capitalisedFirstLetter:[rowData formattedDate]];
	
	/*if ([rowData minvalid] == YES)
	{
		[cell.mIncidentIcon setImage:[UIImage imageNamed:@"icn_incident_nonvalide.png"]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else
	{
		[cell.mIncidentIcon setImage:nil];
	}*/

	
	CGRect CellWide = CGRectMake(0, 0, 320, kTableViewRowHeight);
	CGRect PictWide = CGRectMake(0, 0, 320, kTableViewRowHeight);
	
	UIView *bgView = [[UIView alloc] initWithFrame:CellWide];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:PictWide];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UIView *bgViewSelected = [[UIView alloc] initWithFrame:CellWide];
	UIImageView *imageViewSelected = [[UIImageView alloc] initWithFrame:PictWide];
    imageViewSelected.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	[imageView setImage:[UIImage imageNamed:@"item_cell_ou_off.png"]];
	[imageViewSelected setImage:[UIImage imageNamed:@"item_cell_ou_on.png"]];
	
	[bgView addSubview:imageView];
	[cell setBackgroundView:bgView];
	[imageView release];
	[bgView release];
	[bgViewSelected addSubview:imageViewSelected];
	[cell setSelectedBackgroundView:bgViewSelected];
	[imageViewSelected release];
	[bgViewSelected release];
	
	if ([mSegmentedControl selectedSegmentIndex] == kSwitchResolvedIndex || rowData.minvalid == YES)
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		NSInteger count = [mOrderedKeys count];
        C4MLog(@"numberOfSectionsInTableView = %d", count);
		return (count > 0) ? count : 1;
	}
	//return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		NSInteger count = [mOrderedKeys count];
		if(count == 0)
			return 0;
		NSString* key = [mOrderedKeys objectAtIndex:section];
		NSArray* nameSection = [mDictionnaryReportsOngoing objectForKey:key];
		
        C4MLog(@"numberOfRowsInSection = %d", [nameSection count]);
		return [nameSection count];
	}
	//return [self.mArrayCurrentTable count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		if([mOrderedKeys count] == 0)
			return nil;
		NSString* key = [mOrderedKeys objectAtIndex:section];
		if(key == UITableViewIndexSearch)
			return nil;
		
		return [InfoVoirieContext capitalisedFirstLetter:key];
	}
	//return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger) index
{
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		NSString* key = [mOrderedKeys objectAtIndex:index];
		if(key == UITableViewIndexSearch)
		{
			[tableView setContentOffset:CGPointZero animated:NO];
			return NSNotFound;
		}
		else
		{
			return index;
		}
	}
	/*else
	{
		return 0;
	}*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
	return kTableViewRowHeight; 
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	/*if([mSegmentedControl selectedSegmentIndex] != kSwitchOngoingIndex)
	{
		return nil;
	}*/
	if ([mArrayCurrentTable count] <= 0)
	{
		return nil;
	}
	if (mLoadingOngoing == YES)
	{
		return nil;
	}
	
	UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 28)] autorelease];
	UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_bar.png"]];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 300, 20)];
	title.text = [self tableView:tableView titleForHeaderInSection:section];
	title.text = [InfoVoirieContext capitalisedFirstLetter:(title.text)];
	title.textColor = [UIColor whiteColor];
	title.font = [UIFont boldSystemFontOfSize:20.0];
	title.backgroundColor = [UIColor clearColor];
	[view addSubview:bg];
	[view addSubview:title];
	[bg release];
	[title release];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kTableViewHeaderHeight;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([mSegmentedControl selectedSegmentIndex] == kSwitchResolvedIndex)
	{
		return;
	}
	
	IncidentObj *lincident;
	//if([mSegmentedControl selectedSegmentIndex] == kSwitchOngoingIndex)
	{
		NSUInteger section = [indexPath section];
		NSUInteger row = [indexPath row];
		
		NSString* key = [mOrderedKeys objectAtIndex:section];
		NSArray* reportSection = [mDictionnaryReportsOngoing objectForKey:key];
		lincident = [reportSection objectAtIndex:row];
	}
	/*else
	{
		NSUInteger row = [indexPath row];
		lincident = [mArrayCurrentTable objectAtIndex:row];
	}*/
	if (lincident.minvalid == YES)
	{
		return;
	}
	
	FicheIncidentController *nextController = [[FicheIncidentController alloc] initWithIncident:lincident];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}

#pragma mark -
#pragma mark Report Delegate Methods
- (void)didReceiveReportsOngoing:(NSArray*)_ongoing updated:(NSArray*)_updated resolved:(NSArray*)_resolved
{
    C4MLog(@"didReceiveReportsOngoing");
          
	if (_ongoing == nil || _updated == nil || _resolved == nil)
	{
		[self showLoadingView:NO];
		// TODO: Message d'erreur ?
		return;
	}
	
	self.mReportsOngoing = (NSMutableArray*)_ongoing;
	self.mReportsUpdated = (NSMutableArray*)_updated;
	self.mReportsResolved = (NSMutableArray*)_resolved;
	
	//[mReportsOngoing addObjectsFromArray:mReportsUpdated];
	
	if ([self.mReportsResolved count] < 2)
	{
		[mLabelResolved setText:NSLocalizedString(@"resolve", nil)];
	}
	else
	{
		[mLabelResolved setText:NSLocalizedString(@"resolves", nil)];
	}
	
	mLabelOngoing.text = [mReportsOngoing count] < 2 ? NSLocalizedString(@"ongoing", nil) : NSLocalizedString(@"ongoing_plural", nil);
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"locale", nil)];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:kDateFormat];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM"];
	[dateFormatter setLocale:locale];
	
	[mDictionnaryReportsOngoing removeAllObjects];
	[mOrderedKeys removeAllObjects];
	
	for(IncidentObj *lincident in mReportsOngoing)
	{
		BOOL toRelease = NO;
		NSDate *date2format = [inputFormatter dateFromString:lincident.mdate];
		NSString* newDateString = [dateFormatter stringFromDate:date2format];
		NSString* date = [NSString stringWithFormat:@"%@", newDateString];
		NSMutableArray* lincidentAtDate = [mDictionnaryReportsOngoing valueForKey:date];
		
		if(lincidentAtDate == nil)
		{
			lincidentAtDate = [[NSMutableArray alloc] init];
			toRelease = YES;
		}
		[lincidentAtDate addObject:lincident];
		[mDictionnaryReportsOngoing setObject:lincidentAtDate forKey:date];
		if(toRelease == YES)
			[lincidentAtDate release];
	}
	
	[self orderDictionaryAccordingToDate];
	
	mLabelNumOngoing.text = [NSString stringWithFormat:@"%d", [self.mReportsOngoing count]];
	mLabelNumUpdated.text = [NSString stringWithFormat:@"%d", [self.mReportsUpdated count]];
	mLabelNumResolved.text = [NSString stringWithFormat:@"%d", [self.mReportsResolved count]];
	
	[self toggleControls:mSegmentedControl];
	[self showLoadingView:NO];
	[locale release];
	[inputFormatter release];
	[dateFormatter release];
}

#pragma mark -
#pragma mark Map View Delegate Methods
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString  * annotationViewId = @"AnnotationViewRapports";
	MKAnnotationView * annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:annotationViewId];
	
	
	if( [annotation isKindOfClass:[IncidentObj class]] )
	{
		if (annotationView == nil) 
		{
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:annotationViewId] autorelease];
			annotationView.canShowCallout = YES;
		}
		
		// Create the pick up button as the right accessory view
		UIButton * pickUpButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[pickUpButton setFrame:CGRectMake(0, 0, 30, 30) ];
		annotationView.rightCalloutAccessoryView = pickUpButton;		
	
		[annotationView setImage:[UIImage imageNamed:@"map_cursor.png"]];
		if([mSegmentedControl selectedSegmentIndex] == kSwitchResolvedIndex || ((IncidentObj*)annotation).minvalid == YES)
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
