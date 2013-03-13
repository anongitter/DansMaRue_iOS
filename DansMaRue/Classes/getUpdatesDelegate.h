//
//  getUpdatesDelegate.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol getUpdatesDelegate

- (void)didReceiveUpdates:(NSArray*)_updates;

@end
