//
//  C4MNavigationBar.m
//  Bordeau
//
//  Created by Raphaël Pinto on 21/12/10.
//  Copyright 2010 c4m. All rights reserved.
//

#import "C4MNavigationBar.h"

//static C4MNavigationBar *instance = nil;

@implementation C4MNavigationBar

/*
// Singleton accessor
+ (C4MNavigationBar *)Instance
{
	// Check if an instance already exist
    if (instance == nil)
	{
		// If not, create a new one an load it
        instance = [[C4MNavigationBar alloc] init];
    }
    return instance;
}


- (id)init
{
	if (self = [super init])
	{
         NSLog(@"C4MNavigationBar init");
	}	
	return self;
}

*/

- (void)drawRect:(CGRect)rect 
{
    NSLog(@"C4MNavigationBar drawRect");
    /*
	UIImage* image = [UIImage imageNamed: @"white_navbar.png"];
    [image drawInRect:CGRectMake(0., 0., self.frame.size.width, self.frame.size.height)];
    */
    
    NSLog(@"mUseStandardNavBar : %d", [[InfoVoirieAppDelegate sharedDelegate] mUseStandardNavBar]);
    
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
