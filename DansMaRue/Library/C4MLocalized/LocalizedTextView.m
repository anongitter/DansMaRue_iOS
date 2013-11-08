//
//  LocalizedTextView.m
//  Bhost
//
//  Created by  on 13/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalizedTextView.h"

@implementation LocalizedTextView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		self.text	= NSLocalizedString(self.text, @"");
	}
	return self;
}

@end
