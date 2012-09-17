//
//  GetUserReports.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicRequest.h"
#import "categoriesDelegate.h"

@interface GetCategories : BasicRequest
{
	NSObject<categoriesDelegate> *mCategoriesDelegate;
}

@property (nonatomic, retain) NSObject<categoriesDelegate> *mCategoriesDelegate;

- (id)initWithDelegate:(NSObject<categoriesDelegate> *) _categoriesDelegate;
- (void)downloadCategories;

@end
