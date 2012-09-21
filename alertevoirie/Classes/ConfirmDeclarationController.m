//
//  ConfirmDeclarationController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ConfirmDeclarationController.h"

#import "ConfirmIncidentCell.h"
#import "FicheIncidentController.h"
#import "CategorieController.h"

@implementation ConfirmDeclarationController
@synthesize mIncidentsOngoing;

-(BOOL) shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		self.mIncidentsOngoing = [NSMutableArray array];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"new_report_navbar_title", nil)];
	[self.navigationItem setTitleView:label];
	
	NSMutableDictionary* lPosition = [NSMutableDictionary dictionary];
	[lPosition setObject:[NSNumber numberWithDouble:[InfoVoirieContext sharedInfoVoirieContext].mLocation.latitude] forKey:@"latitude"];
	[lPosition setObject:[NSNumber numberWithDouble:[InfoVoirieContext sharedInfoVoirieContext].mLocation.longitude] forKey:@"longitude"];
	
	mRequester = [[GetIncidentsByPosition alloc] initWithDelegate:self];
	[mRequester generatIncident:lPosition farRadius:NO];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	mLoadingView.frame = CGRectMake(0, 44, 320, 44);
	[self.view addSubview:mLoadingView];
	[self showLoadingView:YES];
	
	mLabel.text = NSLocalizedString(@"searching_near_incidents", nil);
	mTableView.hidden = YES;
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(returnToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
}

- (IBAction) returnToPreviousView:(id)sender
{
	self.navigationItem.leftBarButtonItem.enabled = NO;
	if (mLoadingView.hidden == NO) {
		[mRequester changeDelegateTo:nil];
		[self showLoadingView:NO];
	}
	else {
		
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDeclareIncident:(id)sender
{
	CategorieController *lCategorieController = [[CategorieController alloc] initWithViewController:nil];
	if ([mIncidentsOngoing count] == 0) {
		lCategorieController.mReturnToRoot = YES;
	}
	
	[self.navigationController pushViewController:lCategorieController animated:YES];
	[lCategorieController release];
	[self showLoadingView:NO];
}

- (void) showLoadingView:(BOOL)show
{
	mLoadingView.hidden = !show;
	
	if ( show)
	{
		UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
		mTableView.tableHeaderView = tmp;
		[tmp release];
	}
	else
	{
		mTableView.tableHeaderView = nil;
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
    // e.g. self.myOutlet = nil;
	mTableView = nil;
	mLabel = nil;
}

- (void)dealloc 
{
	[mRequester release];
	[mTableView release];
	[mLabel release];
	[mIncidentsOngoing release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([(ConfirmIncidentCell*)[tableView cellForRowAtIndexPath:indexPath] mIncident].minvalid == YES) {
		return;
	}
	
	FicheIncidentController *nextController = [[FicheIncidentController alloc] initWithIncident:[mIncidentsOngoing objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
	[self showLoadingView:NO];
}


// hauteur des cellules du tableau.
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return kConfirmCellHeight;
}

// nombre de cellule par section.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [mIncidentsOngoing count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString* myReportsCell = @"ConfirmIncidentCellIdentifier";
	
	ConfirmIncidentCell *cell = (ConfirmIncidentCell *)[tableView dequeueReusableCellWithIdentifier:myReportsCell];
	if(cell == nil)
	{
		NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ConfirmIncidentCell" owner:self options:nil];
		
		for(id oneObject in nib)
			if([oneObject isKindOfClass:[ConfirmIncidentCell class]])
				cell = (ConfirmIncidentCell *)oneObject;
	}
	[cell updateWithIncident:[mIncidentsOngoing objectAtIndex:indexPath.row]];
	
	return cell;
}

#pragma mark -
#pragma mark Incident Delegate Methods
-(void)didReceiveIncidents:(NSArray*)_incidents
{
	NSString* lstatus;
	
	if (_incidents == nil) {
		//[self performSelector:@selector(btnDeclareIncident:) withObject:nil afterDelay:.2];
		[self showLoadingView:NO];
		return;
	}
	
	[mIncidentsOngoing removeAllObjects];
	
	for(IncidentObj *lincident in _incidents)
	{
		lstatus = lincident.mstate;
		if([lstatus isEqualToString:@"O"] || [lstatus isEqualToString:@"U"])
		{
			[self.mIncidentsOngoing addObject:lincident];
		}
	}
	
	if ([mIncidentsOngoing count] == 0)
	{
		[self performSelector:@selector(btnDeclareIncident:) withObject:nil afterDelay:.2];
		[self showLoadingView:NO];
		return;
	}
	
	[self showLoadingView:NO];
	mLabel.text = NSLocalizedString(@"question_incident_already_declared", nil);
	mTableView.hidden = NO;
	[mTableView reloadData];
}

@end
