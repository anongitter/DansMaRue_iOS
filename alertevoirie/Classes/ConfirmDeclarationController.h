//
//  ConfirmDeclarationController.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "incidentDelegate.h"
#import "GetIncidentsByPosition.h"

#define kConfirmCellHeight				180

@interface ConfirmDeclarationController : UIViewController
	<incidentDelegate, UIAlertViewDelegate> 
{
	NSMutableArray* mIncidentsOngoing;
	
	IBOutlet UITableView * mTableView;
	IBOutlet UILabel *mLabel;
	
	UIView *mLoadingView;
	
	GetIncidentsByPosition *mRequester;
}
@property (nonatomic, retain) NSMutableArray* mIncidentsOngoing;

- (IBAction)btnDeclareIncident:(id)sender;
- (void) showLoadingView:(BOOL)show;
- (IBAction) returnToPreviousView:(id)sender;

@end
