//
//  InfoVoirieAppDelegate.m
//  InfoVoirie
//
//  Created by Prigent roudaut on 26/05/10.
//  Copyright C4MProd 2010. All rights reserved.
//

#import "InfoVoirieAppDelegate.h"
#import "NouveauController.h"

#import "InfoVoirieContext.h"

@implementation InfoVoirieAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize mUseStandardNavBar;

+ (InfoVoirieAppDelegate*)sharedDelegate
{
	return (InfoVoirieAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{    
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	[tabBarController setDelegate:[InfoVoirieContext sharedInfoVoirieContext]];
	
    [window makeKeyAndVisible];
	
	// CLLocationManager permet la gestion de la position géographique de l'utilisateur
	mLocationManager = [[CLLocationManager alloc] init];
	// Le fait de setter le Delegate permet d'appeler méthodes implémentées dans cette classe
	[mLocationManager setDelegate:self];
	// Définit l'échelle de distance à prendre en compte pour le raffraichissement de la position courante 
	[mLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[mLocationManager startUpdatingLocation];
	
	mNumGeolocIteration = 0;
	
	
	
	return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// CLLocationManager permet la gestion de la position géographique de l'utilisateur
	mLocationManager = [[CLLocationManager alloc] init];
	// Le fait de setter le Delegate permet d'appeler méthodes implémentées dans cette classe
	[mLocationManager setDelegate:self];
	// Définit l'échelle de distance à prendre en compte pour le raffraichissement de la position courante 
	[mLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[mLocationManager startUpdatingLocation];
	
	mNumGeolocIteration = 0;
}

#pragma mark -
#pragma mark Location Manager Delegate Methods
/*
 * On sauvegarde la position géographique courante
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"locationManager didUpdate");
	// On sauvegarde la nouvelle position courante de l'utilisateur (utile pour les annotations)
	[InfoVoirieContext sharedInfoVoirieContext].mLocation = newLocation.coordinate;
	[InfoVoirieContext sharedInfoVoirieContext].mLocationFound = YES;
	mNumGeolocIteration++;
	if (mNumGeolocIteration == 1)
	{
		NSLog(@"numGeoloc = 1");
		
		UIViewController *home = [[[[tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
		if ([home isKindOfClass:[NouveauController class]])
		{
			[(NouveauController*)home reloadIncidentStats];
		}
	}
	NSLog(@"ok");
}


/*
 * Gestion d'erreur
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"locationManager: fail with error : %@", error);
}

- (void)dealloc
{
    [tabBarController release];
    [window release];
	[mLocationManager release];
    [super dealloc];
}

@end

/*
//custom navigation bar
@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect
{
	UIImage *image = nil;
	
	if ([[InfoVoirieAppDelegate sharedDelegate] mUseStandardNavBar])
	{
		image = [UIImage imageNamed: @"black_navbar.png"];
		self.tintColor = [UIColor colorWithWhite:0. alpha:1.];
	}
	else
	{
		image = [UIImage imageNamed: @"white_navbar.png"];
		self.tintColor = [UIColor colorWithWhite:0. alpha:1.];
	}
	
	[image drawInRect:CGRectMake(0., 0., self.frame.size.width, self.frame.size.height)];
	//self.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
}
@end
*/