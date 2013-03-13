//
//  ArrowViewController.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 10/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "finalImageDelegate.h"

#define kArrowImageName		@"big_arrow.png"

@interface ArrowViewController : UIViewController {
	UIImage *mArrowImage;
	UIImage *mBackgroundImage;
	
	UIImageView *mViewArrowImage;
	UIImageView *mViewBackgroundImage;
	
	UIButton *mButtonUse;
	UIButton *mButtonRetake;
	
	UIImage *mFinalImage;
	
	NSObject<finalImageDelegate> *mDelegate;
	
	UIView *mViewInfo;
	UILabel *mLabelInfo;
	
	NSUInteger mNumTaps;
}

@property (nonatomic, retain) IBOutlet UIImageView *mViewArrowImage;
@property (nonatomic, retain) IBOutlet UIImageView *mViewBackgroundImage;
@property (nonatomic, retain) IBOutlet UIButton *mButtonUse;
@property (nonatomic, retain) IBOutlet UIButton *mButtonRetake;
@property (nonatomic, retain) IBOutlet UIView *mViewInfo;
@property (nonatomic, retain) IBOutlet UILabel *mLabelInfo;


@property (nonatomic, retain) UIImage *mArrowImage;
@property (nonatomic, retain) UIImage *mBackgroundImage;
@property (nonatomic, retain) UIImage *mFinalImage;

@property (nonatomic) NSUInteger mNumTaps;

@property (nonatomic, retain) NSObject<finalImageDelegate> *mDelegate;

- (id)initWithBackgroundImage:(UIImage *)_bgImage andDelegate:(NSObject<finalImageDelegate> *)_delegate;
- (void)getScreenImage:(id)sender;
- (IBAction)triggerOKButton:(id)sender;
- (IBAction)triggerCancelButton:(id)sender;

- (void)resetArrowTransform;
- (void)setNewBGImage:(UIImage *)_bgImage;
@end
