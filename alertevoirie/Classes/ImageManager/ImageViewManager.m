//
//  ImageViewManager.m
//  PlayGround
//
//  Created by Prigent roudaut on 15/09/10.
//  Updated by JD pauleau on 08/10/2010.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ImageViewManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageViewManager

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		mIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[mIndicator stopAnimating];
		mIndicator.hidesWhenStopped = YES;
		mIndicator.frame = CGRectMake(self.frame.size.width/2 -10, self.frame.size.height/2 -10, 20, 20);
		[self addSubview:mIndicator];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		mIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[mIndicator stopAnimating];
		mIndicator.hidesWhenStopped = YES;
		mIndicator.frame = CGRectMake(self.frame.size.width/2 -10, self.frame.size.height/2 -10, 20, 20);
		[self addSubview:mIndicator];
	}
	
	return self;
}

-(void)willUpdateImage
{
	[mIndicator startAnimating];
}

- (void) didUpdateImage:(UIImage *)img animated:(BOOL)_animated
{
	[mIndicator stopAnimating];
	
	if (img == nil)
	{
		return;
	}
	
	if (_animated)
	{
		CATransition *transition = [CATransition animation];
		[transition setType:kCATransitionFade];
		[transition setDuration:0.5f];
		[self.layer addAnimation:transition forKey:nil];
	}
	
	self.image = img;
	//self.contentMode = UIViewContentModeScaleToFill;
}


- (void) dealloc
{
	[mIndicator release];
	[super dealloc];
}

@end
