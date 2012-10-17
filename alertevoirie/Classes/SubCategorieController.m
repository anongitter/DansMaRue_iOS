//
//  SubCategorieController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "SubCategorieController.h"
#import "SupCategorieController.h"
#import "LieuIncidentController.h"
#import "CategoriesCell.h"

@implementation SubCategorieController
@synthesize mNextViewController;
@synthesize mFicheViewController;
@synthesize mParentCategorie;
@synthesize mStreetFurnituresPictures;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNextView:(ValidationRapportController *)_nextView andID:(NSNumber*) _ParentID
{
    
    NSLog(@"---------------1");
    
    if ((self = [super initWithNibName:@"CategorieController" bundle:nil])) 
	{
		mParentCategorie = [[NSMutableArray alloc] init];
        
		for (id key in [InfoVoirieContext sharedInfoVoirieContext].mCategory) 
		{
			NSMutableDictionary* lDic = [NSMutableDictionary dictionaryWithDictionary:[[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:key]]; 
            
			NSNumber* num = [lDic valueForKey:@"parent_id"];
			NSString* string = [NSString stringWithFormat:@"%d", [num intValue]];
            
            //NSLog(@"sub lDic=%@ _ParentID='%@' string='%@'", lDic, _ParentID, string);
			if([num intValue] ==  [_ParentID intValue])
			{
				[lDic setValue:key forKey:@"id"];
				[mParentCategorie addObject:lDic];
			}
		}
        //NSLog(@"sub mParentCategorie=%@", mParentCategorie);
        
		mUseStreetFurnituresCells = NO;
		
		mParentString = [[[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:[NSString stringWithFormat:@"%d", [_ParentID intValue]]] objectForKey:@"name"];
        //NSLog(@"====> parent=%@", [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:_ParentID]);
        
        UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:mParentString];
        [self.navigationItem setTitleView:label];
        
		
		if ([[mParentString lowercaseString] isEqualToString:[NSString stringWithFormat:@"%@", @"mobiliers urbains"]])
		{
			mUseStreetFurnituresCells = YES;
			NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"street_furnitures_pictures_dictionary" ofType:@"plist"];
			self.mStreetFurnituresPictures = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		}
		mNextViewController = _nextView;
		mFicheViewController = nil;
    }
    return self;
}

- (id)initWithFicheView:(FicheIncidentController *)_nextView andID:(NSString*) _ParentID
{
    if ((self = [super initWithNibName:@"CategorieController" bundle:nil])) 
	{
		mParentCategorie = [[NSMutableArray alloc] init];
		for (id key in [InfoVoirieContext sharedInfoVoirieContext].mCategory) 
		{
			NSMutableDictionary* lDic = [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:key]; 
			NSString* string = [lDic valueForKey:@"parent_id"];
			
			if([string isEqualToString:_ParentID] )
			{
				[lDic setValue:key forKey:@"id"];
				[mParentCategorie addObject:lDic];
			}
		}
		mUseStreetFurnituresCells = NO;
		
		mParentString = [[[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:_ParentID] objectForKey:@"name"];
		
		if ([[mParentString lowercaseString] isEqualToString:[NSString stringWithFormat:@"%@", @"mobiliers urbains"]])
		{
			mUseStreetFurnituresCells = YES;
			NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"street_furnitures_pictures_dictionary" ofType:@"plist"];
			self.mStreetFurnituresPictures = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		}
		mFicheViewController = _nextView;
		mNextViewController = nil;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

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
    // e.g. self.myOutlet = nil;
	mTableView = nil;
}


- (void)dealloc
{
	[mTableView release];
	[mParentCategorie release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Delegate Methods

// hauteur des cellules du tableau.
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return kSubCategoryCellHeight;
}

// nombre de cellule par section.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [mParentCategorie count];
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
	else
	{
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
	NSString* toCapitalised = [[mParentCategorie objectAtIndex:indexPath.row] valueForKey:@"name"];
	cell.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:toCapitalised];
	if (mUseStreetFurnituresCells == YES)
	{
		// TODO: real images for street furnitures cells
		NSString* imageName = [mStreetFurnituresPictures objectForKey:[[mParentCategorie objectAtIndex:indexPath.row] objectForKey:@"id"]];
		[cell.mImageView setImage:[UIImage imageNamed:imageName]];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary* category = [mParentCategorie objectAtIndex:[indexPath row]];
 
	NSNumber *numCat = [category valueForKey:@"id"];
	BOOL children = NO;
	if ([category valueForKey:@"children_id"] != nil)
	{
		children = YES;
	}
	if (mNextViewController != nil)
	{
		if (children == YES)
		{
			SupCategorieController *nextController = [[SupCategorieController alloc] initWithNextView:mNextViewController andID:[category valueForKey:@"children_id"]];
			[self.navigationController pushViewController:nextController animated:YES];
			[nextController release];
		}
		else
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
		
			[self.navigationController popToViewController:mNextViewController animated:YES];
		}
	}
	else
	{
		if (mFicheViewController != nil)
		{
			if (children == YES)
			{
				SupCategorieController *nextController = [[SupCategorieController alloc] initWithFicheView:mFicheViewController andID:[category valueForKey:@"children_id"]];
				[self.navigationController pushViewController:nextController animated:YES];
				[nextController release];
			}
			else
			{
			NSDictionary* lDic = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
								  objectForKey:[NSString stringWithFormat:@"%d", [numCat integerValue]]];
			
			mFicheViewController.mIncident.mcategory = [numCat integerValue];
			mFicheViewController.mLabelCategory.text = [lDic objectForKey:@"name"];
			mFicheViewController.mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mFicheViewController.mLabelCategory.text];
			
			NSNumber *parentID = [lDic objectForKey:@"parent_id"];
			mFicheViewController.mLabelParentCategory.text =  [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
															   objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"name"];
			mFicheViewController.mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mFicheViewController.mLabelParentCategory.text];
			
			// TODO: request
			[mFicheViewController changeIncident];
			[self.navigationController popToViewController:mFicheViewController animated:YES];
			}
		}
		else
		{
			if (children == YES)
			{
				SupCategorieController *nextController = [[SupCategorieController alloc] initWithNextView:mNextViewController andID:[category valueForKey:@"children_id"]];
				[self.navigationController pushViewController:nextController animated:YES];
				[nextController release];
			}
			else
			{
				IncidentObj *lincident = [[IncidentObj alloc] init];
				lincident.mcategory = [numCat integerValue];
				lincident.mstate = @"ongoing";
				LieuIncidentController *lLieuIncidentController = [[LieuIncidentController alloc] initWithIncident:lincident];
				[self.navigationController pushViewController:lLieuIncidentController animated:YES];
				lLieuIncidentController.title = NSLocalizedString(@"precise_incident_place", nil);
				[lLieuIncidentController release];
				[lincident release];
			}
		}
	}	
}

@end
