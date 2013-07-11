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
#import <HockeySDK/HockeySDK.h>




@interface InfoVoirieAppDelegate() <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate> {}
@end




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
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:kHockeyAppBetaId
														 liveIdentifier:kHockeyAppLiveId
															   delegate:self];
#if CONFIGURATION_Release
	[BITHockeyManager sharedHockeyManager].disableUpdateManager = TRUE;
#endif
	
	[[BITHockeyManager sharedHockeyManager] startManager];
   
    
#warning print default user dictionary
    NSLog(@"[NSUserDefaults standardUserDefaults] %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Add the tab bar controller's current view as a subview of the window
    
    window.rootViewController = tabBarController;
    //[window addSubview:tabBarController.view];
	
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
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newVersionAvailable:) name:kNotificationDidReceiveNewVersion object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceUpdate:) name:kNotificationDidReceiveForceUpdate object:nil];
	
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

	C4MLog(@"locationManager didUpdate");
	// On sauvegarde la nouvelle position courante de l'utilisateur (utile pour les annotations)
	[InfoVoirieContext sharedInfoVoirieContext].mLocation = newLocation.coordinate;
    
    //DAP : DEBUG ONLY when not on Paris (2 rue de la cité 75004 Paris)!!
    //CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:48.854491 longitude:2.347629];
    //[InfoVoirieContext sharedInfoVoirieContext].mLocation = tempLocation.coordinate;
    ///
    
	[InfoVoirieContext sharedInfoVoirieContext].mLocationFound = YES;
	mNumGeolocIteration++;
	if (mNumGeolocIteration == 1)
	{
		C4MLog(@"numGeoloc = 1");
		
		UIViewController *home = [[[[tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
		if ([home isKindOfClass:[NouveauController class]])
		{
			[(NouveauController*)home reloadIncidentStats];
		}
	}
	C4MLog(@"ok");
}


/*
 * Gestion d'erreur
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	C4MLog(@"locationManager: fail with error : %@", error);
}

- (void)dealloc
{
    [tabBarController release];
    [window release];
	[mLocationManager release];
    [super dealloc];
}



#pragma mark - Notification Methods
- (void)newVersionAvailable:(NSNotification*)_notification
{
    NSArray* components;
    
    NSString* lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKey_LastVersionAvailable];
    components = [lastVersion componentsSeparatedByString:@"."];

    int lastVersionMajor = 0;
    int lastVersionMinor = 0;
    int lastVersionBuild = 0;
    if ([components count] > 0)
    {
        lastVersionMajor = [[components objectAtIndex:0] intValue];
        
        if ([components count] > 1)
        {
            lastVersionMinor = [[components objectAtIndex:1] intValue];
            
            if ([components count] > 2)
            {
                lastVersionBuild = [[components objectAtIndex:2] intValue];
            }
        }
    }
    
    NSString* newVersion = _notification.object;
    
    components = [newVersion componentsSeparatedByString:@"."];
    int newVersionMajor = 0;
    int newVersionMinor = 0;
    int newVersionBuild = 0;
    if ([components count] > 0)
    {
        newVersionMajor = [[components objectAtIndex:0] intValue];
        
        if ([components count] > 1)
        {
            newVersionMinor = [[components objectAtIndex:1] intValue];
            
            if ([components count] > 2)
            {
                newVersionBuild = [[components objectAtIndex:2] intValue];
            }
        }
    }
    
    
    if ( newVersionMajor > lastVersionMajor || 
        ( newVersionMajor == lastVersionMajor && newVersionMinor > lastVersionMinor ) ||
        ( newVersionMajor == lastVersionMajor && newVersionMinor == lastVersionMinor && newVersionBuild > lastVersionBuild ))
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_new_version_available_title", nil) message:[NSString stringWithFormat:NSLocalizedString(@"alert_new_version_available_message", nil), newVersion] delegate:self cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:NSLocalizedString(@"alert_new_version_available_open", nil), nil];
        
        alert.tag = 'NEWV';
        [alert show];
        [alert release];
        
        [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:kUserDefaultKey_LastVersionAvailable];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)forceUpdate:(NSNotification*)_notification
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_new_version_available_title", nil) message:NSLocalizedString(@"alert_new_version_force_update_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_new_version_available_open", nil) otherButtonTitles:nil];
    
    alert.tag = 'FORC';
    [alert show];
    [alert release];
}

#pragma mark - UIAlertView Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//NSLog(@"");
	if ( alertView.cancelButtonIndex != buttonIndex )
	{
		if ( alertView.tag == 'NEWV' )
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"application_itunes_link", nil)]];
		}
	}
	else
	{
		if ( alertView.tag == 'FORC' )
		{
			//NSLog(@"");
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"application_itunes_link", nil)]];
		}
	}
}

- (BOOL) shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}



#pragma mark -
#pragma mark HockeyApp Methods



- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_Release
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
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