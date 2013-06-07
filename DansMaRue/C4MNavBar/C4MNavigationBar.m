//
//  C4MNavigationBar.m
//  Bordeau
//
//  Created by Raphaël Pinto on 21/12/10.
//  Copyright 2010 c4m. All rights reserved.
//

#import "C4MNavigationBar.h"
#import "InfoVoirieAppDelegate.h"


//static C4MNavigationBar *instance = nil;

@implementation C4MNavigationBar



- (void)drawRect:(CGRect)rect 
{      
    UIImage *image = nil;
    
    if ([[InfoVoirieAppDelegate sharedDelegate] mUseStandardNavBar])
	{
		image = [UIImage imageNamed: @"black_navbar.png"];
		self.tintColor = [UIColor colorWithWhite:0. alpha:1.];
	}
	else
	{
		image = [UIImage imageNamed: @"white_navbar.png"];
		self.tintColor = [UIColor colorWithWhite:0. alpha:1.];
	}
	
	[image drawInRect:CGRectMake(0., 0., self.frame.size.width, self.frame.size.height)];
}


@end
