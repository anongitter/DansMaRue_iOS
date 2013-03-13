//
//  ActualiteCell.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ActualiteCell.h"

@implementation ActualiteCell
@synthesize mDescription;
@synthesize mAddress;
@synthesize mImageViewStatus;

- (void)dealloc {
	[mDescription release];
	[mAddress release];
	[mImageViewStatus release];
    [super dealloc];
}


@end
