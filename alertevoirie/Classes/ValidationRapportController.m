//
//  ValidationRapportController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ValidationRapportController.h"
#import "CategorieController.h"
#import "LieuIncidentController.h"
#import "InfoVoirieAppDelegate.h"

@implementation ValidationRapportController
@synthesize mImageFar;
@synthesize mImageClose;
@synthesize mLabelParentCategory;
@synthesize mLabelCategory;
@synthesize mLabelAddressStreet;
@synthesize mLabelAddressCity;
@synthesize mArrowViewController;
@synthesize mImagePickerController;
@synthesize mIncidentCreated;

#pragma mark -

- (id)initWithIncident:(IncidentObj *)_incident
{
	self = [super initWithNibName:@"ValidationRapportController" bundle:nil];
	if (self)
	{
		mIncidentCreated = [_incident retain];
	}
	return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	mScrollView.contentSize = CGSizeMake(320, 545);
	mScrollView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0);
	
	mButtonValidate.enabled = NO;
	
	UIButton *cancelButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 74, 44)];
	[cancelButtonView setImage:[UIImage imageNamed:@"hdr_btn_annuler_off.png"] forState:UIControlStateNormal];
	[cancelButtonView setImage:[UIImage imageNamed:@"hdr_btn_annuler_on.png"] forState:UIControlStateHighlighted];
	[cancelButtonView addTarget:self action:@selector(cancelReport:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButtonView];
	[self.navigationItem setRightBarButtonItem:cancelButton];
	[cancelButtonView release];
	[cancelButton release];
	
	UIBarButtonItem *previous = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(returnToPreviousView:)];
	self.navigationItem.leftBarButtonItem = previous;
	[previous release];
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:NSLocalizedString(@"new_report_navbar_title", nil)];
	[self.navigationItem setTitleView:label];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	mLoadingView.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:mLoadingView];
	[self showLoadingView:NO];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(returnToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
	
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[InfoVoirieContext sharedInfoVoirieContext].mCreatingNewReport = YES;
	
	NSLog(@"%@", mIncidentCreated);
	
	NSArray* laddress = [[mIncidentCreated maddress] componentsSeparatedByString:@"\n"];
	
	mLabelAddressStreet.text = [laddress objectAtIndex:0];
	mLabelAddressCity.text = [laddress objectAtIndex:1];
	
	NSDictionary* lDic = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
						  objectForKey:[NSString stringWithFormat:@"%d", mIncidentCreated.mcategory]];
	//NSLog(@"%d", mIncidentCreated.mcategory);
	//NSLog(@"%@", lDic);
	mLabelCategory.text = [lDic objectForKey:@"name"];
	mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mLabelCategory.text];
	
	NSNumber *parentID = [lDic objectForKey:@"parent_id"];
	mLabelParentCategory.text = [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
								  objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"name"];
	mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mLabelParentCategory.text];
	
	NSString* gdParentID = [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
							 objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"parent_id"];
	NSDictionary* gdParent = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory] objectForKey:gdParentID];
	if (gdParent != nil)
	{
		NSString* gdParentString = [gdParent objectForKey:@"name"];
		mLabelCategory.text = [NSString stringWithFormat:@"%@ %@", mLabelParentCategory.text, [lDic objectForKey:@"name"]];
		mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mLabelCategory.text];
		mLabelParentCategory.text = gdParentString;
		mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mLabelParentCategory.text];
	}
	
	if ([mLabelParentCategory.text length] == 0)
	{
		mLabelParentCategory.text = mLabelCategory.text;
		mLabelCategory.text = @"";
	}
	
	if (mImageFar != nil)
	{
		NSLog(@"%s image far", __PRETTY_FUNCTION__);
		mImageViewFar.image = mImageFar;
		mCameraFar.hidden = YES;
		mLabelFarPhoto.hidden = YES;
		[mIconFar setImage:[UIImage imageNamed:@"icn_pen.png"]];
	}
	
	if (mImageClose != nil)
	{
		NSLog(@"%s image close", __PRETTY_FUNCTION__);
		mImageViewNear.image = mImageClose;
		mCameraNear.hidden = YES;
		mLabelNearPhoto.hidden = YES;
		[mIconNear setImage:[UIImage imageNamed:@"icn_pen.png"]];
	}
}

- (void) showLoadingView:(BOOL)show
{
	mLoadingView.hidden = !show;
}

#pragma mark -
#pragma mark Actions
- (IBAction) whereButtonPressed:(id)sender
{
	LieuIncidentController *nextController = [[LieuIncidentController alloc] initWithViewController:self];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}

