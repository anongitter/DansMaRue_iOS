//
//  FicheIncidentController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "FicheIncidentController.h"
#import "incidentObj.h"
#import "UpdateIncident.h"
#import "ChangeIncident.h"
#import "SendIncidentPictures.h"
#import "ArrowViewController.h"
#import "CategorieController.h"
#import "LieuIncidentController.h"
#import "CommentaireController.h"
#import "InfoVoirieAppDelegate.h"
#import "ImageManager.h"
#import "UpdateCell.h"
#import "InfoVoirieContext.h"


@implementation FicheIncidentController
@synthesize mScrollView;
@synthesize mTableView;
@synthesize mUpperElementsView;
@synthesize mButtonsView;
@synthesize mLabelDescription;
@synthesize mLabelDate;
@synthesize mLabelWhere;
@synthesize mLabelAddress;
@synthesize mLabelParentCategory;
@synthesize mLabelCategory;
@synthesize mLabelNumberConfirmations;
@synthesize mButtonAddPhoto;
@synthesize mButtonInvalidateIncident;
@synthesize mButtonIncidentResolved;
@synthesize mButtonConfirmIncident;
@synthesize mImageFar;
@synthesize mImageNear;
@synthesize mIncident;
@synthesize mTypeImagePicked;
@synthesize mArrowViewController;
@synthesize mImagePickerController;
@synthesize mFinalImage;
@synthesize mArrayUpdate;
@synthesize mUpdateImages;
@synthesize mPicker;
@synthesize mLabelPriority;

- (id)initWithIncident:(IncidentObj	*)_incident
{
	self = [super initWithNibName:nil bundle:nil];
	if(self)
	{
		self.mIncident = _incident;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	//mScrollView.contentSize = CGSizeMake(320, 700);
	
	mArrayUpdate = [[NSMutableArray alloc] init];
	//mUpdateImages = [[NSMutableDictionary alloc] init];
	
	mGetUpdates = [[GetUpdates alloc] initWithUpdateDelegate:self];
	[mGetUpdates generateUpdatesForIncident:[NSNumber numberWithInteger:mIncident.mid]];
	
	self.mLabelDescription.text = [InfoVoirieContext capitalisedFirstLetter:mIncident.mdescriptive];
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:(self.mLabelDescription.text)];
	[self.navigationItem setTitleView:label];
	
	self.mLabelAddress.text = [InfoVoirieContext capitalisedFirstLetter:[mIncident maddress]];
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:kDateFormat];
	
	NSDate *formatterDate = [inputFormatter dateFromString:mIncident.mdate];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE d MMMM '-' HH:mm"];
	[dateFormatter setLocale:locale];
	NSString* newDateString = [dateFormatter stringFromDate:formatterDate];
	
	self.mLabelDate.text = [InfoVoirieContext capitalisedFirstLetter:newDateString];
	
	//[NSThread detachNewThreadSelector:@selector(threadLoadingImageFar:) toTarget:[FicheIncidentController class] withObject:self];
	//[NSThread detachNewThreadSelector:@selector(threadLoadingImageClose:) toTarget:[FicheIncidentController class] withObject:self];
	
	if ([mIncident.mpicturesFar count] > 0)
		[[ImageManager sharedImageManager] getImageNamed:[mIncident.mpicturesFar objectAtIndex:0] withDelegate:mImageFar];
	
	if ([mIncident.mpicturesClose count] > 0)
		[[ImageManager sharedImageManager] getImageNamed:[mIncident.mpicturesClose objectAtIndex:0] withDelegate:mImageNear];
	
	NSMutableDictionary* lDic = [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:[NSString stringWithFormat:@"%d", (mIncident.mcategory)]]; 
	NSNumber * parentID = [lDic valueForKey:@"parent_id"];
	NSString* nameString = [lDic valueForKey:@"name"];
	lDic = [[InfoVoirieContext sharedInfoVoirieContext].mCategory objectForKey:parentID];
	NSString* parentString = [lDic valueForKey:@"name"];
	mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:parentString];
	mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:nameString];
	
	NSString* gdParentID = [[[[InfoVoirieContext sharedInfoVoirieContext] mCategory]
							 objectForKey:[NSString stringWithFormat:@"%d", [parentID integerValue]]] objectForKey:@"parent_id"];
	NSDictionary* gdParent = [[[InfoVoirieContext sharedInfoVoirieContext] mCategory] objectForKey:gdParentID];
	if (gdParent != nil) {
		NSString* gdParentString = [gdParent objectForKey:@"name"];
		mLabelCategory.text = [NSString stringWithFormat:@"%@ %@", parentString, nameString];
		mLabelCategory.text = [InfoVoirieContext capitalisedFirstLetter:mLabelCategory.text];
		mLabelParentCategory.text = gdParentString;
		mLabelParentCategory.text = [InfoVoirieContext capitalisedFirstLetter:mLabelParentCategory.text];
	}
	
	if ([mLabelParentCategory.text length] == 0)
	{
		mLabelParentCategory.text = mLabelCategory.text;
		mLabelCategory.text = @"";
	}
	
	mLabelNumberConfirmations.text = [self createConfirmationText];
	
	// Init Loading View
	mLoadingView = [InfoVoirieContext createLoadingView];
	mLoadingView.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:mLoadingView];
	[self showLoadingView:YES];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(triggerReturnButton:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
	
	mTypeImagePicked = -1;
	mFinalImage = nil;
	[locale release];
	[inputFormatter release];
	[dateFormatter release];
    
    incidentLabels = [[NSArray alloc] initWithObjects:@"Dangereux", @"Gênant", @"Mineur", nil];
    self.mLabelPriority.text = [incidentLabels objectAtIndex:(mIncident.mPriorityId-1)];
}

