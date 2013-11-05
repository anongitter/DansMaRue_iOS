//
//  C4MInfo.m
//  Beezik
//
//  Created by Prigent roudaut on 12/02/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "C4MInfo.h"


@implementation C4MInfo

@synthesize mTableView; 
@synthesize mWebView;

@synthesize mTransitionOut;

@synthesize mCodeOn;
@synthesize mCodeOff;	

@synthesize mDesignOn;	
@synthesize mDesignOff;	

@synthesize mNavOn;	
@synthesize mNavOff;

@synthesize mNavBar;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad 
{
	[super viewDidLoad];

    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7(x)

    
	NSString* web_content = NSLocalizedString(@"legalNoticeContent", nil);
	mWebView.dataDetectorTypes = UIDataDetectorTypeNone  ;
	[mWebView loadHTMLString:web_content baseURL:nil];
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"c4m_info_navbar_title", nil)];
	label.frame = CGRectMake(0, 0, 120, 44);
	[self.navigationController.navigationBar.topItem setTitleView:label];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationController.navigationBar.topItem setLeftBarButtonItem:returnButton];
	[returnButton release];
    
    
	NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersion = [appVersion stringByAppendingFormat:@" (%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	mLabelAppVersion.text = [NSString stringWithFormat:@"v%@", appVersion];
    
	UIBarButtonItem *lVersionNb = [[UIBarButtonItem alloc] initWithCustomView:mLabelAppVersion];
	[self.navigationController.navigationBar.topItem setRightBarButtonItem:lVersionNb];
	[lVersionNb release];
	
	
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        mNavBar.frame =  CGRectMake(0,20,mNavBar.frame.size.width,mNavBar.frame.size.height);
//        mNavBar.bounds = CGRectMake(0, 20, mNavBar.frame.size.width, mNavBar.frame.size.height);
//        mTableView.frame =  CGRectMake(0,64,mTableView.frame.size.width,mTableView.frame.size.height-20);
//        mTableView.bounds = CGRectMake(0, 64, mTableView.frame.size.width, mTableView.frame.size.height);
//        mLabelAppVersion.frame =  CGRectMake(231,31,mLabelAppVersion.frame.size.width,mLabelAppVersion.frame.size.height);
//        mLabelAppVersion.bounds = CGRectMake(231, 31, mLabelAppVersion.frame.size.width, mLabelAppVersion.frame.size.height);
    }
    
}

