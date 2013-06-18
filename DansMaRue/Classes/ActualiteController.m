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
@synthesize mLabelInfo;



-(BOOL) shouldAutorotate{
    return YES;
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}*/

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        [self updateView];
    }
    if(interfaceOrientation == UIDeviceOrientationLandscapeRight || interfaceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        [self updateLandScapeView];
    }
    return YES;
}*/


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        [self updateView];
    }
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft)
    {
        [self updateLandScapeView];
    }
}


- (void) updateView
{
    [self.mScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 900)];
    [self.mContentView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 900)];
}


- (void) updateLandScapeView
{
    [self.mScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 650)];
    [self.mContentView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 650)];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	/*
	mActivities = [[NSMutableDictionary alloc] init];
	mIncidentsById = [[NSMutableDictionary alloc] init];
	mOrderedKeys = [[NSMutableArray alloc] init];
	mBannedIncidentsId = [[NSMutableArray alloc] init];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	
	mLoadingView.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:mLoadingView];
	*/
    
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"actuality_navbar_title", nil)];
	[self.navigationItem setTitleView:label];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_mScrollView addSubview:_mContentView];
    _mScrollView.contentSize = _mContentView.frame.size;
    
    C4MLog(@"_mScrollView %@", [NSValue valueWithCGRect:_mScrollView.frame]);
    C4MLog(@"_mScrollView.contentSize %@", [NSValue valueWithCGSize:_mScrollView.contentSize]);
}


- (IBAction) mailShareApp
{
	MFMailComposeViewController *mailComposeController = [[MFMailComposeViewController alloc] init];
	
	if(mailComposeController != nil)
	{
		mailComposeController.mailComposeDelegate = self;
		mailComposeController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        [mailComposeController setBccRecipients:[NSArray arrayWithObject:NSLocalizedString(@"infopanel.mail.comments.mailto.address", nil)]];
        
		[mailComposeController setSubject:NSLocalizedString(@"infopanel.mail.comments.subject", @"")];
        
        [mailComposeController setMessageBody:NSLocalizedString(@"infopanel.mail.comments.body", @"") isHTML:YES];
		[self presentModalViewController:mailComposeController animated:YES];
		[mailComposeController release];
		
	}
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction) openMail:(id)sender
{
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[[NSURL alloc] initWithString:NSLocalizedString(@"infopanel.mail.comments.mailto.address", nil)]];
}


- (void) showLoadingView:(BOOL)show
{
	mLoadingView.hidden = !show;
	
	if ( show)
	{
		mLoadingOngoing = YES;
	}
	else
	{
		mLoadingOngoing = NO;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [self setMScrollView:nil];
    [self setMContentView:nil];
    [super viewDidUnload];
}


- (void)dealloc {
	[mActivities release];
	[mLoadingView release];
	[mOrderedKeys release];
    [_mScrollView release];
    [_mContentView release];
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
	[inputFormatter setDateFormat:kDateFormat];
	
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
	
    if ([_incidentLogs count] == 0)
	{
        [self showLoadingView:NO];
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
		
        NSString* string = [NSString stringWithFormat:@"no_report_around"];
		mLabelInfo.text = NSLocalizedString(string, nil);
		mLabelInfo.font = [UIFont systemFontOfSize:22.0];
		mLabelInfo.textAlignment = UITextAlignmentCenter;
		mLabelInfo.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
		mLabelInfo.backgroundColor = [UIColor clearColor];
	}
	else
	{
		if(mLabelInfo != nil)
			mLabelInfo.hidden = YES;
        
        
        NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"locale", nil)];
        
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:kDateFormat];
        
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
        [self orderDictionaryAccordingToDate];
        [locale release];
        [inputFormatter release];
        [dateFormatter release];
        [self showLoadingView:NO];        
	}
}


@end