- (NSString*)createConfirmationText
{
	NSString* confirmationsText;
	switch (mIncident.mconfirms) {
		case 0:
			confirmationsText = [NSString stringWithString:NSLocalizedString(@"no_incident_confirmation", nil)];
			break;
		case 1:
			confirmationsText = [NSString stringWithString:NSLocalizedString(@"one_incident_confirmation", nil)];
			break;
		default:
			confirmationsText = [NSString stringWithFormat:@"%d %@", mIncident.mconfirms, NSLocalizedString(@"many_incident_confirmations", nil)];
			break;
	}
	return confirmationsText;
}

- (void) changeIncident
{
	ChangeIncident *request = [[ChangeIncident alloc] initWithDelegate:self];
	//[request generateChangeForIncident:[NSNumber numberWithInteger:mIncident.mid] newCategory:[NSNumber numberWithInteger:mIncident.mcategory] newAddress:[mIncident maddress]];
	[request generateChangeForIncident:mIncident];
	[request release];
	[self showLoadingView:YES];
}

- (void) showLoadingView:(BOOL)show
{
	mLoadingView.hidden = !show;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}



#pragma mark -
#pragma mark Actions



- (IBAction)triggerReturnButton:(id)sender
{
	[mGetUpdates setUpdateDelegate:nil];
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)touchDownButton:(id)sender
{
	UIButton* button = (UIButton *)sender;
    
    switch (button.tag)
    {
        case whereButtonTag:
        {
            mLabelWhere.textColor = [UIColor whiteColor];
            mLabelAddress.textColor = [UIColor whiteColor];
            break;
        }
        case categoryButtonTag:
        {
            mLabelParentCategory.textColor = [UIColor whiteColor];
            mLabelCategory.textColor = [UIColor whiteColor];
            break;
        }
        case priorityButtonTag:
        {
            mLabelPriority.textColor = [UIColor whiteColor];
            _mPriorityButtonLabel.textColor = [UIColor whiteColor];
            break;
        }
        default:
            break;
    }
}


