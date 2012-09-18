//
//  GetUserReports.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetCategories.h"

@implementation GetCategories
@synthesize mCategoriesDelegate;

- (id)initWithDelegate:(NSObject<categoriesDelegate> *) _categoriesDelegate
{
	self = [super init];
	if (self)
	{
		self.mCategoriesDelegate = _categoriesDelegate;
	}
	
	return self;
}

- (void)setCategoriesDelegate:(NSObject<categoriesDelegate> *) _categoriesDelegate
{
	if (mCategoriesDelegate != nil)
	{
		[mCategoriesDelegate release];
		mCategoriesDelegate = nil;
	}
	self.mCategoriesDelegate = _categoriesDelegate;
}

- (void)dealloc
{
	[mCategoriesDelegate release];
	[super dealloc];
}

- (void)downloadCategories
{
    
    NSString* version = [[NSUserDefaults standardUserDefaults] valueForKey:@"categories_version"];
    if (version==nil) version = @"0";
    
	self.mReceivedData = [NSMutableData data];
	
	NSMutableArray* requests = [NSMutableArray array];
	
	NSMutableDictionary* dictionnary = [NSMutableDictionary dictionary];
	[dictionnary setObject:@"getCategories" forKey:@"request"];
	[dictionnary setObject:version forKey:@"curVersion"];
	[requests addObject:dictionnary];
    
    mURLConnection = [[InfoVoirieContext launchRequestWithArray:requests andDelegate:self] retain];
}

#pragma mark -
#pragma mark Connection Delegate Methods
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[super connection:connection didFailWithError:error];
	
	[InfoVoirieContext sharedInfoVoirieContext].mCategory = [[NSUserDefaults standardUserDefaults] valueForKey:@"categories_json"];
    [mCategoriesDelegate didReceiveCategories];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    
    if ([httpResponse respondsToSelector:@selector(allHeaderFields)])
	{
        NSDictionary * dicresponse = httpResponse.allHeaderFields;
		
		NSLog(@"HTTP headers for response:\n %@",dicresponse);
        BOOL testAvailableVersion = YES;
        if ([dicresponse objectForKey:kHTTPHeaderForceUpdateKey/*@"x-app-force-update"*/])
		{
			if ([[dicresponse objectForKey:kHTTPHeaderForceUpdateKey] isEqualToString:@"true"])
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReceiveForceUpdate object:nil];
                testAvailableVersion = NO;
			}
		}
		
		if (testAvailableVersion && [dicresponse objectForKey:kHTTPHeaderAvailableVersionKey/*@"x-app-available-version"*/])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReceiveNewVersion object:[dicresponse objectForKey:kHTTPHeaderAvailableVersionKey]];
		}
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSString* filesContent = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
	
    NSLog(@"downloaded categories: %@", filesContent);
    
	NSMutableArray* idRootJson = [mJson objectWithString:filesContent error:nil];
	[filesContent release];
	
//    NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
//    NSDictionary* lDicRoot = [jsonRootObject objectAtIndex:0];
//    NSDictionary* lAnswerRoot = [lDicRoot valueForKey:@"answer"];

    //workaround
	if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
        NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
		NSDictionary* lDicRoot = [jsonRootObject objectAtIndex:0];
        
        //Store locally if necessary
        NSString* version = [NSString stringWithFormat:@"%d", [[lDicRoot valueForKey:@"version"] intValue]];
        NSString* old_version = [[NSUserDefaults standardUserDefaults] valueForKey:@"categories_version"];
        if (![version isEqualToString:old_version]) {
            [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"categories_version"];
            
            NSDictionary* lCategoriesRoot = [lDicRoot valueForKey:@"categories"];
            [[NSUserDefaults standardUserDefaults] setValue:lCategoriesRoot forKey:@"categories_json"];
        }
	}
	else 
	{
		NSLog(@"Error");
	}
    
    [InfoVoirieContext sharedInfoVoirieContext].mCategory = [[NSUserDefaults standardUserDefaults] valueForKey:@"categories_json"];
    [mCategoriesDelegate didReceiveCategories];
}

@end
