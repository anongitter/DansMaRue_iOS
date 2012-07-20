//
//  CommentaireController.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "CommentaireController.h"

@implementation CommentaireController
@synthesize mTextField;
@synthesize mLabelNumCharRemaining;
@synthesize mTextComment;
@synthesize mOriginalComment;
@synthesize mValidateButton;
@synthesize mCommentDelegate;

#pragma mark -

- (id)initWithDelegate:(NSObject<commentDelegate> *) _commentDelegate
{
	self = [super initWithNibName:@"CommentaireController" bundle:nil];
	if (self)
	{
		self.mCommentDelegate = _commentDelegate;
		self.mTextComment = nil;
		self.mOriginalComment = nil;
	}
	return self;
}

- (id)initWithDelegate:(NSObject<commentDelegate> *) _commentDelegate andComment:(NSString*)_comment
{
	NSLog(@"init");
	self = [super initWithNibName:@"CommentaireController" bundle:nil];
	if (self)
	{
		self.mCommentDelegate = _commentDelegate;
		self.mTextComment = _comment;
		self.mOriginalComment = _comment;
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	mValidateButton.enabled = NO;
	
	UILabel *label = [InfoVoirieContext createNavBarUILabelWithTitle:@"Votre Commentaire"];
	[self.navigationItem setTitleView:label];
	
	UIButton *buttonView = [InfoVoirieContext createNavBarBackButton];
	[buttonView addTarget:self action:@selector(triggerReturnButton:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	[self.navigationItem setLeftBarButtonItem:returnButton];
	[returnButton release];
	
	if (mTextComment != nil)
	{
		mTextField.text = mTextComment;
	}
	
	[mTextField becomeFirstResponder];
}

#pragma mark - Actions
-(IBAction) textFieldDoneEditing:(id)sender
{
	/*[sender resignFirstResponder];
	if (![mTextField.text isEqualToString:@""])
	{
		mValidateButton.enabled = YES;
	}
	 */
	[mCommentDelegate didReceiveComment:mTextField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) backgroundTap:(id)sender
{
	/*[mTextField resignFirstResponder];
	if (![mTextField.text isEqualToString:@""])
	{
		mValidateButton.enabled = YES;
	}
	*/
}

- (IBAction)triggerReturnButton:(id)sender
{
	if (mOriginalComment != nil) {
		[mCommentDelegate didReceiveComment:mOriginalComment];
	}
	else {
		[mCommentDelegate didReceiveComment:@""];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}


-(IBAction) validateButtonPressed:(id)sender
{
	[mCommentDelegate didReceiveComment:mTextField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate Methods
- (BOOL)textField:(UITextField *)textField
	shouldChangeCharactersInRange:(NSRange)range
	replacementString:(NSString*)string
{
	NSUInteger stringLength;
	if(range.location == [textField.text length])
	{	
		stringLength = [string length];
	}
	else
	{
		stringLength = -1;
	}
	
	if([string isEqualToString:@"\n"])
	{
		NSInteger charRemaining = kNumCharactersMax - [textField.text length];
		mLabelNumCharRemaining.text = [NSString stringWithFormat:@"%d %@", charRemaining, NSLocalizedString(@"remaining_char", nil)];
		[textField resignFirstResponder];
		[mCommentDelegate didReceiveComment:mTextField.text];
		[self.navigationController popViewControllerAnimated:YES];
		return NO;
	}
	NSInteger charRemaining = kNumCharactersMax - ([textField.text length] + stringLength);
	if(charRemaining < 0)
	{
		if(range.location == [textField.text length])
			return NO;
		return YES;
	}
	mLabelNumCharRemaining.text = [NSString stringWithFormat:@"%d %@", charRemaining, NSLocalizedString(@"remaining_char", nil)];
	return YES;
}

#pragma mark - Memory Management Methods

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
}


- (void)dealloc
{
    [super dealloc];
}

@end
