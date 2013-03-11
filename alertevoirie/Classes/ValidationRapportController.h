//
//  ValidationRapportController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "incidentObj.h"
#import "ArrowViewController.h"
#import "finalImageDelegate.h"
#import "commentaireDelegate.h"
#import "saveIncidentDelegate.h"
#import "CommentaireController.h"
#import "SendIncidentPictures.h"
#import "SaveIncident.h"


#define kImagePickerOverView				0
#define kImagePickerNearView				1

#define kAlertViewCancelReport				0
#define kAlertViewReturnWithoutSave			1
#define kAlertViewSavedIncident				2
#define kAlertViewPhotoNotSaved				3
#define kAlertViewEmail                     4

#define kActionSheetLibrary					0
#define kActionSheetPhoto					1

#define kWhereButtonTag						0
#define kCategoryButtonTag					1

@interface ValidationRapportController : UIViewController
 <UIImagePickerControllerDelegate, UINavigationControllerDelegate, finalImageDelegate, 
	commentDelegate, UpdateFormPictureDelegate, UIAlertViewDelegate, saveIncidentDelegate,
	UIActionSheetDelegate, sendingPictureDelegate>
{
	IBOutlet UIScrollView *mScrollView;
	NSInteger mTypeImagePicked;
	NSInteger mImagesSent;
	NSInteger mCurrentConfirmImagesSent;
	NSInteger mCurrentSuccessOnImagesSent;
	
	IBOutlet UIImageView *mImageViewNear;
	IBOutlet UIImageView *mImageViewFar;
	IBOutlet UIImageView *mCameraNear;
	IBOutlet UIImageView *mCameraFar;
	IBOutlet UIImageView *mIconNear;
	IBOutlet UIImageView *mIconFar;
	
	IBOutlet UILabel *mLabelDescription;
	IBOutlet UIButton *mButtonDescription;
	IBOutlet UIImageView *mImageViewDescription;
	
	IBOutlet UILabel *mLabelWhere;
	IBOutlet UILabel *mLabelParentCategory;
	IBOutlet UILabel *mLabelCategory;
	IBOutlet UILabel *mLabelAddressStreet;
	IBOutlet UILabel *mLabelAddressCity;
	
	IBOutlet UILabel *mLabelFarPhoto;
	IBOutlet UILabel *mLabelNearPhoto;
	
	IBOutlet UIButton *mButtonValidate;
    UIBarButtonItem          *mCancelButtonItem;
    UIBarButtonItem          *mOkButtonItem;
	
	UIImage *mImageFar;
	UIImage *mImageClose;
	
	ArrowViewController *mArrowViewController;
	UIImagePickerController *mImagePickerController;
	IncidentObj *mIncidentCreated;
	
	UIView *mLoadingView;
    
    UILabel *mLabelPriority;
    UILabel *mLabelEmail;
    
    IBOutlet UIView             *mPickerHolderView;
    UIPickerView       *mPicker;
    int incidentId;
    NSArray            *incidentLabels;
}

@property (nonatomic, retain) UIImage* mImageFar;
@property (nonatomic, retain) UIImage* mImageClose;
@property (nonatomic, retain) UILabel* mLabelParentCategory;
@property (nonatomic, retain) UILabel* mLabelCategory;
@property (nonatomic, retain) UILabel* mLabelAddressStreet;
@property (nonatomic, retain) UILabel* mLabelAddressCity;
@property (nonatomic, retain) ArrowViewController *mArrowViewController;
@property (nonatomic, retain) UIImagePickerController *mImagePickerController;
@property (nonatomic, retain) IncidentObj *mIncidentCreated;
@property (nonatomic, retain) IBOutlet UILabel *mLabelPriority;
@property (nonatomic, retain) IBOutlet UILabel *mLabelEmail;
@property (nonatomic, retain) IBOutlet UIPickerView *mPicker;

- (id)initWithIncident:(IncidentObj *)_incident;
- (void) showLoadingView:(BOOL)show;
- (IBAction) textFieldDoneEditing:(id)sender;
- (IBAction) touchUpButton:(id)sender;
- (IBAction) touchDownButton:(id)sender;
- (IBAction) descriptionButtonPressed:(id)sender;
- (IBAction) whereButtonPressed:(id)sender;
- (IBAction) categoryButtonPressed:(id)sender;
- (IBAction) cancelReport:(id)sender;
- (IBAction) validateReport:(id)sender;
- (IBAction) nearButtonPressed:(id)sender;
- (IBAction) farButtonPressed:(id)sender;
- (IBAction) triggerEmailButton:(id)sender;
- (IBAction) triggerPriorityButton:(id)sender;
- (IBAction) onPickerHolder:(id)sender;

- (void)launchImagePicker;

@end