- (IBAction)touchUpButton:(id)sender
{
	UIButton *button = (UIButton *)sender;
    
    switch (button.tag)
    {
        case whereButtonTag:
        {
            mLabelWhere.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
            mLabelAddress.textColor = [UIColor blackColor];
            break;
        }
        case categoryButtonTag:
        {
            mLabelParentCategory.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
            mLabelCategory.textColor = [UIColor blackColor];
            break;
        }
        case priorityButtonTag:
        {
            _mPriorityButtonLabel.textColor = [[InfoVoirieContext sharedInfoVoirieContext] mTextBlueColor];
            mLabelPriority.textColor = [UIColor blackColor];
            break;
        }
        default:
            break;
    }
}


/*
- (BOOL)testAuthenticationToken
{
#ifdef kMarseilleTownhallVersion
	if ([[InfoVoirieContext sharedInfoVoirieContext] mAuthenticationToken] == nil)
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"information", nil) message:NSLocalizedString(@"function_require_connexion", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		return NO;
	}
#endif
	
	return YES;
}
*/
- (IBAction)triggerWhereButton:(id)sender
{
	/*if ([self testAuthenticationToken] == NO)
	{
		return;
	}*/

	LieuIncidentController *nextController = [[LieuIncidentController alloc] initWithFicheViewController:self];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}

- (IBAction)triggerCategoryButton:(id)sender
{
	/*if ([self testAuthenticationToken] == NO)
	{
		return;
	}*/
	CategorieController *nextController = [[CategorieController alloc] initWithFicheViewController:self];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController release];
}

- (IBAction)triggerPriorityButton:(id)sender
{
    mPickerHolderView.hidden = FALSE;
}

- (IBAction)triggerInvalidateIncidentButton:(id)sender
{
	/*if ([self testAuthenticationToken] == NO)
	{
		return;
	}*/
	
	UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalidate_incident_title", nil) message:NSLocalizedString(@"invalidate_incident_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"confirm", nil), nil];
	lAlertTmp.tag = kAlertViewInvalidateTag;
	[lAlertTmp show];
	[lAlertTmp release];
}

- (IBAction)triggerIncidentResolvedButton:(id)sender
{
	/*if ([self testAuthenticationToken] == NO)
	{
		return;
	}*/
	
	UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"resolved_incident_title", nil) message:NSLocalizedString(@"resolved_incident_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
	lAlertTmp.tag = kAlertViewResolvedTag;
	[lAlertTmp show];
	[lAlertTmp release];
}

- (IBAction)triggerConfirmIncidentButton:(id)sender
{
	/*if ([self testAuthenticationToken] == NO)
	{
		return;
	}*/
	
	UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_incident_title", nil) message:NSLocalizedString(@"confirm_incident_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"confirm", nil), nil];
	lAlertTmp.tag = kAlertViewConfirmTag;
	[lAlertTmp show];
	[lAlertTmp release];
}

