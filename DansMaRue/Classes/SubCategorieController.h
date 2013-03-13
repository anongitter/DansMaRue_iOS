//
//  SubCategorieController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "incidentObj.h"
#import "ValidationRapportController.h"
#import "FicheIncidentController.h"

#define kSubCategoryCellHeight			60

@interface SubCategorieController : UIViewController 
{
	NSMutableArray*					mParentCategorie;
	IBOutlet UITableView*			mTableView;
	ValidationRapportController*	mNextViewController;
	FicheIncidentController*		mFicheViewController;
	
	NSString*						mParentString;
	BOOL							mUseStreetFurnituresCells;
	NSDictionary*					mStreetFurnituresPictures;
}
@property (nonatomic, retain) NSMutableArray* mParentCategorie;
@property (nonatomic, retain) NSDictionary* mStreetFurnituresPictures;
@property (nonatomic, retain) ValidationRapportController *mNextViewController;
@property (nonatomic, retain) FicheIncidentController *mFicheViewController;

- (id)initWithNextView:(ValidationRapportController*)_nextView andID:(NSNumber*) _ParentID;
- (id)initWithFicheView:(FicheIncidentController *)_nextView andID:(NSNumber*) _ParentID;
- (IBAction) returnToPreviousView:(id)sender;

@end