- (IBAction) categoryButtonPressed:(id)sender
{
	CategorieController *nextController = [[CategorieController alloc] initWithViewController:self];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}

- (IBAction) touchDownButton:(id)sender
{
	UIButton *button = (UIButton *)sender;
	if (button.tag == kWhereButtonTag)
	{
		[mLabelWhere setTextColor:[UIColor whiteColor]];
	}
	else if(button.tag == kCategoryButtonTag)
	{
		[mLabelParentCategory setTextColor:[UIColor whiteColor]];
	}
}

- (IBAction) touchUpButton:(id)sender
{
	UIButton *button = (UIButton *)sender;
	if (button.tag == kWhereButtonTag)
	{
		[mLabelWhere setTextColor:[[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor]];
	}
	else if(button.tag == kCategoryButtonTag)
	{
		[mLabelParentCategory setTextColor:[[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor]];
	}
}

- (IBAction) returnToPreviousView:(id)sender
{
	if (mImageFar != nil || mImageClose != nil)
	{
		UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"back_while_editing_title", nil) message:NSLocalizedString(@"back_while_editing_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"continue", nil), nil];
		lAlertTmp.tag = kAlertViewReturnWithoutSave;
		[lAlertTmp show];
		[lAlertTmp release];
	}
	else if (mLoadingView.hidden == NO)
	{
		UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"report_is_sending_title", nil) message:NSLocalizedString(@"report_is_sending_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		lAlertTmp.tag = kAlertViewReturnWithoutSave;
		[lAlertTmp show];
		[lAlertTmp release];
	}
	else {
		[self.navigationController popViewControllerAnimated:YES];
		[InfoVoirieContext sharedInfoVoirieContext].mCreatingNewReport = NO;
	}
}

- (IBAction) cancelReport:(id)sender
{
	if (mLoadingView.hidden == NO)
	{
		UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"report_is_sending_title", nil) message:NSLocalizedString(@"report_is_sending_invalidate_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		lAlertTmp.tag = kAlertViewReturnWithoutSave;
		[lAlertTmp show];
		[lAlertTmp release];
	}
	else
	{
		UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stop_redaction_title", nil) message:NSLocalizedString(@"stop_redaction_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"stop_redaction_confirm", nil), nil];
		lAlertTmp.tag = kAlertViewCancelReport;
		[lAlertTmp show];
		[lAlertTmp release];
	}
}

