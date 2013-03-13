//
//  MesRapportsController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "MapKit/MKAnnotation.h"
#import "DDAnnotation.h"

#import "constants.h"
#import "reportDelegate.h"

#define kSwitchOngoingIndex		0
#define kSwitchUpdatedIndex		1
#define kSwitchResolvedIndex	2

#define kTableViewRowHeight		120
#define kTableViewHeaderHeight	28

@interface MesRapportsController : UIViewController
	<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, reportDelegate>
{	
	NSMutableArray*					mArrayCurrentTable;
	NSMutableDictionary*			mDictionnaryReportsOngoing;
	NSMutableArray*					mOrderedKeys;
	
	// UI labels used on segmented controller
	IBOutlet UILabel*				mLabelOngoing;
	IBOutlet UILabel*				mLabelUpdated;
	IBOutlet UILabel*				mLabelResolved;
	IBOutlet UILabel*				mLabelNumOngoing;
	IBOutlet UILabel*				mLabelNumUpdated;
	IBOutlet UILabel*				mLabelNumResolved;
	//
	
	IBOutlet UIView*				mViewNotConnected;
	
	IBOutlet UISegmentedControl*	mSegmentedControl;
	
	IBOutlet UITableView*			mTableView;
	IBOutlet MKMapView*				mMapView;
	
	IBOutlet UIButton*				mMapButtonView;
	IBOutlet UIButton*				mListButtonView;
	
	UILabel*							mLabelInfo;
	
	NSMutableArray*					mReportsOngoing;
	NSMutableArray*					mReportsUpdated;
	NSMutableArray*					mReportsResolved;
	
	UIView*							mLoadingView;
	BOOL							mLoadingOngoing;
	BOOL							mMapShown;
}

@property (nonatomic, retain) UILabel *mLabelInfo;

@property (nonatomic, retain) NSArray* mArrayCurrentTable;
@property (nonatomic, retain) NSMutableArray* mReportsOngoing;
@property (nonatomic, retain) NSMutableArray* mReportsUpdated;
@property (nonatomic, retain) NSMutableArray* mReportsResolved;

- (void)changeLabelsColor:(NSInteger)_index;
- (void)changeMapAnnotations:(NSInteger)_index;
- (void)disableSegmentsLabel;
- (IBAction)toggleControls:(id)sender;
- (IBAction)mapButtonPressed:(id)sender;
- (void) showLoadingView:(BOOL)show;
- (void)orderDictionaryAccordingToDate;

@end
