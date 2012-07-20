//
//  CategoriesCell.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 05/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CategoriesCell : UITableViewCell {
	UILabel *mLabelCategory;
	// Streets Furnitures
	UIImageView *mImageView;
}

@property (nonatomic, retain) IBOutlet UILabel *mLabelCategory;
@property (nonatomic, retain) IBOutlet UIImageView *mImageView;

@end
