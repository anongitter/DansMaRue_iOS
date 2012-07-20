//
//  UserAuthentication.h
//  InfoVoirie
//
//  Created by Christophe on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "incidentObj.h"
#import "userAuthenticationDelegate.h"

@interface UserAuthentication : BasicRequest
{
	NSObject<userAuthenticationDelegate> *mDelegate;
}

- (id)initWithDelegate:(NSObject<userAuthenticationDelegate> *) _delegate;
- (void)generateUserAuthentication;

@end
