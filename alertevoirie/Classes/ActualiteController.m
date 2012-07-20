//
//  ActualiteController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ActualiteController.h"

@implementation ActualiteController
@synthesize mActivities;
@synthesize mIncidentsById;
@synthesize mOrderedKeys;
@synthesize mBannedIncidentsId;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	mActivities = [[NSMutableDictionary alloc] init];
	mIncidentsById = [[NSMutableDictionary alloc] init];
	mOrderedKeys = [[NSMutableArray alloc] init];
	mBannedIncidentsId = [[NSMutableArray alloc] init];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	
	mLoadingView.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:mLoadingView];
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"actuality_navbar_title", nil)];
	[self.navigationItem setTitleView:label];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"viewWillAppear");
	
	[super viewWillAppear:animated];
	if (mLoadingOngoing == NO) {
		
		GetActivities * lGetActivities = [[GetActivities alloc] initWithDelegate:self];
		NSMutableDictionary* lPosition =	[NSMutableDictionary dictionary];
		[lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].latitude] forKey:@"latitude"];
		[lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].longitude] forKey:@"longitude"];
		
		[lGetActivities generateActivities:lPosition];
		[lGetActivities release];
		
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	mTableView = nil;
}

- (void)dealloc {
	[mActivities release];
	[mTableView release];
	[mLoadingView release];
	[mOrderedKeys release];
    [super dealloc];
}

#pragma mark -
#pragma mark Ordering Dictionary Methods
NSComparisonResult compareDateDescendingOrder(id _date1, id _date2, void *context)
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
	NSArray* keys = [mActivities allKeys];
	NSMutableArray* toOrder = [[NSMutableArray alloc] init];
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"locale", nil)];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	for(NSString* key in keys)
	{
		NSMutableArray* section = [mActivities objectForKey:key];
		LogObj *llog = [section objectAtIndex:0];
		NSString* date = [[llog.mDate componentsSeparatedByString:@"."] objectAtIndex:0];
		[toOrder addObject:[inputFormatter dateFromString:date]];
	}
	[toOrder sortUsingFunction:(compareDateDescendingOrder) context:nil];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE d MMMM"];
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
	NSArray* keys = [mActivities allKeys];
	for(NSString* key in keys)
	{
		[[mActivities objectForKey:key] sortUsingSelector:@selector(compareDateWithDateOf:)];
	}
}

#pragma mark -
#pragma mark GetActivities Delegate Methods

