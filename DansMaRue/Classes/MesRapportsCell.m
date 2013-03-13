//
//  MesRapportsCell.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "MesRapportsCell.h"


@implementation MesRapportsCell
@synthesize mIncidentDescriptive;
@synthesize mIncidentAddress;
@synthesize mIncidentDate;
@synthesize mIncidentIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void)dealloc {
	[mIncidentDescriptive release];
	[mIncidentAddress release];
	[mIncidentDate release];
	[super dealloc];
}


@end
