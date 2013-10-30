//
//  NouveauController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "NouveauController.h"
#import "GetUserReports.h"
#import "GetCategories.h"
#import "C4MNavigationBar.h"

@interface NouveauController (Private)

- (void)updateLoginButton;

@end


@implementation NouveauController

- (BOOL) shouldAutorotate{
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
    
    [self.navigationController.navigationBar setNeedsDisplay];
    
    UIImageView* titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTitleImageName]];
    titleImage.contentMode = UIViewContentModeScaleAspectFit;
    titleImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.navigationItem.titleView = titleImage;
	
	mLoadingOngoing = 0;
	
	UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:mButtonInfo];
	[self.navigationItem setLeftBarButtonItem:infoButton];
	[infoButton release];
	
	mLabelTextOngoingIncidents.text = NSLocalizedString(@"ongoing", nil);
	mLabelTextUpdatedIncidents.text = NSLocalizedString(@"updated", nil);
	mLabelTextResolvedIncidents.text = NSLocalizedString(@"resolve", nil);
	
	mLabelTextIncidents.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"incidents_around", nil)];
	
	[mButtonDeconnexion setTitle:NSLocalizedString(@"deconnexion", nil) forState:UIControlStateNormal];
	
	[self updateLoginButton];
    
    [self getCategories];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (mLoadingOngoing <= 0 && mHasBeenGeolocated == YES)
	{
		if ([[InfoVoirieContext sharedInfoVoirieContext] mLocationFound] == YES)
		{
			GetIncidentStats * lGetIncidentStats = [[GetIncidentStats alloc] initWithStatsDelegate:self andReportDelegate:self];
			
			NSMutableDictionary* lPosition =	[NSMutableDictionary dictionary];
			[lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].latitude] forKey:@"latitude"];
			[lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].longitude] forKey:@"longitude"];
			
			[lGetIncidentStats generateIncidentStats:lPosition];
			
			[lGetIncidentStats release];
			mLoadingOngoing++;
		}
	}
	else
	{
        C4MLog(@"Loading 1, mLoadingOngoing=%d",mLoadingOngoing);
		[mIndicatorView startAnimating];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (mLoadingOngoing > 0)
	{
        C4MLog(@"Loading 2, mLoadingOngoing=%d",mLoadingOngoing);
		[mIndicatorView startAnimating];
	}
}

- (void)reloadIncidentStats
{
	GetIncidentStats * getIncidentStats = [[GetIncidentStats alloc] initWithStatsDelegate:self andReportDelegate:self];
	
	NSMutableDictionary* lPosition =	[NSMutableDictionary dictionary];
	[lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].latitude] forKey:@"latitude"];
	[lPosition setObject:[NSNumber numberWithDouble:[[InfoVoirieContext sharedInfoVoirieContext] mLocation].longitude] forKey:@"longitude"];
	
	[getIncidentStats generateIncidentStats:lPosition];
	
	[getIncidentStats release];
	
    C4MLog(@"Loading 3, mLoadingOngoing=%d",mLoadingOngoing);
	[mIndicatorView startAnimating];
	
	mHasBeenGeolocated = YES;
}

- (void)getCategories
{
	GetCategories *getCategories = [[GetCategories alloc] initWithDelegate:self];
	[getCategories downloadCategories];
}

- (void)authenticate
{
	UserAuthentication* userAuthentication = [[UserAuthentication alloc] initWithDelegate:self];
	
	[userAuthentication generateUserAuthentication];
	
	[userAuthentication release];
	
    C4MLog(@"Loading 4");
	[mIndicatorView startAnimating];
}

- (void)updateLoginButton
{
	[mButtonLogin setHidden:YES];
	/*[mButtonLogin setHidden:([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] != nil)];
	
	if ([mViewLogin isHidden] == YES)
	{
		[mButtonLogin setBackgroundImage:[UIImage imageNamed:@"btn_mid_off.png"] forState:UIControlStateNormal];
		[mButtonLogin setTitleColor:[[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor] forState:UIControlStateNormal];
		[mButtonLogin setBackgroundImage:[UIImage imageNamed:@"btn_mid_on.png"] forState:UIControlStateHighlighted];
		[mButtonLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	}
	else
	{
		[mButtonLogin setBackgroundImage:[UIImage imageNamed:@"btn_mid_on.png"] forState:UIControlStateNormal];
		[mButtonLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[mButtonLogin setBackgroundImage:[UIImage imageNamed:@"btn_mid_off.png"] forState:UIControlStateHighlighted];
		[mButtonLogin setTitleColor:[[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor] forState:UIControlStateHighlighted];
	}*/
}