-(void)didReceiveActivities:(NSArray*)_incidents logs:(NSArray*)_incidentLogs
{
	if (_incidents == nil || _incidentLogs == nil)
	{
		[self showLoadingView:NO];
		// TODO: error message ?
		return;
	}
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"locale", nil)];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE d MMMM"];
	[dateFormatter setLocale:locale];
	
	[mIncidentsById removeAllObjects];
	[mActivities removeAllObjects];
	[mOrderedKeys removeAllObjects];
	
	for(IncidentObj *lincident in _incidents)
	{
		[mIncidentsById setObject:lincident forKey:[NSString stringWithFormat:@"%d", lincident.mid]];
	}
	
	NSMutableArray* invalidIncidentsID = [NSMutableArray array];
	for (LogObj *log in _incidentLogs)
	{
		if([[log mStatus] isEqualToString:@"Invalid"])
		{
			[invalidIncidentsID addObject:[NSNumber numberWithInteger:[log mId]]];
		}
	}
	
	for(LogObj *llog in _incidentLogs)
	{
		BOOL showLog = YES;
		
		for (NSNumber *Id in invalidIncidentsID)
		{
			if(llog.mId == [Id integerValue])
				showLog = NO;
		}
		if (showLog == YES)
		{
			if ([[llog mStatus] isEqualToString:@"Resolved"])
			{
				[mBannedIncidentsId addObject:[NSNumber numberWithInteger:llog.mId]];
			}
			//NSString* date = [[llog.mDate componentsSeparatedByString:@"."] objectAtIndex:0];
			NSDate *date2format = [inputFormatter dateFromString:llog.mDate];
			NSString* newDateString = [dateFormatter stringFromDate:date2format];
			NSMutableArray* llogAtDate = [mActivities valueForKey:newDateString];
			
			if(llogAtDate == nil)
			{
				llogAtDate = [NSMutableArray array];
			}
			[llogAtDate addObject:llog];
			[mActivities setObject:llogAtDate forKey:newDateString];
		}
	}
	//NSLog(@"ok");
	//NSLog(@"count = %d", [[mActivities allValues] count]);
	[self orderDictionaryAccordingToDate];
	[locale release];
	[inputFormatter release];
	[dateFormatter release];
	[mTableView reloadData];
	[self showLoadingView:NO];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (UITableViewCell *)tableView:(UITableView *)tableView
				 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString* key = [mOrderedKeys objectAtIndex:section];
	NSArray* activitySection = [mActivities objectForKey:key];
	
	static NSString* myActivityCell = @"MyActivityCellIdentifier";
	
	ActualiteCell *cell = (ActualiteCell *)[tableView dequeueReusableCellWithIdentifier:myActivityCell];
	if(cell == nil)
	{
		NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ActualiteCell" owner:self options:nil];
		
		for(id oneObject in nib)
		{
			if([oneObject isKindOfClass:[ActualiteCell class]])
			{
				cell = (ActualiteCell *)oneObject;
			}
		}
	}
	
	LogObj *log = [activitySection objectAtIndex:row];
	NSString* logId = [NSString stringWithFormat:@"%d", log.mId];
	IncidentObj *rowData = [mIncidentsById objectForKey:logId];
	
	cell.mAddress.text = [InfoVoirieContext capitalisedFirstLetter:[rowData maddress]];
	UIImage *imageStatus = nil;
	NSString* status = @"";
	
	cell.userInteractionEnabled = YES;
	
	if ([log.mStatus isEqualToString:kResolvedKey])
	{
		status = NSLocalizedString(@"incident_resolved", nil);
		imageStatus = [UIImage imageNamed:kIconResolved];
	}
	else if ([log.mStatus isEqualToString:kNewKey])
	{
		status = NSLocalizedString(@"incident_created", nil);
		imageStatus = [UIImage imageNamed:kIconCreated];
	}
	else if ([log.mStatus isEqualToString:kPhotoKey])
	{
		status = NSLocalizedString(@"photo_added", nil);
		imageStatus = [UIImage imageNamed:kIconAddedPhoto];
	}
	else if ([log.mStatus isEqualToString:kInvalidatedKey])
	{
		status = NSLocalizedString(@"incident_invalidated", nil);
		imageStatus = [UIImage imageNamed:kIconInvalidated];
	}
	else if ([log.mStatus isEqualToString:kConfirmedKey])
	{
		status = NSLocalizedString(@"incident_confirmed", nil);
		imageStatus = [UIImage imageNamed:kIconConfirmed];
	}
	
	NSString* ldescription = [NSString stringWithFormat:@"%@ %@", status, rowData.mdescriptive];
	cell.mDescription.text = [InfoVoirieContext capitalisedFirstLetter:ldescription];
	if(imageStatus != nil)
		[cell.mImageViewStatus setImage:imageStatus];
	
	CGRect CellWide = CGRectMake(0, 0, 320, kTableViewRowHeight);
	CGRect PictWide = CGRectMake(0, 0, 320, kTableViewRowHeight);
	
	UIView *bgView = [[UIView alloc] initWithFrame:CellWide];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:PictWide];
	UIView *bgViewSelected = [[UIView alloc] initWithFrame:CellWide];
	UIImageView *imageViewSelected = [[UIImageView alloc] initWithFrame:PictWide];
	
	if ([log.mStatus isEqualToString:kResolvedKey] || [log.mStatus isEqualToString:kInvalidatedKey])
	{
		[imageView setImage:[UIImage imageNamed:@"item_cell_ou_off.png"]];
		[imageViewSelected setImage:[UIImage imageNamed:@"item_cell_ou_on.png"]];
		
		cell.userInteractionEnabled = NO;
	}
	else
	{
		BOOL resolved = NO;
		NSNumber *logId = [NSNumber numberWithInteger:log.mId];
		for (NSNumber *Id in mBannedIncidentsId)
		{
			if ([Id intValue] == [logId intValue])
			{
				resolved = YES;
				break;
			}
		}
		if (resolved == YES)
		{
			[imageView setImage:[UIImage imageNamed:@"item_cell_ou_off.png"]];
			[imageViewSelected setImage:[UIImage imageNamed:@"item_cell_ou_on.png"]];
		}
		else
		{
			[imageView setImage:[UIImage imageNamed:@"item_cell_off.png"]];
			[imageViewSelected setImage:[UIImage imageNamed:@"item_cell_on.png"]];
		}
	}
	
	[bgView addSubview:imageView];
	[cell setBackgroundView:bgView];
	[imageView release];
	[bgView release];
	[bgViewSelected addSubview:imageViewSelected];
	[cell setSelectedBackgroundView:bgViewSelected];
	[imageViewSelected release];
	[bgViewSelected release];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger count = [mOrderedKeys count];
	return (count > 0) ? count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = [mOrderedKeys count];
	if(count == 0)
		return 0;
	NSString* key = [mOrderedKeys objectAtIndex:section];
	NSArray* nameSection = [mActivities objectForKey:key];
	
	return [nameSection count];
}

- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
	if([mOrderedKeys count] == 0)
		return nil;
	NSString* key = [mOrderedKeys objectAtIndex:section];
	if(key == UITableViewIndexSearch)
		return nil;
	return key;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString*)title
							 atIndex:(NSInteger) index
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

- (CGFloat)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
	return kTableViewRowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (mLoadingOngoing == YES)
	{
		return nil;
	}
	
	UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 28)] autorelease];
	UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_bar.png"]];
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
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	NSString* key = [mOrderedKeys objectAtIndex:section];
	NSArray* activitySection = [mActivities objectForKey:key];
	LogObj *llog = [activitySection objectAtIndex:row];
	if ([llog.mStatus isEqualToString:kResolvedKey] || [llog.mStatus isEqualToString:kInvalidatedKey])
	{
		return;
	}
	NSNumber *logId = [NSNumber numberWithInteger:llog.mId];
	for (NSNumber *Id in mBannedIncidentsId)
	{
		if ([Id intValue] == [logId intValue])
		{
			return;
		}
	}
	IncidentObj *lincident = [mIncidentsById objectForKey:[NSString stringWithFormat:@"%d", llog.mId]];
	FicheIncidentController *nextController = [[FicheIncidentController alloc] initWithIncident:lincident];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}

@end
