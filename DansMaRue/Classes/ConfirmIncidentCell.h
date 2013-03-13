//
//  ConfirmIncidentCell.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 09/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateImageCellDelegate.h"
#import "ConfirmDeclarationController.h"
//#import "imageLoaderDelegate.h"
#import "ImageViewManager.h"

#define kCellHeight 180

@class IncidentObj;
@interface ConfirmIncidentCell : UITableViewCell
//	<imageLoaderDelegate>
{
	UILabel				*mIncidentName;
	UILabel				*mIncidentCategory;
	UILabel				*mIncidentDistance;
	ImageViewManager	*mImageView;
	UIImageView			*mIcon;
	
	IncidentObj			*mIncident;
	
	ConfirmDeclarationController *mController;
	NSInteger mIndex;
}

@property (nonatomic, retain) IBOutlet UILabel *mIncidentCategory;
@property (nonatomic, retain) IBOutlet UILabel *mIncidentName;
@property (nonatomic, retain) IBOutlet UILabel *mIncidentDistance;
@property (nonatomic, retain) IBOutlet ImageViewManager	*mImageView;
@property (nonatomic, retain) IBOutlet UIImageView	*mIcon;
@property (nonatomic, retain) IncidentObj *mIncident;

-(void) updateWithIncident:(IncidentObj*) _IncidentObj;

@end
