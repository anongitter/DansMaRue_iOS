//
//  IncidentsController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "MapKit/MKAnnotation.h"
#import "incidentDelegate.h"

#define kSwitchOngoingIndex			0
#define kSwitchDeclaredIndex		1
#define kSwitchResolvedIndex		2

@interface IncidentsController : UIViewController<incidentDelegate,MKMapViewDelegate>
{
	// UI labels used on segmented controller
	IBOutlet UILabel*			mLabelOngoing;
	IBOutlet UILabel*			mLabelUpdated;
	IBOutlet UILabel*			mLabelResolved;
	
	IBOutlet UILabel*			mLabelNumOngoing;
	IBOutlet UILabel*			mLabelNumUpdated;
	IBOutlet UILabel*			mLabelNumResolved;
	
	IBOutlet UIView*			mViewNotConnected;
	
	
	IBOutlet UISegmentedControl*			mSegmentedControl;
	
	IBOutlet MKMapView*					mMKMapView;
	
	NSMutableArray*				mIncidentsOngoing;
	NSMutableArray*				mIncidentsUpdated;
	NSMutableArray*				mIncidentsResolved;
	
	UIView*						mLoadingView;
	BOOL						mLoadingOngoing;
}

@property (nonatomic, retain) NSMutableArray*				mIncidentsOngoing;
@property (nonatomic, retain) NSMutableArray*				mIncidentsUpdated;
@property (nonatomic, retain) NSMutableArray*				mIncidentsResolved;

- (void) showLoadingView:(BOOL)show;
- (void)changeLabelsColor:(NSInteger)_index;
- (IBAction)toggleControls:(id)sender;

@end
