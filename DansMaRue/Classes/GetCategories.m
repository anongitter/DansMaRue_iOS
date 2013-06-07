//
//  GetUserReports.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 07/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "GetCategories.h"
#import "InfoVoirieContext.h"


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
	
	[InfoVoirieContext sharedInfoVoirieContext].mCategory = [self getMutableObjectFromObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"categories_json"]];
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
	
    if( [idRootJson isKindOfClass: [NSMutableArray class]] )
	{
        NSMutableArray* jsonRootObject = (NSMutableArray*) idRootJson ;
        NSMutableDictionary* lDicRoot = [NSMutableDictionary dictionaryWithDictionary:[jsonRootObject objectAtIndex:0]];
        NSMutableDictionary* lAnswerRoot = [NSMutableDictionary dictionaryWithDictionary:[lDicRoot valueForKey:@"answer"]];
        
        //Store locally if necessary
        NSString* version = [NSString stringWithFormat:@"%d", [[lAnswerRoot valueForKey:@"version"] intValue]];
        NSString* old_version = [[NSUserDefaults standardUserDefaults] valueForKey:@"categories_version"];
        if (![version isEqualToString:old_version]) {
            [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"categories_version"];
            
            NSMutableDictionary* lCategoriesRoot = [NSMutableDictionary dictionary];
            [lCategoriesRoot addEntriesFromDictionary:[lAnswerRoot valueForKey:@"categories"]];
            
            
            C4MLog(@"STOP1 %@", [NSMutableDictionary class]);
            C4MLog(@"STOP1 %@", [lCategoriesRoot class]);
            C4MLog(@"STOP1 %@", lCategoriesRoot);
            
            [[NSUserDefaults standardUserDefaults] setValue:lCategoriesRoot forKey:@"categories_json"];
        }
	}
    
    [[NSUserDefaults standardUserDefaults] synchronize];  
    
    
	[InfoVoirieContext sharedInfoVoirieContext].mCategory = [self getMutableObjectFromObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"categories_json"]];
    
    [mCategoriesDelegate didReceiveCategories];
}



- (id)getMutableObjectFromObject:(id)_Object
{
    if ([_Object isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary* res = [NSMutableDictionary dictionary];
        
        NSDictionary* dictionary = (NSDictionary*)_Object;
        
        for (NSString* aKey in [dictionary allKeys])
        {
            [res setValue:[self getMutableObjectFromObject:[dictionary objectForKey:aKey]] forKey:aKey];
        }
        return res;
    }
    else if ([_Object isKindOfClass:[NSArray class]])
    {
        NSMutableArray* res = [NSMutableArray array];
        
        NSArray* array = (NSArray*)_Object;
        
        for (id anObject in array)
        {
            [res addObject:[self getMutableObjectFromObject:anObject]];
        }
        
        return res;
    }
    else
    {
        return _Object;
    }
}
@end
