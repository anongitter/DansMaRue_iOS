//
//  ActualiteCell.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActualiteCell : UITableViewCell {
	UILabel *mDescription;
	UILabel *mAddress;
	UIImageView *mImageViewStatus;
}

@property (nonatomic, retain) IBOutlet UILabel *mDescription;
@property (nonatomic, retain) IBOutlet UILabel *mAddress;
@property (nonatomic, retain) IBOutlet UIImageView *mImageViewStatus;

@end
