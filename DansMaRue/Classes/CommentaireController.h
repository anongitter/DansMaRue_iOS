//
//  CommentaireController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commentaireDelegate.h"

#define kNumCharactersMax		140

@interface CommentaireController : UIViewController
 <UITextFieldDelegate>
{
	NSString* mTextComment;
	UILabel *mLabelNumCharRemaining;
	
	UITextField * mTextField;
	
	UIButton *mValidateButton;
	
	NSObject<commentDelegate> *mCommentDelegate;
	
	NSUInteger mTextLength;
	NSString* mOriginalComment;
}

- (id)initWithDelegate:(NSObject<commentDelegate> *) _commmentDelegate;
- (id)initWithDelegate:(NSObject<commentDelegate> *) _commentDelegate andComment:(NSString*)_comment;

- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
-(IBAction) validateButtonPressed:(id)sender;

@property (nonatomic, retain) NSString* mTextComment;
@property (nonatomic, retain) NSString* mOriginalComment;
@property (nonatomic, retain) IBOutlet UILabel *mLabelNumCharRemaining;
@property (nonatomic, retain) IBOutlet UITextField *mTextField;
@property (nonatomic, retain) IBOutlet UIButton *mValidateButton;
@property (nonatomic, retain) NSObject<commentDelegate> *mCommentDelegate;

@end
