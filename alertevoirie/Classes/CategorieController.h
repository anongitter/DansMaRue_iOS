//
//  CategorieController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ValidationRapportController.h"
#import "FicheIncidentController.h"

#define kCategoryCellHeight			60

@interface CategorieController : UIViewController 
{
	NSMutableArray* mParentCategorie;
	IBOutlet UITableView * mTableView;
	ValidationRapportController *mNextViewController;
	FicheIncidentController *mFicheViewController;
	
	BOOL	mReturnToRoot;
}

@property (nonatomic, retain) ValidationRapportController *mNextViewController;
@property (nonatomic, retain) FicheIncidentController *mFicheViewController;
@property (nonatomic) BOOL mReturnToRoot;

- (id)initWithViewController:(ValidationRapportController *)_nextViewController;
- (id)initWithFicheViewController:(FicheIncidentController *) _ficheViewController;
- (IBAction) returnToPreviousView:(id)sender;

@end
