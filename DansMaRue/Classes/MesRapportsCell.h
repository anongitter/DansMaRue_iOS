//
//  MesRapportsCell.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MesRapportsCell  : UITableViewCell  {
	UILabel *mIncidentDescriptive;
	UILabel *mIncidentAddress;
	UILabel *mIncidentDate;
	
	UIImageView *mIncidentIcon;
}

@property (nonatomic, retain) IBOutlet UILabel *mIncidentDescriptive;
@property (nonatomic, retain) IBOutlet UILabel *mIncidentAddress;
@property (nonatomic, retain) IBOutlet UILabel *mIncidentDate;
@property (nonatomic, retain) IBOutlet UIImageView *mIncidentIcon;
@end
