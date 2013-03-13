//
//  UpdateCell.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 13/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "incidentObj.h"
//#import "imageLoader.h"
//#import "imageLoaderDelegate.h"
#import "ImageViewManager.h"
#import "FicheIncidentController.h"

@interface UpdateCell : UITableViewCell
	//<imageLoaderDelegate>
{
	UILabel *mLabelDescription;
	UILabel *mLabelDate;
	ImageViewManager *mImageView;
	
	NSString* mImageURL;
	
	FicheIncidentController *mController;
	NSInteger mIndex;
}

@property (nonatomic, retain) IBOutlet UILabel *mLabelDescription;
@property (nonatomic, retain) IBOutlet UILabel *mLabelDate;
@property (nonatomic, retain) IBOutlet ImageViewManager *mImageView;

-(void) updateWithInfo:(NSDictionary*) _info;
//-(void) updateWithInfo:(NSDictionary*)_info index:(NSInteger)_index controller:(FicheIncidentController*)_controller;

@end