-(void) viewDidAppear:(BOOL)animated
{	[super viewDidAppear:animated];
	//[UserItem sharedUserItem].mImageBackGroundNavigationCurrent = [UserItem sharedUserItem].mImageBackGroundNavigation3;
	CATransition *transition = [CATransition animation];
	[transition setType:kCATransitionFade];
	[transition setSubtype:kCATransitionFromTop];	
	[transition setDuration:4.0f];
	[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];	
	
	[mCodeOn.layer addAnimation:transition forKey:nil];	
	[mCodeOff.layer addAnimation:transition forKey:nil];		
	mCodeOn.hidden = false; 
	mCodeOff.hidden = true; 	

    [mNavOn.layer addAnimation:transition forKey:nil];	
	[mNavOff.layer addAnimation:transition forKey:nil];		
	mNavOn.hidden = false; 
	mNavOff.hidden = true;

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* simpleCell = @"simpleCell";
	UITableViewCell *cell = nil;
	if (indexPath.row != 2)
	{
		cell = [aTableView dequeueReusableCellWithIdentifier:simpleCell];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (indexPath.row == 0)
		{
			cell.textLabel.text = NSLocalizedString(@"sharedApplication", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"infopanel.share.subtitle", nil);
		}
		else if (indexPath.row == 1)
		{
			cell.textLabel.text = NSLocalizedString(@"opinion", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"infopanel.comments.subtitle", nil);
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MFMailComposeViewController *mailComposeController = [[MFMailComposeViewController alloc] init];
	if (mailComposeController != nil) {
		
		NSString* emailBody = nil;
		
		[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = YES;
		mailComposeController.mailComposeDelegate = self;
		mailComposeController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		if (indexPath.row == 0)
		{
			NSString* objectText = NSLocalizedString(@"infopanel.mail.recommandation.subject", nil);
			mailComposeController.title = objectText;
			[mailComposeController setSubject:objectText];
			
			emailBody = [NSString stringWithFormat:NSLocalizedString(@"infopanel.mail.recommandation.body", nil),
						 NSLocalizedString(@"infopanel.mail.sreenshot.url", nil)];
		}
		else if (indexPath.row == 1)
		{
			//	mailComposeController.navigationBar.tintColor = self.tintColor;
			mailComposeController.title = NSLocalizedString(@"infopanel.mail.comments.subject", nil);
			[mailComposeController setToRecipients:[NSArray arrayWithObjects:NSLocalizedString(@"infopanel.mail.comments.mailto.address", nil), nil]];
			[mailComposeController setSubject:NSLocalizedString(@"infopanel.mail.comments.subject", nil)];
			
			emailBody = NSLocalizedString(@"infopanel.mail.comments.body", nil);
		}
		
		[mailComposeController setMessageBody:emailBody isHTML:YES];
		
		[self presentModalViewController:mailComposeController animated:YES];
		[mailComposeController release];
	}
	[mTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString* url_string = [[request mainDocumentURL] absoluteString];
	if ( url_string && url_string != nil && [url_string hasPrefix:@"about:"]) { 
		return YES;
	}
	[[UIApplication sharedApplication] openURL:[request mainDocumentURL]];
	return NO;
}
- (void) webViewDidFinishLoad:(UIWebView *)webView {
	float newSize = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
	webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, newSize);
	webView.hidden = NO;
	
	// We need to reset this, else the new frame is not used.
	[mTableView setTableFooterView:mWebView];
}

-(IBAction) btnCall:(id)sender
{
	UIAlertView * lAlert=[[UIAlertView alloc] initWithTitle:@"Appeler" message:@"04 91 31 60 35" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Appeler", nil];
	lAlert.tag = 1 ; 
	[lAlert show];
	[lAlert release];		
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		if(alertView.tag == 1)
		{
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"tel://0491316035"]];
		}
        
#warning TO DO clean this code - seems to not be used anymore
		else if(alertView.tag == 2)
		{
			NSString* url = @"http://www.c4mprod.com";
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
	}
}


-(IBAction) btnMail:(id)sender 
{
	NSString* subject = NSLocalizedString(@"infopanel.mail.c4minforequest.subject",@"C4M Info Request Mail Subject");
    NSString* body = NSLocalizedString(@"infopanel.mail.c4minforequest.body",@"C4M Info Request Mail Body");
	
    MFMailComposeViewController *mailComposeController = [[MFMailComposeViewController alloc] init];
	if (mailComposeController != nil)
	{
		[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = YES;
		mailComposeController.mailComposeDelegate = self;
		
		//mailComposeController.title = @"C4M";
		mailComposeController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		[mailComposeController setToRecipients:[NSArray arrayWithObjects:@"info@c4mprod.com", nil]];
		
		[mailComposeController setSubject:subject];
		[mailComposeController setMessageBody:body isHTML:NO];
		
		[self presentModalViewController:mailComposeController animated:YES];
		[mailComposeController release];
	}
    
}


#warning TO DO clean this code - seems to not be used anymore
-(IBAction) btnApps:(id)sender 
{
	UIAlertView * lAlert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", nil) message:NSLocalizedString(@"leave_app_to_browser", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"confirm", nil), nil];
	lAlert.tag = 2 ; 
	[lAlert show];
	[lAlert release];			
}

-(IBAction) btnBack:(id)sender 
{
	[self dismissModalViewControllerAnimated:true];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = NO;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc 
{
	mWebView.delegate = nil ; 
	mTableView.delegate = nil ; 	
	[mWebView release] ; 
	[mTableView release];
    [super dealloc];
}


@end