#pragma mark -
#pragma mark Actions
- (IBAction)launchLoginButtonPressed
{
	[mViewLogin setHidden:![mViewLogin isHidden]];
	
	[self updateLoginButton];
}

- (IBAction)infoButtonPressed
{
	C4MInfo *info = [[C4MInfo alloc] init];
	info.hidesBottomBarWhenPushed = YES;
	[self.navigationController presentModalViewController:info animated:YES];
	[info release];
}

- (IBAction)createReportButtonPressed
{
	ConfirmDeclarationController *lConfirmDeclarationController = [[ConfirmDeclarationController alloc] initWithNibName:@"ConfirmDeclarationController" bundle:nil];
	[self.navigationController pushViewController:lConfirmDeclarationController animated:NO]; //NO otherwise nested push animation can result in corrupted navigation bar
	[lConfirmDeclarationController release];
}

- (IBAction)loginButtonPressed
{
	if (mTextFieldLogin.text != nil && [mTextFieldLogin.text length] > 0 &&
	    mTextFieldPassword.text != nil && [mTextFieldPassword.text length] > 0)
	{
		[[InfoVoirieContext sharedInfoVoirieContext] computeAuthenticationTokenWithLogin:mTextFieldLogin.text andPassword:mTextFieldPassword.text];
		
		// Connection attempt
		[self authenticate];
	}
	else
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", nil) message:NSLocalizedString(@"please_provide_login_password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (IBAction)textFieldEndEditing:(id)sender
{
	[sender resignFirstResponder];
}

- (IBAction)deconnexionButtonPressed
{
	[[InfoVoirieContext sharedInfoVoirieContext] deconnectUser];
	
	CGRect frame;
	
	frame = mViewWelcomeUser.frame;
	frame.origin.y = -frame.size.height;
	mViewWelcomeUser.frame = frame;
	
	frame = mButtonNewIncident.frame;
	frame.origin.y -= mViewWelcomeUser.frame.size.height;
	mButtonNewIncident.frame = frame;
	
	mTextFieldLogin.text = nil;
	mTextFieldPassword.text = nil;
	
	[mViewLogin setHidden:NO];
	
	[self updateLoginButton];
}

#pragma mark -
#pragma mark Memory Management Methods
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
    
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	mViewWelcomeUser = nil;
	mLabelWelcomeUser = nil;
	mButtonDeconnexion = nil;
	
	mButtonNewIncident = nil;
	mButtonInfo = nil;
	
	mLabelTextIncidents = nil;
	mLabelOngoingIncidents	= nil;
	mLabelResolvedIncidents = nil;
	mLabelUpdatedIncidents = nil;
	mLabelTextOngoingIncidents = nil;
	mLabelTextUpdatedIncidents = nil;
	mLabelTextResolvedIncidents = nil;
	
	mViewLogin = nil;
	mTextFieldLogin = nil;
	mTextFieldPassword = nil;
	
	mIndicatorView = nil;
}

