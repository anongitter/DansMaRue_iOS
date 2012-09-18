//
//  FicheIncidentController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "incidentObj.h"
#import "ArrowViewController.h"
#import "updateIncidentDelegate.h"
#import "finalImageDelegate.h"
#import "commentaireDelegate.h"
#import "sendingPictureDelegate.h"
#import "changeIncidentDelegate.h"
#import "ImageViewManager.h"
#import "GetUpdates.h"

#define kJSONConfirmed				@"Confirmed"
#define kJSONResolved				@"Resolved"
#define kJSONInvalidated			@"Invalid"
#define kJSONDoubleConfirmed		@"DoubleConfirmed"
#define kJSONDoubleResolved			@"DoubleResolved"
#define kJSONDoubleInvalidate		@"DoubleInvalidate"

#define kAlertViewInvalidateTag		0
#define kAlertViewConfirmTag		1
#define kAlertViewResolvedTag		2

#define kActionSheetPhotoType		0
#define kActionSheetPhotoSource		1

#define kImagePickerOverView		0
#define kImagePickerNearView		1

#define kWhereButtonTag				0
#define kCategoryButtonTag			1

#define kFooterHeight				220
#define kHeaderHeight				482
#define kHeaderUpdateHeight			20
#define kCellFicheHeight			160

@interface FicheIncidentController : UIViewController
	<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, updateIncidentDelegate,
	UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,
	UINavigationControllerDelegate, finalImageDelegate, commentDelegate, sendingPictureDelegate,
	/*UpdateFormPictureDelegate,*/ changeIncidentDelegate, getUpdatesDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
	//UIScrollView *mScrollView;
	UITableView *mTableView;
	UIView		*mUpperElementsView;
	UIView		*mButtonsView;
	
	NSMutableArray		*mArrayUpdate;
	NSMutableDictionary* mUpdateImages;
	
	UILabel *mLabelDescription;
	UILabel *mLabelDate;
	UILabel *mLabelWhere;
	UILabel *mLabelAddress;
	UILabel *mLabelParentCategory;
	UILabel *mLabelCategory;
	UILabel *mLabelNumberConfirmations;
    UILabel *mLabelPriority;
	
	UIButton *mButtonAddPhoto;
	UIButton *mButtonInvalidateIncident;
	UIButton *mButtonIncidentResolved;
	UIButton *mButtonConfirmIncident;
	
	ImageViewManager *mImageNear;
	ImageViewManager *mImageFar;
	
	IncidentObj *mIncident;
	
	BOOL mButtonInvalidateIncidentActive;
	BOOL mButtonIncidentResolvedActive;
	BOOL mButtonConfirmIncidentActive;
	
	ArrowViewController *mArrowViewController;
	UIImagePickerController *mImagePickerController;
	NSInteger mTypeImagePicked;
	
	GetUpdates *mGetUpdates;
	
	UIImage *mFinalImage;
	UIView  *mLoadingView;
	BOOL mLoadingOngoing;
    
    IBOutlet UIView             *mPickerHolderView;
    UIPickerView       *mPicker;
    int incidentId;
    NSArray            *incidentLabels;
}

- (id)initWithIncident:(IncidentObj	*)_incident;
- (void) showLoadingView:(BOOL)show;
- (NSString*)createConfirmationText;
- (void) changeIncident;
- (IBAction)touchUpButton:(id)sender;
- (IBAction)touchDownButton:(id)sender;
- (IBAction)triggerReturnButton:(id)sender;
- (IBAction)triggerWhereButton:(id)sender;
- (IBAction)triggerCategoryButton:(id)sender;
- (IBAction)triggerPriorityButton:(id)sender;
- (IBAction)triggerInvalidateIncidentButton:(id)sender;
- (IBAction)triggerIncidentResolvedButton:(id)sender;
- (IBAction)triggerConfirmIncidentButton:(id)sender;
- (IBAction) triggerAddPhotoButton:(id)sender;
- (IBAction) onPickerHolder:(id)sender;

/*+ (void)threadLoadingImageFar:(FicheIncidentController*)_fic;
+ (void)threadLoadingImageClose:(FicheIncidentController*)_fic;
+ (UIImage*) LoadImage:(NSString*) _fileName andURL:(NSString*) _url;
*/
@property (nonatomic, retain) IncidentObj *mIncident;

@property (nonatomic, retain) IBOutlet UIScrollView *mScrollView;
@property (nonatomic, retain) IBOutlet UITableView *mTableView;
@property (nonatomic, retain) IBOutlet UIView	*mUpperElementsView;
@property (nonatomic, retain) IBOutlet UIView	*mButtonsView;
@property (nonatomic, retain) IBOutlet UILabel *mLabelDescription;
@property (nonatomic, retain) IBOutlet UILabel *mLabelDate;
@property (nonatomic, retain) IBOutlet UILabel *mLabelWhere;
@property (nonatomic, retain) IBOutlet UILabel *mLabelAddress;
@property (nonatomic, retain) IBOutlet UILabel *mLabelParentCategory;
@property (nonatomic, retain) IBOutlet UILabel *mLabelCategory;
@property (nonatomic, retain) IBOutlet UILabel *mLabelPriority;
@property (nonatomic, retain) IBOutlet UILabel *mLabelNumberConfirmations;

@property (nonatomic, retain) IBOutlet UIButton *mButtonAddPhoto;
@property (nonatomic, retain) IBOutlet UIButton *mButtonInvalidateIncident;
@property (nonatomic, retain) IBOutlet UIButton *mButtonIncidentResolved;
@property (nonatomic, retain) IBOutlet UIButton *mButtonConfirmIncident;

@property (nonatomic, retain) IBOutlet ImageViewManager *mImageFar;
@property (nonatomic, retain) IBOutlet ImageViewManager *mImageNear;

@property (nonatomic, retain) UIImage *mFinalImage;
@property (nonatomic, retain) NSMutableArray* mArrayUpdate;
@property (nonatomic, retain) NSMutableDictionary* mUpdateImages;

@property (nonatomic) NSInteger mTypeImagePicked;

@property (nonatomic, retain) ArrowViewController *mArrowViewController;
@property (nonatomic, retain) UIImagePickerController *mImagePickerController;

@property (nonatomic, retain) IBOutlet UIPickerView *mPicker;

@end