- (IBAction) triggerAddPhotoButton:(id)sender
{
	/*if ([self testAuthenticationToken] == NO)
	{
		return;
	}*/
	
	UIActionSheet *lactionSheet = [[UIActionSheet alloc]
								   initWithTitle:nil
								   delegate:self
								   cancelButtonTitle:NSLocalizedString(@"photo_action_sheet_cancel", nil)
								   destructiveButtonTitle:nil
								   otherButtonTitles:NSLocalizedString(@"photo_action_sheet_far", nil), NSLocalizedString(@"photo_action_sheet_close", nil), nil];
	lactionSheet.tag = kActionSheetPhotoType;
	[lactionSheet showInView:[(InfoVoirieAppDelegate*)[[UIApplication sharedApplication] delegate] window]];
	[lactionSheet release];
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
    [self setMPriorityButtonLabel:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.mScrollView = nil;
	self.mButtonAddPhoto = nil;
	self.mButtonInvalidateIncident = nil;
	self.mButtonIncidentResolved = nil;
	self.mButtonConfirmIncident = nil;
	self.mTableView = nil;
	self.mButtonsView = nil;
	self.mUpperElementsView = nil;
}


- (void)dealloc
{
	//[mScrollView release];
	[mTableView release];
	[mButtonsView release];
	[mUpperElementsView release];
	[mLabelDescription release];
	[mLabelDate release];
	[mLabelAddress release];
	[mLabelParentCategory release];
	[mLabelCategory release];
	[mLabelNumberConfirmations release];
	[mButtonAddPhoto release];
	[mButtonInvalidateIncident release];
	[mButtonIncidentResolved release];
	[mButtonConfirmIncident release];
	[mGetUpdates release];
	[mUpdateImages release];
    [mPicker release];
    [mLabelPriority release];
    [_mPriorityButtonLabel release];
	[super dealloc];
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [incidentLabels count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [incidentLabels objectAtIndex:row];
} 

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    incidentId = (row+1);
    mIncident.mPriorityId = incidentId;
    self.mLabelPriority.text = [incidentLabels objectAtIndex:row];
}

- (IBAction) onPickerHolder:(id)sender{
    mPickerHolderView.hidden = TRUE;
}

#pragma mark -
#pragma mark Table View Data Source Methods
#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// Upper elements view
	if (section == 0) {
		return mUpperElementsView;
	}
	// No header view
	if (section == 2) {
		return nil;
	}
	// Create header bar view with "update" text
	if ([mArrayUpdate count] > 0) {
		CGRect headerRect = CGRectMake(7, 0, 306, kHeaderUpdateHeight);
		
		UIView *headerView = [[[UIView alloc] initWithFrame:headerRect] autorelease];
		UIImage *headerImage = [UIImage imageNamed:@"bar_blue.png"];
		UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headerRect];
		[headerImageView setImage:headerImage];
		[headerImageView setOpaque:NO];
		
		CGRect labelRect = CGRectMake(20, -2, 280, kHeaderUpdateHeight);
		UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
		label.textColor = [UIColor whiteColor];
		// agreement in number
		if ([mArrayUpdate count] == 1) {
			label.text = NSLocalizedString(@"update", nil);
		}
		else {
			label.text = NSLocalizedString(@"updates", nil);
		}
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:15.0];
		
		[headerView addSubview:headerImageView];
		[headerView addSubview:label];
		
		[headerImageView release];
		[label release];
		
		return headerView;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	// height for Upper Element View
	if (section == 0) {
		return mUpperElementsView.frame.size.height;
	}
	// no header view
	if (section == 2) {
		return 0;
	}
	// height for header bar with "update" text
	return kHeaderUpdateHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	// if update array is empty, there's only one section, so we have to add the lower elements view to it
	if ([mArrayUpdate count] == 0) {
		if (section == 0) {
			return mButtonsView;
		}
	}
	// if update array not empty, set the footer of the 2nd section to the lower elements view 
	if (section == 2) {
		return mButtonsView;
	}
	// no footer elsewhere
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	// if update array is empty, there's only one section, so we have to set the lower elements view height for it
	if ([mArrayUpdate count] == 0) {
		return kFooterHeight;
	}
	// if update array not empty, set the 2nd section footer's view height
	if (section == 2) {
		return kFooterHeight;
	}
	// no footer elsewhere
	return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return kCellFicheHeight;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	// no cell in section 0 an 2
	if (section == 0 || section == 2) {
		return 0;
	}
	// section 1 : 
	return [mArrayUpdate count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// if update array is empty, there's only one section
	if ([mArrayUpdate count] == 0)
	{
		return 1;
	}
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString* myUpdateCells = @"UpdateCellIdentifier";
	
	if (indexPath.section == 1) {
		UpdateCell *cell = (UpdateCell *)[tableView dequeueReusableCellWithIdentifier:myUpdateCells];
		if(cell == nil)
		{
			NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"UpdateCell" owner:self options:nil];
			
			for(id oneObject in nib)
				if([oneObject isKindOfClass:[UpdateCell class]])
					cell = (UpdateCell *)oneObject;
		}
		
		[cell updateWithInfo:[mArrayUpdate objectAtIndex:indexPath.row]];
		
		return cell;
	}
	
	return nil;
}