- (void)dealloc
{
	[mViewWelcomeUser release];
	[mLabelWelcomeUser release];
	[mButtonDeconnexion release];
	[mButtonNewIncident release];
	[mButtonInfo release];
	[mLabelTextIncidents release];
	[mLabelOngoingIncidents release];
	[mLabelResolvedIncidents release];
	[mLabelUpdatedIncidents release];
	[mLabelTextOngoingIncidents release];
	[mLabelTextUpdatedIncidents release];
	[mLabelTextResolvedIncidents release];
	
	[mViewLogin release];
	[mTextFieldLogin release];
	[mTextFieldPassword release];
	
	[mIndicatorView release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark TextField Delegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	NSData* stringData = [finalString dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES];
	NSString* noaccentString = [[[NSString alloc] initWithData: stringData encoding: NSASCIIStringEncoding] autorelease];
	
	if ([finalString isEqualToString:noaccentString])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

#pragma mark -
#pragma mark GetCategories Delegate Methods

-(void)didReceiveCategories{
    
    C4MLog(@"didReceiveCategories");
    
    
    
}


#pragma mark -
#pragma mark GetIncidentStats Delegate Methods

- (void)didReceiveIncidentStats:(NSString*)_nbOngoingIncidents :(NSString*)_nbUpdatedIncidents :(NSString*)_nbResolvedIncidents
{
	C4MLog(@"didReceiveIncidentStats : mLoadingOngoing = %d", mLoadingOngoing);
	
	mLoadingOngoing--;
	if (mLoadingOngoing <= 0)
	{
		[mIndicatorView stopAnimating];
	}
	
	if (_nbOngoingIncidents == nil && _nbUpdatedIncidents == nil && _nbResolvedIncidents == nil)
	{
		return;
	}
	
	if ([_nbOngoingIncidents isEqualToString:@""] && [_nbUpdatedIncidents isEqualToString:@""] && [_nbResolvedIncidents isEqualToString:@""])
	{
		UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:NSLocalizedString(@"server_error_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[lAlert show];
		[lAlert release];
		return;
	}
	
	[mLabelOngoingIncidents setText:_nbOngoingIncidents];
	[mLabelUpdatedIncidents setText:_nbUpdatedIncidents];
	[mLabelResolvedIncidents setText:_nbResolvedIncidents];
	
	if ([_nbResolvedIncidents intValue] < 2)
	{
		[mLabelTextResolvedIncidents setText:NSLocalizedString(@"resolve", nil)];
	}
	else
	{
		[mLabelTextResolvedIncidents setText:NSLocalizedString(@"resolves", nil)];
	}
	
	mLabelTextOngoingIncidents.text = [_nbOngoingIncidents intValue] < 2 ? NSLocalizedString(@"ongoing", nil) : NSLocalizedString(@"ongoing_plural", nil);
}

#pragma mark -
#pragma mark Report Delegate Methods
- (void)didReceiveReportsOngoing:(NSArray*)_ongoing updated:(NSArray*)_updated resolved:(NSArray*)_resolved
{	
	C4MLog(@"didReceiveReportsOngoing : mLoadingOngoing = %d", mLoadingOngoing);
	mLoadingOngoing--;
	if (mLoadingOngoing <= 0)
	{
		[mIndicatorView stopAnimating];
	}
	
	if (_resolved == nil)
	{
		// TODO: Message d'erreur ?
		return;
	}
	
	NSNumber *nbResolved = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDictionaryKeyNumberResolved];
	if(nbResolved == nil)
	{
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:kUserDictionaryKeyNumberResolved];
		nbResolved = [NSNumber numberWithInt:0];
	}
	
	NSInteger resolvedIncidents = [_resolved count];
	
	if(resolvedIncidents > [nbResolved integerValue])
	{
		//C4MLog(@"NSUser value : %d/%d", [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDictionaryKeyNumberResolved] integerValue], resolvedIncidents);
		NSArray* items = [self.tabBarController.tabBar items];
		UITabBarItem *reports = [items objectAtIndex:3];
		reports.badgeValue = [NSString stringWithFormat:@"%d", [[NSNumber numberWithInt:(resolvedIncidents - [nbResolved integerValue])] integerValue]];
	}
	
	
}

#pragma mark -
#pragma mark UserAuthentication Delegate Methods
- (void)didAuthenticate
{
	[mViewLogin setHidden:YES];
	
	[self updateLoginButton];
	
	/*[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:.5];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	*/
	mLabelWelcomeUser.text = [NSString stringWithFormat:NSLocalizedString(@"welcome_message", nil), [[InfoVoirieContext sharedInfoVoirieContext] mUserLogin]];
	CGRect frame = mViewWelcomeUser.frame;
	frame.origin.y = -5;
	mViewWelcomeUser.frame = frame;
	
	frame = mButtonNewIncident.frame;
	frame.origin.y = 20 + mViewWelcomeUser.frame.size.height;
	mButtonNewIncident.frame = frame;
	
	//[UIView commitAnimations];
	
	[self viewWillAppear:YES];
	
	[[InfoVoirieContext sharedInfoVoirieContext] saveUserInfo];
	
	[mIndicatorView stopAnimating];
}

- (void)didFailedAuthenticationWithStatusCode:(NSInteger)_status
{	
	[[InfoVoirieContext sharedInfoVoirieContext] deconnectUser];
	
	[self updateLoginButton];
	
	[mIndicatorView stopAnimating];
}

@end
