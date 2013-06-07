//
//  InfoVoirieAppDelegate.h
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright C4MProd 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface InfoVoirieAppDelegate : NSObject
	<UIApplicationDelegate, CLLocationManagerDelegate>
{
    UIWindow*					window;
    UITabBarController*			tabBarController;
	CLLocationManager*			mLocationManager;
	NSUInteger					mNumGeolocIteration;
	
	BOOL						mUseStandardNavBar;
}

+ (InfoVoirieAppDelegate*)sharedDelegate;

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet UITabBarController* tabBarController;
@property (nonatomic, assign) BOOL mUseStandardNavBar;

@end