/*
#pragma mark -
#pragma mark Thread Load Image Methods
// create a thread to load the far image
+ (void)threadLoadingImageFar:(FicheIncidentController*)_fic
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if([_fic.mIncident.mpicturesFar count] > 0)
	{
		UIImage *limageFar = [self LoadImage:[_fic.mIncident.mpicturesFar objectAtIndex:0] andURL:[_fic.mIncident.mpicturesFar objectAtIndex:0]];
		if(limageFar != nil)
		{
			if([limageFar isKindOfClass:[UIImage class]])
			{
				[_fic.mImageFar setContentMode:UIViewContentModeScaleAspectFit];
				[_fic.mImageFar setImage:limageFar];
			}
				
		}
	}
	[pool release];
}

// create a thread to load the near image
+ (void)threadLoadingImageClose:(FicheIncidentController*)_fic
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if([_fic.mIncident.mpicturesClose count] > 0)
	{
		UIImage *limageClose = [self LoadImage:[_fic.mIncident.mpicturesClose objectAtIndex:0] andURL:[_fic.mIncident.mpicturesClose objectAtIndex:0]];
		if(limageClose != nil)
		{
			if([limageClose isKindOfClass:[UIImage class]])
			{
				[_fic.mImageNear setContentMode:UIViewContentModeScaleAspectFit];
				[_fic.mImageNear setImage:limageClose];
			}
				
		}
	}
	[pool release];
}

+ (UIImage*) LoadImage:(NSString*) _fileName andURL:(NSString*) _url
{
    NSString* tempPath = NSTemporaryDirectory(); 
	_fileName = [_fileName stringByReplacingOccurrencesOfString:@":" withString:@""];
    _fileName = [_fileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString* filePath = [tempPath stringByAppendingPathComponent:_fileName];
   
	UIImage * image = [UIImage imageWithContentsOfFile:filePath];
	
    if(image != nil) // Ouverture success
    {
        return image;     
    }
    else
    {
        NSURL *url = [NSURL URLWithString:_url];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:filePath atomically:YES];
        return [UIImage imageWithData:data];
    }
}
*/

#pragma mark -
#pragma mark Action Sheet Delegate Methods
- (void)actionSheet:(UIActionSheet *) actionSheet 
willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// Action sheet allows user to add far or near photos
	if(buttonIndex != [actionSheet cancelButtonIndex])
	{
		if (actionSheet.tag == kActionSheetPhotoSource)
		{
			UIImagePickerControllerSourceType sourceType;
			if (buttonIndex == 0)
			{
				sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			}
			else
			{
				sourceType = UIImagePickerControllerSourceTypeCamera;
			}
				
			// Set up the image picker controller and add it to the view
			if(mImagePickerController == nil)
			{
				mImagePickerController = [[UIImagePickerController alloc] init];
				mImagePickerController.delegate = self;
				mImagePickerController.allowsEditing = NO;
				mImagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				mImagePickerController.sourceType = sourceType;
			}
			// show the image picker controller
			[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = YES;
			[self presentModalViewController:mImagePickerController animated:YES];
			[mImagePickerController release];
			mImagePickerController = nil;
		}
		if (actionSheet.tag == kActionSheetPhotoType)
		{
			if(buttonIndex == 0)		// far button pushed
			{
				mTypeImagePicked = kImagePickerOverView;
			}
			else						// near button pushed
			{
				mTypeImagePicked = kImagePickerNearView;
			}
			
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"photo_action_sheet_source_choice", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"photo_action_sheet_choose_library", nil), NSLocalizedString(@"photo_action_sheet_choose_camera", nil), nil];
				actionSheet.tag = kActionSheetPhotoSource;
				[actionSheet showInView:[(InfoVoirieAppDelegate*)[[UIApplication sharedApplication] delegate] window]];
				[actionSheet release];
			}
			else
			{
				if (mImagePickerController == nil)
				{
					mImagePickerController = [[UIImagePickerController alloc] init];
					mImagePickerController.delegate = self;
					mImagePickerController.allowsEditing = NO;
					mImagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				}
				
				mImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = YES;
				[self presentModalViewController:mImagePickerController animated:YES];
				[mImagePickerController release];
				mImagePickerController = nil;
			}
			
		}
	}
}

