//
//  GetUserReports.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "reportDelegate.h"

@interface GetUserReports : BasicRequest
{
	NSObject<reportDelegate> *mReportDelegate;
}

@property (nonatomic, retain) NSObject<reportDelegate> *mReportDelegate;

- (id)initWithDelegate:(NSObject<reportDelegate> *) _reportDelegate;
- (void)setReportDelegate:(NSObject<reportDelegate> *) _reportDelegate;
- (void)generateReports;

@end