- (IBAction) validateReport:(id)sender
{	
	if ([mLabelDescription.text length] <= 0 || [mLabelDescription.text isEqualToString:NSLocalizedString(@"comment_needed", nil)])
	{
		UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"information", nil) message:NSLocalizedString(@"add_description_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[lAlertView show];
		[lAlertView release];
	}
	else
	{
		NSString* laddress = [mIncidentCreated.maddress stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
		laddress = [laddress stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
		mIncidentCreated.maddress = laddress;
		mIncidentCreated.mdescriptive = mLabelDescription.text;
		
		SaveIncident * lsaveIncident = [[SaveIncident alloc] initWithDelegate:self];
		[lsaveIncident generateSaveForIncident:mIncidentCreated];
		[lsaveIncident release];
		[mScrollView setUserInteractionEnabled:NO];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.navigationItem.leftBarButtonItem.enabled = NO;
		
		[self showLoadingView:YES];
	}
}

- (IBAction) descriptionButtonPressed:(id)sender
{
	mTypeImagePicked = kImagePickerOverView;
	NSString* commentString = nil;
	if ([mLabelDescription.text isEqualToString:NSLocalizedString(@"comment_needed", nil)])
	{
		commentString = @"";
	}
	else {
		commentString = mLabelDescription.text;
	}
	
	CommentaireController *comment = [[CommentaireController alloc] initWithDelegate:self andComment:commentString];
	[self.navigationController pushViewController:comment animated:YES];
	[comment release];
}

- (IBAction) nearButtonPressed:(id)sender
{
	mTypeImagePicked = kImagePickerNearView;
	// Set up the image picker controller and add it to the view
	[self launchImagePicker];
}

- (IBAction) farButtonPressed:(id)sender
{
	mTypeImagePicked = kImagePickerOverView;
	// Set up the image picker controller and add it to the view
	[self launchImagePicker];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

- (void)launchImagePicker
{	
	if(mImagePickerController == nil)
	{
		mImagePickerController = [[UIImagePickerController alloc] init];
		mImagePickerController.delegate = self;
		mImagePickerController.allowsEditing = NO;
		mImagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"photo_action_sheet_source_choice", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"photo_action_sheet_choose_library", nil), NSLocalizedString(@"photo_action_sheet_choose_camera", nil), nil];
		[actionSheet showInView:[(InfoVoirieAppDelegate*)[[UIApplication sharedApplication] delegate] window]];
		[actionSheet release];
		//mImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else
	{
		mImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = YES;
		[self presentModalViewController:mImagePickerController animated:YES];
		[mImagePickerController release];
		mImagePickerController = nil;
	}
}

#pragma mark -
#pragma mark Memory Management Methods
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
	
	mScrollView = nil;
	mImageViewFar = nil;
	mCameraFar = nil;
	mIconFar = nil;
	mImageViewNear = nil;
	mCameraNear = nil;
	mIconNear = nil;
	mLabelDescription = nil;
	mButtonDescription = nil;
	mImageViewDescription = nil;
	mButtonValidate = nil;
	mLabelFarPhoto = nil;
	mLabelNearPhoto = nil;
	
	self.mLabelCategory = nil;
	self.mLabelParentCategory = nil;
	self.mLabelAddressCity = nil;
	self.mLabelAddressStreet = nil;
}

- (void)dealloc
{	
	[mImageFar release];
	[mImageClose release];
	[mScrollView release];
	[mImageViewFar release];
	[mCameraFar release];
	[mIconFar release];
	[mImageViewNear release];
	[mCameraNear release];
	[mIconNear release];
	[mLabelDescription release];
	[mButtonDescription release];
	[mImageViewDescription release];
	[mLabelCategory release];
	[mLabelParentCategory release];
	[mLabelAddressStreet release];
	[mLabelAddressCity release];
	[mButtonValidate release];
	[mLabelFarPhoto release];
	[mLabelNearPhoto release];
	[super dealloc];
}

#pragma mark -
#pragma mark Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != alertView.cancelButtonIndex)
	{
		switch (alertView.tag)
		{
			case kAlertViewCancelReport:
				[self.navigationController popToRootViewControllerAnimated:YES];
				[InfoVoirieContext sharedInfoVoirieContext].mCreatingNewReport = NO;
				break;
			case kAlertViewReturnWithoutSave:
				[self.navigationController popViewControllerAnimated:YES];
				[InfoVoirieContext sharedInfoVoirieContext].mCreatingNewReport = NO;
				break;
			case kAlertViewSavedIncident:
			case kAlertViewPhotoNotSaved:
				[self showLoadingView:NO];
				[self.navigationController popToRootViewControllerAnimated:YES];
				[InfoVoirieContext sharedInfoVoirieContext].mCreatingNewReport = NO;
				break;
			default:
				break;
		}
	}
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (buttonIndex == kActionSheetLibrary)
		{
			mImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = YES;
			[self presentModalViewController:mImagePickerController animated:YES];
			[mImagePickerController release];
			mImagePickerController = nil;
		}
		else if (buttonIndex == kActionSheetPhoto)
		{
			mImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = NO;
			[self presentModalViewController:mImagePickerController animated:YES];
			[mImagePickerController release];
			mImagePickerController = nil;
		}
	}
}

#pragma mark -
#pragma mark Image View Controller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = NO;
	[picker dismissModalViewControllerAnimated:NO];
	
	if(mTypeImagePicked == kImagePickerOverView)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
		
		/*CGSize newSize = CGSizeMake(320, 480);
		UIGraphicsBeginImageContext( newSize );
		[limage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		//image is the original UIImage
		limage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();*/
		
		ArrowViewController *newArrowViewController = [[ArrowViewController alloc] initWithBackgroundImage:image andDelegate:self];
		
		[self presentModalViewController:newArrowViewController animated:NO];
		[newArrowViewController release];
	}
	else
	{
		NSInteger newWidth = image.size.width * 480 / image.size.height;
		CGSize newSize = CGSizeMake(newWidth, 480);
		UIGraphicsBeginImageContext( newSize );
		[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		CGRect rect = CGRectMake((tmpImage.size.width - 320)/2., (tmpImage.size.height - 480)/2., 320, 480);
		CGImageRef imageRef = CGImageCreateWithImageInRect(tmpImage.CGImage, rect);
		
		self.mImageClose = [UIImage imageWithCGImage:imageRef];
		mCameraNear.hidden = YES;
		mLabelNearPhoto.hidden = YES;
		[mIconNear setImage:[UIImage imageNamed:@"icn_pen.png"]];
		
		CGImageRelease(imageRef);
		
		[self didReceiveComment:@""];
	}
}

