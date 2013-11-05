//
//  SupCategorieController.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 16/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "SupCategorieController.h"
#import "FullscreenLieuIncidentController.h"
#import "CategoriesCell.h"
#import "InfoVoirieContext.h"


@implementation SupCategorieController
@synthesize mNextViewController;
@synthesize mFicheViewController;
@synthesize mSupCategorie;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithID:(NSArray*) _ChildrenID
{
    //NSLog(@"_ChildrenID=%@", _ChildrenID);
    
	self = [super initWithNibName:@"CategorieController" bundle:nil];
	if (self)
	{
		mSupCategorie = [[NSMutableArray alloc] init];
		for (NSNumber* child in _ChildrenID)
		{
            //NSLog(@"mCategory=%@", [InfoVoirieContext sharedInfoVoirieContext].mCategory);
			NSMutableDictionary* lDic = [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:[NSString stringWithFormat:@"%d", child.intValue]];
			[lDic setValue:child forKey:@"id"];
			[mSupCategorie addObject:lDic];
		}
        
        
		mUseStreetFurnituresCells = NO;
		NSNumber* parentID = [[mSupCategorie objectAtIndex:0] objectForKey:@"parent_id"];
		mParentString = [[[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:[NSString stringWithFormat:@"%d", parentID.intValue]] objectForKey:@"name"];
		
        UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:mParentString];
        [self.navigationItem setTitleView:label];
        
		if ([[mParentString lowercaseString] isEqualToString:[NSString stringWithFormat:@"%@", @"mobiliers urbains"]])
		{
			mUseStreetFurnituresCells = YES;
		}
	}
	return self;
}

- (id)initWithNextView:(ValidationRapportController *)_nextView andID:(NSArray*) _ChildrenID
{
    if ([self initWithID:_ChildrenID]) 
	{
		mNextViewController = _nextView;
		mFicheViewController = nil;
    }
    return self;
}

- (id)initWithFicheView:(FicheIncidentController *)_nextView andID:(NSArray*) _ChildrenID
{
    if ([self initWithID:_ChildrenID]) 
	{
		mFicheViewController = _nextView;
		mNextViewController = nil;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //fix iOS7 to vaid layout go underneath the navBar
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7(x)
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:mParentString];
	[self.navigationItem setTitleView:label];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(returnToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
}

- (IBAction) returnToPreviousView:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
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
	[mSupCategorie release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Delegate Methods

// hauteur des cellules du tableau.
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return kSupCategoryCellHeight;
}

// nombre de cellule par section.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [mSupCategorie count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString* CellIdentifier = @"CategoriesCellIdentifier";
	static NSString* CellSFIdentifier = @"CategoriesCellSFIdentifier";
	
	CategoriesCell *cell = nil ;
	if (mUseStreetFurnituresCells == YES)
	{
		cell = (CategoriesCell *)[tableView dequeueReusableCellWithIdentifier:CellSFIdentifier];
	}
	else {
		cell = (CategoriesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	}
	
	if (cell == nil)
	{
		NSArray* nib;
		if (mUseStreetFurnituresCells == YES)
		{
			nib = [[NSBundle mainBundle] loadNibNamed:@"CategoriesStreetFurnituresCell" owner:self options:nil];
		}
		else
		{
			nib = [[NSBundle mainBundle] loadNibNamed:@"CategoriesCell" owner:self options:nil];
		}
		
		for(id oneObject in nib)
			if([oneObject isKindOfClass:[CategoriesCell class]])
				cell = (CategoriesCell *)oneObject;
	}
	NSString* toCapitalised = [[mSupCategorie objectAtIndex:indexPath.row] valueForKey:@"name"];
	cell.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:toCapitalised];
	if (mUseStreetFurnituresCells == YES)
	{
		// TODO: real images for street furnitures cells
		[cell.mImageView setImage:nil];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary* category = [mSupCategorie objectAtIndex:[indexPath row]];
	NSNumber *numCat = [category valueForKey:@"id"];
	if (mNextViewController != nil)
	{
		NSDictionary* lDic = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
							  objectForKey:[NSString stringWithFormat:@"%d", [numCat integerValue]]];
		
		mNextViewController.mIncidentCreated.mcategory = [numCat integerValue];
		mNextViewController.mLabelCategory.text = [lDic objectForKey:@"name"];
		mNextViewController.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mNextViewController.mLabelCategory.text];
		
		NSNumber *parentID = [lDic objectForKey:@"parent_id"];
		mNextViewController.mLabelParentCategory.text =  [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
														   objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"name"];
		mNextViewController.mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mNextViewController.mLabelParentCategory.text];
		
		NSString* gdParentID = [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
								 objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"parent_id"];
		NSDictionary* gdParent = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory] objectForKey:gdParentID];
		if (gdParent != nil) {
			NSString* gdParentString = [gdParent objectForKey:@"name"];
			mNextViewController.mLabelCategory.text = [NSString stringWithFormat:@"%@ %@", mNextViewController.mLabelParentCategory.text, [lDic objectForKey:@"name"]];
			mNextViewController.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mNextViewController.mLabelCategory.text];
			mNextViewController.mLabelParentCategory.text = gdParentString;
			mNextViewController.mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mNextViewController.mLabelParentCategory.text];
		}
		
		[self.navigationController popToViewController:mNextViewController animated:YES];
	}
	else
	{
		if (mFicheViewController != nil) {
			NSDictionary* lDic = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
								  objectForKey:[NSString stringWithFormat:@"%d", [numCat integerValue]]];
			
			mFicheViewController.mIncident.mcategory = [numCat integerValue];
			mFicheViewController.mLabelCategory.text = [lDic objectForKey:@"name"];
			mFicheViewController.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mFicheViewController.mLabelCategory.text];
			
			NSNumber *parentID = [lDic objectForKey:@"parent_id"];
			mFicheViewController.mLabelParentCategory.text =  [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
														   objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"name"];
			mFicheViewController.mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mFicheViewController.mLabelParentCategory.text];
			
			NSString* gdParentID = [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
									 objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"parent_id"];
			NSDictionary* gdParent = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory] objectForKey:gdParentID];
			if (gdParent != nil) {
				NSString* gdParentString = [gdParent objectForKey:@"name"];
				mFicheViewController.mLabelCategory.text = [NSString stringWithFormat:@"%@ %@", mFicheViewController.mLabelParentCategory.text, [lDic objectForKey:@"name"]];
				mFicheViewController.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mFicheViewController.mLabelCategory.text];
				mFicheViewController.mLabelParentCategory.text = gdParentString;
				mFicheViewController.mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mFicheViewController.mLabelParentCategory.text];
			}
			
			[mFicheViewController changeIncident];
			[self.navigationController popToViewController:mFicheViewController animated:YES];
		}
		else {
			IncidentObj *lincident = [[IncidentObj alloc] init];
			lincident.mcategory = [numCat integerValue];
			//NSLog(@"sup category : category : %d", lincident.mcategory);
			lincident.mstate = @"ongoing";
			FullscreenLieuIncidentController *lFullscreenLieuIncidentController = [[FullscreenLieuIncidentController alloc] initWithIncident:lincident];
			[self.navigationController pushViewController:lFullscreenLieuIncidentController animated:YES];
			lFullscreenLieuIncidentController.title = NSLocalizedString(@"precise_incident_place", nil);
			[lFullscreenLieuIncidentController release];
			[lincident release];
		}
	}	
}

@end
