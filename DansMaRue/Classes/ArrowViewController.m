//
//  ArrowViewController.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 10/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ArrowViewController.h"
#import "finalImageDelegate.h"

CGImageRef UIGetScreenImage();

@implementation ArrowViewController
@synthesize mArrowImage;
@synthesize mBackgroundImage;
@synthesize mFinalImage;
@synthesize mViewArrowImage;
@synthesize mViewBackgroundImage;
@synthesize mNumTaps;
@synthesize mButtonUse;
@synthesize mButtonRetake;
@synthesize mDelegate;
@synthesize mViewInfo;
@synthesize mLabelInfo;

- (id)initWithBackgroundImage:(UIImage *)_bgImage andDelegate:(NSObject<finalImageDelegate> *)_delegate
{
	self = [super initWithNibName:@"ArrowViewController" bundle:nil];
	if (self) {
		self.mDelegate = _delegate;
		self.mBackgroundImage = _bgImage;
		self.mArrowImage = [UIImage imageNamed:kArrowImageName];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    //fix iOS7 to vaid layout go underneath the navBar
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7(x)

	[mViewArrowImage setImage:mArrowImage];
	[mViewBackgroundImage setImage:mBackgroundImage];
	self.view.multipleTouchEnabled = YES;
}

// "Screenshot"
- (void)getScreenImage:(id)sender
{	
	UIGraphicsBeginImageContext(self.view.frame.size);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	mFinalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	mButtonUse.hidden = NO;
	mButtonRetake.hidden = NO;
	mViewInfo.hidden = NO;
	mLabelInfo.hidden = NO;
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[mDelegate didReceiveImage:mFinalImage fromController:self];
}

- (void)setNewBGImage:(UIImage *)_bgImage
{
	[mBackgroundImage release];
	self.mBackgroundImage = _bgImage;
	if (mViewBackgroundImage != nil) {
		[mViewBackgroundImage setImage:mBackgroundImage];
	}
	self.mArrowImage = [UIImage imageNamed:kArrowImageName];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.mViewArrowImage = nil;
	self.mViewBackgroundImage = nil;
	self.mButtonUse = nil;
	self.mButtonRetake = nil;
	//self.mFinalImage = nil;
	self.mViewInfo = nil;
	self.mLabelInfo = nil;
}

- (void)dealloc
{
	[mArrowImage release];
	[mBackgroundImage release];
	[mViewArrowImage release];
	[mViewBackgroundImage release];
	[mButtonUse release];
	[mButtonRetake release];
	[mDelegate release];
	[mViewInfo release];
	[mLabelInfo release];
	[super dealloc];
}

#pragma mark -
#pragma mark Touches Methods

- (void)resetArrowTransform
{
	mViewArrowImage.layer.transform = CATransform3DIdentity;
	mViewArrowImage.center = CGPointMake(self.view.frame.size.width/2., self.view.frame.size.height/2.);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	mNumTaps = [[touches anyObject] tapCount];
	// If tap count = 2, the position of the arrow is resetted
	if(mNumTaps == 2)
	{
		[self resetArrowTransform];
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *ltouch;
	UITouch *lsecondtouch;
	
	ltouch = [[touches allObjects] objectAtIndex:0];
	CGPoint beginPoint2,currentPoint2,beginPoint1,currentPoint1;
	CGFloat difLocationX, difLocationY;
	
	beginPoint1 = [ltouch locationInView:ltouch.view];
    currentPoint1 = [ltouch previousLocationInView:ltouch.view];
	difLocationX = (currentPoint1.x - beginPoint1.x);
	difLocationY = (currentPoint1.y - beginPoint1.y);
	
	// One touch - the arrow is translated
	if([touches count] == 1)
	{
		CGPoint origin = mViewArrowImage.center;
		if (origin.x - mViewArrowImage.layer.frame.size.width/2. - difLocationX < 0) {
			return;
		}
		if (origin.x + mViewArrowImage.layer.frame.size.width/2. - difLocationX > self.view.frame.size.width) {
			return;
		}
		if (origin.y - mViewArrowImage.layer.frame.size.height/2. - difLocationY < 0) {
			return;
		}
		if (origin.y + mViewArrowImage.layer.frame.size.height/2. - difLocationY > self.view.frame.size.height) {
			return;
		}
		
		CGPoint center = mViewArrowImage.center;
		CGPoint dif = CGPointMake(center.x - difLocationX, center.y - difLocationY);
		mViewArrowImage.center = dif;
	}
	// Two touches (or more) - the arrow is rotated w.r.t the 2 first touches movements
	if ([touches count] > 1) {
		lsecondtouch = [[touches allObjects] objectAtIndex:1];
		
		beginPoint2 = [lsecondtouch locationInView:lsecondtouch.view];
		currentPoint2 = [lsecondtouch previousLocationInView:lsecondtouch.view];
		
		// Rotate mArrowView
		// create 2 vectors that represent the movements of each touch
		CGPoint vecPrevious = beginPoint1;
		vecPrevious.x -= beginPoint2.x;
		vecPrevious.y -= beginPoint2.y;
		CGPoint vecCurrent = currentPoint1;
		vecCurrent.x -= currentPoint2.x;
		vecCurrent.y -= currentPoint2.y;
		// compute their norm
		CGFloat normCurrent = sqrt(vecCurrent.x*vecCurrent.x + vecCurrent.y*vecCurrent.y);
		CGFloat normPrevious = sqrt(vecPrevious.x*vecPrevious.x + vecPrevious.y*vecPrevious.y);
		// compute the angle between these two vectors
		CGFloat c = (vecCurrent.x * vecPrevious.x + vecCurrent.y* vecPrevious.y)/(normCurrent*normPrevious);
		
		// We don't test that c is equal to 1, to manage the issues of round off
		if (c > 0.9999 || c < -0.9999) {
			return;
		}
		
		CGFloat sign = (vecCurrent.x * vecPrevious.y - vecCurrent.y* vecPrevious.x);
		
		if(sign != 0)
			sign /= abs(sign);
		else
			sign = 1;
		CGFloat angle = sign * acos(c);
		
		// apply the transformation
		CATransform3D rotationTransform = mViewArrowImage.layer.transform;
		rotationTransform = CATransform3DRotate(rotationTransform, angle, 0, 0, 1);
		mViewArrowImage.layer.transform = rotationTransform;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

#pragma mark -
#pragma mark trigger button methods
- (IBAction)triggerOKButton:(id)sender
{
	mButtonUse.hidden = YES;
	mButtonRetake.hidden = YES;
	mViewInfo.hidden = YES;
	mLabelInfo.hidden = YES;
	[self performSelector:@selector(getScreenImage:) withObject:nil afterDelay:.2];
}

- (IBAction)triggerCancelButton:(id)sender
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[mDelegate didReceiveImage:nil fromController:self];
}

@end
