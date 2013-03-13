//
//  SupCategorieController.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 16/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "incidentObj.h"
#import "ValidationRapportController.h"
#import "FicheIncidentController.h"

#define kSupCategoryCellHeight			60

@interface SupCategorieController : UIViewController {
	NSMutableArray* mSupCategorie;
	IBOutlet UITableView * mTableView;
	ValidationRapportController *mNextViewController;
	FicheIncidentController *mFicheViewController;
	
	NSString* mParentString;
	BOOL mUseStreetFurnituresCells;
}

@property (nonatomic, retain) NSMutableArray* mSupCategorie;
@property (nonatomic, retain) ValidationRapportController *mNextViewController;
@property (nonatomic, retain) FicheIncidentController *mFicheViewController;

- (id)initWithNextView:(ValidationRapportController*)_nextView andID:(NSArray*) _ChildrenID;
- (id)initWithFicheView:(FicheIncidentController *)_nextView andID:(NSArray*) _ChildrenID;
- (IBAction) returnToPreviousView:(id)sender;

@end