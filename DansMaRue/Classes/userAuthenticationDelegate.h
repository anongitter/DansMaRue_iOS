//
//  userAuthenticationDelegate.h
//  InfoVoirie
//
//  Created by Christophe on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol userAuthenticationDelegate

- (void)didAuthenticate;
- (void)didFailedAuthenticationWithStatusCode:(NSInteger)_status;

@end
