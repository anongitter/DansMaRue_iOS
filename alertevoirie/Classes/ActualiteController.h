//
//  ActualiteController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "activityDelegate.h"
#import "FicheIncidentController.h"
#import "GetActivities.h"
#import "ActualiteCell.h"
#import <MessageUI/MFMailComposeViewController.h>

#define kTableViewRowHeight			100
#define kTableViewHeaderHeight		28

#define kResolvedKey				@"Resolved"
#define kConfirmedKey				@"Confirmed"
#define kInvalidatedKey				@"Invalid"
#define kPhotoKey					@"Photo"
#define kNewKey						@"NewIncident"

#define kIconCreated				@"icn_creer.png"
#define kIconAddedPhoto				@"icn_photo_ajoutee.png"
#define kIconConfirmed				@"icn_incident_confirme.png"
#define kIconResolved				@"icn_incident_resolu.png"
#define kIconInvalidated			@"icn_incident_nonvalide.png"

@interface ActualiteController : UIViewController
	<UITableViewDelegate, UITableViewDataSource, activityDelegate, MFMailComposeViewControllerDelegate>
{
	NSMutableDictionary*		mActivities;
	NSMutableDictionary*		mIncidentsById;
	NSMutableArray*				mOrderedKeys;
	NSMutableArray*				mBannedIncidentsId;
	IBOutlet UITableView*		mTableView;
	
	UIView*						mLoadingView;
	BOOL						mLoadingOngoing;
}

@property (nonatomic, retain) UILabel *                 mLabelInfo;
@property (nonatomic, retain) NSMutableDictionary*		mActivities;
@property (nonatomic, retain) NSMutableDictionary*		mIncidentsById;
@property (nonatomic, retain) NSMutableArray*			mOrderedKeys;
@property (nonatomic, retain) NSMutableArray*			mBannedIncidentsId;

- (void)showLoadingView:(BOOL)show;

- (IBAction) mailShareApp;

@end
