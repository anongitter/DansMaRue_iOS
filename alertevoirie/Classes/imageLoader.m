//
//  imageLoader.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "imageLoader.h"

@implementation ImageLoader
@synthesize mImageLoaderDelegate;
@synthesize mDicoImage;
@synthesize mDefault;
@synthesize nilDelegate;

static ImageLoader *	sharedImageLoaderInstance = nil;

- (id)init
{
	self = [super init];
	if (self)
	{
		self.mDefault = nil;
	}
	return self;
}

- (id)initWithDelegate:(NSObject <imageLoaderDelegate>*)_delegate
{
	self = [super init];
	if (self) {
		
		self.mImageLoaderDelegate = _delegate;
	}
	return self;
}

+ (ImageLoader *)sharedImageLoader
{
	if (sharedImageLoaderInstance == nil)
	{
		sharedImageLoaderInstance = [[ImageLoader alloc] init];
	}
	return sharedImageLoaderInstance;
}

- (void)cancelActions
{
	self.nilDelegate = YES;
}

- (NSString*)applicationDocumentsDirectory 
{	
	NSString* basePath = NSTemporaryDirectory();
    return basePath;
}

- (void) setImageLoaderDelegate:(NSObject <imageLoaderDelegate> *)_delegate
{
	self.mImageLoaderDelegate = _delegate;
}

- (UIImage *)loadImage:(NSString*)_urlImage	forDelegate:(NSObject <imageLoaderDelegate> *)_delegate
{
	if(mDicoImage == nil)
		self.mDicoImage = [NSMutableDictionary dictionary];
	
	if([mDicoImage valueForKey:_urlImage] != nil)
	{
		return [mDicoImage valueForKey:_urlImage];
	}
	else
	{
		if ( [[NSFileManager defaultManager] fileExistsAtPath:_urlImage]) 
		{
			NSString* local_img_path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:_urlImage];
			UIImage *img = [UIImage imageWithContentsOfFile:local_img_path];
			[mDicoImage setValue:img forKey:_urlImage];
			return img;
		} 
		else 
		{
			NSDictionary* tmpDic = [[NSDictionary alloc] initWithObjectsAndKeys:_delegate, @"delegate", _urlImage, @"url", nil];
			[NSThread detachNewThreadSelector:@selector(downloadImageToCache:) toTarget:self withObject:tmpDic];
			[tmpDic release];
			
			return mDefault;
		}
	}
}

- (void)removeCache
{
	for(NSString* imageName in [mDicoImage allKeys])
	{
		NSString* img_path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:imageName];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:img_path error:NULL];
	}
	[mDicoImage removeAllObjects];
}

- (void) downloadImageToCache:(NSDictionary*)Dico
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* urlImage = [Dico valueForKey:@"url"];
	
	if ( !urlImage || urlImage == nil) 
	{
		[pool release];
		return;
	}
	
	NSURL *url = [NSURL URLWithString:urlImage];
	NSData *data = [[NSData alloc]initWithContentsOfURL:url];
	
	if([[mDicoImage allKeys] count]>100)
		[self removeCache];
	
	if ( data != nil) 
	{
		UIImage *img = [[UIImage alloc] initWithData:data];
		if ( img != nil) 
		{		
			[mDicoImage setValue:img forKey:urlImage];
			NSData *dataForPNGFile = UIImagePNGRepresentation(img);
			NSString* img_path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:urlImage];
			[dataForPNGFile writeToFile:img_path options:0 error:nil];
			
			if (nilDelegate == NO)
			{
				NSObject<imageLoaderDelegate>* delegate = [Dico valueForKey:@"delegate"];
				[delegate didLoadImage:img];
			}
			else
			{
				nilDelegate = NO;
			}
		}
		[img release];
	}
	[data release];
	
	[pool release];
}


@end
