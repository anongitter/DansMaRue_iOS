//
//  CategoriesCell.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 05/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "CategoriesCell.h"


@implementation CategoriesCell
@synthesize mLabelCategory;
@synthesize mImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
