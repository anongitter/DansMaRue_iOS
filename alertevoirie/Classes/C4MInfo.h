//
//  C4MInfo.h
//  Beezik
//
//  Created by Prigent roudaut on 12/02/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>

@interface C4MInfo : UIViewController <UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate, UIWebViewDelegate,UIAlertViewDelegate>
{
	UIWebView * mWebView ;
	UITableView * mTableView  ; 
	CATransition *mTransitionOut;
	
	UIImageView * mCodeOn;
	UIImageView * mCodeOff;	
	
	UIImageView * mDesignOn;	
	UIImageView * mDesignOff;	
	
	UIImageView * mNavOn;	
	UIImageView * mNavOff;	
	
	UINavigationBar *mNavBar;
	
	IBOutlet UILabel *mLabelAppVersion;
}

@property (nonatomic, retain) IBOutlet UITableView * mTableView  ; 
@property (nonatomic, retain) IBOutlet UIWebView * mWebView  ; 

@property (nonatomic, retain) IBOutlet UIImageView * mCodeOn;
@property (nonatomic, retain) IBOutlet UIImageView * mCodeOff;	

@property (nonatomic, retain) IBOutlet UIImageView * mDesignOn;	
@property (nonatomic, retain) IBOutlet UIImageView * mDesignOff;	

@property (nonatomic, retain) IBOutlet UIImageView * mNavOn;	
@property (nonatomic, retain) IBOutlet UIImageView * mNavOff;	

@property (nonatomic, retain) IBOutlet UINavigationBar *mNavBar;

@property (nonatomic, retain) CATransition *mTransitionOut;
-(IBAction) btnCall:(id)sender ;
-(IBAction) btnMail:(id)sender ;
-(IBAction) btnApps:(id)sender ;
-(IBAction) btnBack:(id)sender ;

@end
