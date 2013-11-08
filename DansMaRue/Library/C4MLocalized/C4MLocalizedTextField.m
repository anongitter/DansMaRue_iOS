//
//  C4MLocalizedTextField.m
//  Bhost
//
//  Created by Raphaël Pinto on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "C4MLocalizedTextField.h"

@implementation C4MLocalizedTextField


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		self.placeholder	= NSLocalizedString(self.placeholder, @"");
	}
	return self;
}

@end