#pragma mark -
#pragma mark Final Image Delegate Methods
- (void)didReceiveImage:(UIImage *)_image fromController:(UIViewController *)_controller
{
	if (_image != nil)
	{
		NSLog(@"%s", __PRETTY_FUNCTION__);
		
		self.mImageFar = _image;
		[mImageViewFar setImage:(self.mImageFar)];
		mCameraFar.hidden = YES;
		mLabelFarPhoto.hidden = YES;
		[mIconFar setImage:[UIImage imageNamed:@"icn_pen.png"]];
		
		CommentaireController *nextController = [[CommentaireController alloc] initWithDelegate:self];
		[self.navigationController pushViewController:nextController animated:NO];
		[nextController release];
	}
	[_controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Comment Delegate Methods
- (void)didReceiveComment:(NSString*)_comment
{
	if(mTypeImagePicked == kImagePickerOverView)
	{
		mButtonValidate.enabled = YES;
		if (_comment != nil && [_comment length] != 0)
		{
			mLabelDescription.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
			mLabelDescription.text = _comment;
		}
		else
		{
			mLabelDescription.textColor = [UIColor redColor];
			mLabelDescription.text = NSLocalizedString(@"comment_needed", nil);;
		}

		mLabelDescription.hidden = NO;
		mButtonDescription.hidden = NO;
		mImageViewDescription.hidden = NO;
		mScrollView.contentInset = UIEdgeInsetsZero;
		mScrollView.contentOffset = CGPointMake(0, 0);
	}
	else
	{
		[mImageViewNear setImage:(self.mImageClose)];
		[mIconNear setImage:[UIImage imageNamed:@"icn_pen.png"]];
	}
	mTypeImagePicked = -1;
}

#pragma mark -
#pragma mark Sending Picture Delegate Methods
- (void)didSendPictureOk:(BOOL)_success
{
	//TODO: when only one of two pictures successfully sent
	mCurrentConfirmImagesSent++;
	if (_success == YES)
	{
		mCurrentSuccessOnImagesSent++;
	}
	if(mCurrentConfirmImagesSent == mImagesSent)
	{
		if (mCurrentSuccessOnImagesSent == mImagesSent)
		{
			UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"information", nil) message:NSLocalizedString(@"report_send_message", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
			lAlertTmp.tag = kAlertViewSavedIncident;
			[lAlertTmp show];
			[lAlertTmp release];
		}
		else
		{
			NSString* message;
			if (mCurrentSuccessOnImagesSent == 1)
			{
				message = NSLocalizedString(@"one_photo_not_sent", nil);
			}
			else
			{
				message = NSLocalizedString(@"photos_not_sent", nil);
			}
			UIAlertView *lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:message delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
			lAlertTmp.tag = kAlertViewPhotoNotSaved;
			[lAlertTmp show];
			[lAlertTmp release];
		}
	}
}

#pragma mark -
#pragma mark Update Form Picture Delegate Methods
-(void) updateImageFar:(UIImage*) _Image
{
	[mImageViewFar setImage:_Image];
}

-(void) updateImageNear:(UIImage *)_Image
{
	[mImageViewNear setImage:_Image];
}

#pragma mark -
#pragma mark Save Incident Delegate Methods
-(void) didSaveIncident:(NSInteger)_incidentId
{
	if (_incidentId < 0)
	{
		UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error_title", nil) message:NSLocalizedString(@"report_not_sent", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[lAlert show];
		[lAlert release];
		
		[self showLoadingView:NO];
		[mScrollView setUserInteractionEnabled:YES];
		self.navigationItem.leftBarButtonItem.enabled = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		return;
	}
	
	mCurrentConfirmImagesSent = 0;
	mCurrentSuccessOnImagesSent = 0;
	mIncidentCreated.mid = _incidentId;
	
	SendIncidentPictures * lsendIncidentPicture = [[SendIncidentPictures alloc] initWithDelegate:self incidentCreation:YES];
	[lsendIncidentPicture generateSendPicture:[NSNumber numberWithInteger:(mIncidentCreated.mid)] photo:mImageFar type:@"far" comment:[mLabelDescription text]];
	[lsendIncidentPicture release];
	mImagesSent = 1;
	if(mImageClose != nil)
	{
		mImagesSent = 2;
		SendIncidentPictures * lsendIncidentPicture2 = [[SendIncidentPictures alloc] initWithDelegate:self incidentCreation:YES];
		[lsendIncidentPicture2 generateSendPicture:[NSNumber numberWithInteger:(mIncidentCreated.mid)] photo:mImageClose type:@"close" comment:@""];
		[lsendIncidentPicture2 release];
	}
}

@end
