//
//  CategorieController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "CategorieController.h"
#import "SubCategorieController.h"
#import "LieuIncidentController.h"
#import "CategoriesCell.h"

@implementation CategorieController

@synthesize mNextViewController;
@synthesize mFicheViewController;
@synthesize mReturnToRoot;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(BOOL) shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (id)initWithViewController:(ValidationRapportController *)_nextViewController
{
	if(self = [super initWithNibName:@"CategorieController" bundle:nil])
	{
		self.mNextViewController = _nextViewController;
		self.mFicheViewController = nil;
	}
	return self;
}

- (id)initWithFicheViewController:(FicheIncidentController *) _ficheViewController
{
	self = [super initWithNibName:@"CategorieController" bundle:nil];
	if (self) {
		self.mNextViewController = nil;
		self.mFicheViewController = _ficheViewController;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	mParentCategorie = [[NSMutableArray alloc] init];
	
    
    /* od style
	for (id key in [InfoVoirieContext sharedInfoVoirieContext].mCategory) 
	{
		NSMutableDictionary* lDic = [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:key]; 
		NSString* string = [lDic valueForKey:@"parent_id"];
		if([string isEqualToString:@"null"] )
		{
			[lDic setValue:key forKey:@"id"];
			[mParentCategorie addObject:lDic];
		}
	}
     */
    
    //new way
    NSMutableDictionary* lDic = [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:@"0"];
    for (NSNumber* key in [lDic objectForKey:@"children_id"]){
        NSLog(@"key class: %@", [key class]);
        NSMutableDictionary* cat = [NSMutableDictionary dictionaryWithDictionary:[[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:[NSString stringWithFormat:@"%d", [key intValue]]]]; 
        [cat setValue:key forKey:@"id"];
        [mParentCategorie addObject:cat];
    }
    NSLog(@"mParentCategorie: %@", mParentCategorie);
        
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"categorie_navbar_title", nil)];
	[self.navigationItem setTitleView:label];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(returnToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[mTableView reloadData];
}

- (IBAction) returnToPreviousView:(id)sender
{
	if (mReturnToRoot == YES) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark Table View Data Source Methods
// hauteur des cellules du tableau.
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return kCategoryCellHeight;
}

// nombre de cellule par section.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [mParentCategorie count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString* CellIdentifier = @"CategoriesCellIdentifier";
	CategoriesCell *cell = nil ;
	
	cell = (CategoriesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"CategoriesCell" owner:self options:nil];
		
		for(id oneObject in nib)
			if([oneObject isKindOfClass:[CategoriesCell class]])
				cell = (CategoriesCell *)oneObject;
	}
	NSString* toCapitalised = [[mParentCategorie objectAtIndex:indexPath.row] valueForKey:@"name"];
	cell.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:toCapitalised];
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	SubCategorieController *lSubCategorieController = nil;
	
	if (mFicheViewController == nil) {
		lSubCategorieController = [[SubCategorieController alloc] initWithNextView:mNextViewController andID:[[mParentCategorie objectAtIndex:indexPath.row] valueForKey:@"id"]];
	}else {
		lSubCategorieController = [[SubCategorieController alloc] initWithFicheView:mFicheViewController andID:[[mParentCategorie objectAtIndex:indexPath.row] valueForKey:@"id"]];
	}
	
	if ([[lSubCategorieController mParentCategorie] count] == 0)
	{
		[lSubCategorieController release];
		
		NSDictionary* category = [mParentCategorie objectAtIndex:[indexPath row]];
		NSNumber *numCat = [category valueForKey:@"id"];
		if (mNextViewController == nil) {
			if (mFicheViewController == nil) {
				IncidentObj *lincident = [[IncidentObj alloc] init];
				lincident.mcategory = [numCat integerValue];
				lincident.mstate = @"ongoing";
				LieuIncidentController *lLieuIncidentController = [[LieuIncidentController alloc] initWithIncident:lincident];
				[self.navigationController pushViewController:lLieuIncidentController animated:YES];
				[lLieuIncidentController release];
				[lincident release];
			}
			else {
				mFicheViewController.mIncident.mcategory = [numCat integerValue];
				CategoriesCell *cell = (CategoriesCell *)[tableView cellForRowAtIndexPath:indexPath];
				[[mFicheViewController mLabelParentCategory] setText:[[cell mLabelCategory] text]];
				[[mFicheViewController mLabelCategory] setText:@""];
				//TODO: request
				[mFicheViewController changeIncident];
				[self.navigationController popToViewController:mFicheViewController animated:YES];
			}
		}
		else {
			mNextViewController.mIncidentCreated.mcategory = [numCat integerValue];
			CategoriesCell *cell = (CategoriesCell *)[tableView cellForRowAtIndexPath:indexPath];
			[[mNextViewController mLabelParentCategory] setText:[[cell mLabelCategory] text]];
			[[mNextViewController mLabelCategory] setText:@""];
			[self.navigationController popToViewController:mNextViewController animated:YES];
		}
	}
	else
	{
		[self.navigationController pushViewController:lSubCategorieController animated:YES];
		[lSubCategorieController release];
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
}


- (void)dealloc {
	[mTableView release];
    [super dealloc];
}




@end