#pragma mark -
#pragma mark Image View Controller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	// the image picker controller has his allowsEditing property set to NO
	UIImage *limage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	[InfoVoirieAppDelegate sharedDelegate].mUseStandardNavBar = NO;
	[picker dismissModalViewControllerAnimated:NO];
	
	// Resize the photo
	CGSize newSize = CGSizeMake(320, 480);
	UIGraphicsBeginImageContext( newSize );
	[limage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	//image is the original UIImage
	limage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Overview photo
	if(mTypeImagePicked == kImagePickerOverView)
	{
		// hide status bar
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
		// Set the background of ArrowView to limage
		ArrowViewController *newArrowViewController = [[ArrowViewController alloc] initWithBackgroundImage:limage andDelegate:self];
		[self presentModalViewController:newArrowViewController animated:YES];
		[newArrowViewController release];
	}
	else
	{
		self.mFinalImage = limage;
		// no arrow nor comment are necessary 
		[self didReceiveComment:@""];
	}
}

#pragma mark -
#pragma mark Update Incident Delegate Methods 

-(void)didAchieveUpdateFor:(NSString*)status
{
	if([status isEqualToString:kJSONConfirmed])
	{
		[mButtonConfirmIncident setEnabled:YES];
		mIncident.mconfirms += 1;
		[mLabelNumberConfirmations setText:[self createConfirmationText]];
	}
	else if([status isEqualToString:kJSONResolved])
	{
		[mButtonIncidentResolved setEnabled:YES];
		[self.navigationController popToRootViewControllerAnimated:NO];
		[self.tabBarController setSelectedIndex:1];
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	else if([status isEqualToString:kJSONInvalidated])
	{
		[mButtonConfirmIncident setEnabled:NO];
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	else
	{
		NSString* message = @"";
		
		if([status isEqualToString:kJSONDoubleResolved])
		{
			message = NSLocalizedString(@"error_incident_already_resolved", nil);
		}
		else if([status isEqualToString:kJSONDoubleConfirmed])
		{
			message = NSLocalizedString(@"error_incident_already_confirmed", nil);
		}
		else if([status isEqualToString:kJSONDoubleInvalidate])
		{
			message = NSLocalizedString(@"error_incident_already_invalidated", nil);
		}
		
		UIAlertView * lAlertTmp = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[lAlertTmp show];
		[lAlertTmp release];
	}
}

#pragma mark -
#pragma mark Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != alertView.cancelButtonIndex)
	{
		if(alertView.tag == kAlertViewInvalidateTag)
		{
			UpdateIncident * lUpdateIncident = [[UpdateIncident alloc] initWithDelegate:self];
			[lUpdateIncident generateUpdateForIncident:[NSNumber numberWithInteger:(mIncident.mid)] status:kJSONInvalidated];
			[lUpdateIncident release];
			[mButtonInvalidateIncident setEnabled:NO];
		}
		else if(alertView.tag == kAlertViewResolvedTag)
		{
			UpdateIncident * lUpdateIncident = [[UpdateIncident alloc] initWithDelegate:self];
			[lUpdateIncident generateUpdateForIncident:[NSNumber numberWithInteger:(mIncident.mid)] status:kJSONResolved];
			[lUpdateIncident release];
			[mButtonIncidentResolved setEnabled:NO];
		}
		else if(alertView.tag == kAlertViewConfirmTag)
		{
			UpdateIncident * lUpdateIncident = [[UpdateIncident alloc] initWithDelegate:self];
			[lUpdateIncident generateUpdateForIncident:[NSNumber numberWithInteger:(mIncident.mid)] status:kJSONConfirmed];
			[lUpdateIncident release];
			[mButtonConfirmIncident setEnabled:NO];
		}
	}
}

#pragma mark -
#pragma mark Final Image Delegate Methods
- (void)didReceiveImage:(UIImage *)_image fromController:(UIViewController *)_controller
{
	if(_image == nil)
	{
		[_controller dismissModalViewControllerAnimated:YES];
		return;
	}
		
	self.mFinalImage = [UIImage imageWithCGImage:[_image CGImage]];
	if(mFinalImage != nil)
	{
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
	NSString* type = @"";
	if(mTypeImagePicked == kImagePickerOverView)
		type = @"far";
	if(mTypeImagePicked == kImagePickerNearView)
		type = @"close";
	[self showLoadingView:YES];
	
	SendIncidentPictures * lsendIncidentPicture = [[SendIncidentPictures alloc] initWithDelegate:self incidentCreation:NO];
	[lsendIncidentPicture generateSendPicture:[NSNumber numberWithInteger:(mIncident.mid)] photo:mFinalImage type:type comment:_comment];
	[lsendIncidentPicture release];
}

#pragma mark -
#pragma mark Sending Picture Delegate Methods
- (void)didSendPictureOk:(BOOL)_success
{
	if (_success == NO)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error_send_photo_title", nil) message:NSLocalizedString(@"error_send_photo_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
	else
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"success_send_photo_title", nil) message:NSLocalizedString(@"success_send_photo_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	if(mTypeImagePicked == kImagePickerNearView)
	{
		if([mIncident.mpicturesClose count] == 0 && mFinalImage != nil)
		{
			[self.mImageNear setImage:mFinalImage];
		}
	}
	mTypeImagePicked = -1;
	if (mGetUpdates == nil)
	{
		mGetUpdates = [[GetUpdates alloc] initWithUpdateDelegate:self];
	}
	[mGetUpdates generateUpdatesForIncident:[NSNumber numberWithInteger:mIncident.mid]];
	[self showLoadingView:YES];
}

#pragma mark -
#pragma mark Change Incident Delegate Methods
-(void)didAchieveChange:(BOOL)success
{
	if (success == NO)
	{
		UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error_update_title", nil) message:NSLocalizedString(@"error_update_message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
		[lAlert show];
		[lAlert release];
	}
	[self showLoadingView:NO];
}

#pragma mark -
#pragma mark Get Updates Delegate Methods
- (void)didReceiveUpdates:(NSMutableArray*)_updates
{
	[mUpdateImages removeAllObjects];
	[self showLoadingView:NO];
	if (_updates == nil)
	{
		self.mArrayUpdate = [NSArray array];
	}
	else
	{
		self.mArrayUpdate = _updates;
	}
	
	NSMutableArray* removeUpdates = [NSMutableArray array];
	
	for	(NSDictionary* dictionary in mArrayUpdate)
	{
		if ([mIncident mpicturesFar] != nil && [[mIncident mpicturesFar] count] > 0 && [[[mIncident mpicturesFar] objectAtIndex:0] isEqualToString:[dictionary objectForKey:@"photo_url"]])
		{
			[removeUpdates addObject:dictionary];
		}
		if ([mIncident mpicturesClose] != nil && [[mIncident mpicturesClose] count] > 0 && [[[mIncident mpicturesClose] objectAtIndex:0] isEqualToString:[dictionary objectForKey:@"photo_url"]])
		{
			[removeUpdates addObject:dictionary];
		}
	}
	
	[mArrayUpdate removeObjectsInArray:removeUpdates];
	
	[mTableView reloadData];
}

@end
