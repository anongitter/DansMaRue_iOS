//
//  ConfirmIncidentCell.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 09/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ConfirmIncidentCell.h"
#import "incidentObj.h"
//#import "imageLoader.h"
#import "ImageManager.h"

@implementation ConfirmIncidentCell

@synthesize mIncidentCategory;
@synthesize mIncidentName;
@synthesize mIncidentDistance;
@synthesize mImageView;
@synthesize mIcon;
@synthesize mIncident;

-(void) updateWithIncident:(IncidentObj*) _IncidentObj
{
	CGRect CellWide = CGRectMake(0, 0, 320, kCellHeight);
	CGRect PictWide = CGRectMake(0, 0, 320, kCellHeight);
	
	UIView *bgView = [[UIView alloc] initWithFrame:CellWide];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:PictWide];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UIView *bgViewSelected = [[UIView alloc] initWithFrame:CellWide];
	UIImageView *imageViewSelected = [[UIImageView alloc] initWithFrame:PictWide];
    imageViewSelected.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	[imageView setImage:[UIImage imageNamed:@"item_cell_ou_off.png"]];
	[imageViewSelected setImage:[UIImage imageNamed:@"item_cell_ou_on.png"]];
	
	[bgView addSubview:imageView];
	[self setBackgroundView:bgView];
	[imageView release];
	[bgView release];
	[bgViewSelected addSubview:imageViewSelected];
	[self setSelectedBackgroundView:bgViewSelected];
	[imageViewSelected release];
	[bgViewSelected release];
	
	mIncidentName.text = [_IncidentObj.mdescriptive capitalizedString];
	
	NSMutableDictionary* lCategorie = [[InfoVoirieContext sharedInfoVoirieContext].mCategory valueForKey:[NSString stringWithFormat:@"%d", _IncidentObj.mcategory]];
    NSLog(@"lCategorie=%@", lCategorie);
    
	NSNumber* parentID = [lCategorie objectForKey:@"parent_id"];
	NSMutableDictionary* parentCategorie = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory] valueForKey:[NSString stringWithFormat:@"%d", [parentID intValue]]];
    
    
	if ([parentID intValue] <= 0)
	{
		mIncidentCategory.text = [[lCategorie valueForKey:@"name"] capitalizedString];
	}
	else {
		mIncidentCategory.text = [NSString stringWithFormat:@"%@\n%@", [[parentCategorie valueForKey:@"name"] capitalizedString], [[lCategorie valueForKey:@"name"] capitalizedString]];
	}
	//mIncidentCategory.text = @"toto";
	
	// Compute Distance
	CLLocationCoordinate2D userLocation = [[InfoVoirieContext sharedInfoVoirieContext] mLocation];
	CLLocation *location1 = [[CLLocation alloc] initWithLatitude:userLocation.latitude longitude:userLocation.longitude];
	CLLocation *location2 = [[CLLocation alloc] initWithLatitude:_IncidentObj.coordinate.latitude longitude:_IncidentObj.coordinate.longitude];
	double distance = [location1 distanceFromLocation:location2];
    
	
	mIncidentDistance.text = [NSString stringWithFormat:@"à %dm", [[NSNumber numberWithDouble:(distance)] intValue]];
	
	[location1 release];
	[location2 release];
	
	mIncident = [_IncidentObj retain];
	
	if (mIncident.minvalid == YES)
	{
		[mIcon setImage:[UIImage imageNamed:@"icn_incident_nonvalide.png"]];
	}
	else
	{
		[mIcon setImage:[UIImage imageNamed:@"icn_arrow.png"]];
	}

	//UIImage *image = nil;
	
	if ([[mIncident mpicturesFar] count] != 0)
	{
		/*ImageLoader *imageLoader = [ImageLoader sharedImageLoader];
		image = [imageLoader loadImage:[[_IncidentObj mpicturesFar] objectAtIndex:0] forDelegate:self];*/
		[[ImageManager sharedImageManager] getImageNamed:[[mIncident mpicturesFar] objectAtIndex:0] withDelegate:mImageView];
	}
	//[mImageView setImage:image];
}

/*- (void)didLoadImage:(UIImage*) _Image
{
	mImageView.image = _Image;
}*/

- (void)prepareForReuse
{
	mImageView.image = nil;
	
	if ([[mIncident mpicturesFar] count] != 0)
	{
		[[ImageManager sharedImageManager] removeDelegateForImage:[[mIncident mpicturesFar] objectAtIndex:0]];
	}
	[mIncident release];
	mIncident = nil;
}

- (void)dealloc
{
	[mIncidentCategory release];
	[mIncidentName release];
	[mIncidentDistance release];
	[mImageView release];
	[mIncident release];
    [super dealloc];
}

@end
