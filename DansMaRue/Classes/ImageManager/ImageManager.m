//
//  ImageManager.m
//  Universal
//
//  Created by Jean-Denis Pauleau on 14/04/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager
@synthesize DicoImage;
@synthesize mDelegateDictionary;


static ImageManager *	sharedImageManagerInstance = nil;

+ (ImageManager *)sharedImageManager
{
	if (sharedImageManagerInstance == nil)
	{
		sharedImageManagerInstance = [[ImageManager alloc] init];
	}
	return sharedImageManagerInstance;
}

- (id) init
{
	self = [super init];
	
	if (self)
	{
		self.DicoImage				= [NSMutableDictionary dictionary];
		self.mDelegateDictionary	= [[NSMutableDictionary alloc]init];
	}
	return self;
}

- (void) dealloc
{
	[DicoImage release];
	[mDelegateDictionary release];
	[super dealloc];
}


- (NSString*)applicationImagesDirectory 
{	
	NSString* basePath = NSTemporaryDirectory();
    return basePath;
}


- (UIImage *) getImageNamed:(NSString *)urlImage withDelegate:(NSObject <ImageManagerDelegate> *)delegate
{
	if(urlImage != nil)
	{
		// Image already in memory.
		if ([DicoImage valueForKey:urlImage] != nil)
		{
			if(delegate != nil)
			{
				[delegate didUpdateImage:[DicoImage valueForKey:urlImage]  animated:NO];
				//[delegate performSelectorOnMainThread: @selector(didUpdateImage:) withObject:[DicoImage valueForKey:urlImage] waitUntilDone:NO];
			}
			return [DicoImage valueForKey:urlImage];
		}
		// Image have to be downloaded.
		else
		{
			NSString * local_img_path = [[self applicationImagesDirectory] stringByAppendingPathComponent:[[urlImage stringByReplacingOccurrencesOfString:@":" withString:@"!"] stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:local_img_path]) 
			{
				UIImage * img = [UIImage imageWithContentsOfFile:local_img_path];
				[DicoImage setValue:img forKey:urlImage];
				[delegate didUpdateImage:img animated:NO];
				//[delegate performSelectorOnMainThread: @selector(didUpdateImage:) withObject:[DicoImage valueForKey:urlImage] waitUntilDone:NO];
				return [DicoImage valueForKey:urlImage];
			} 
			else 
			{ 
				// If there already exist a entry in the ditionary for this image.
				if([mDelegateDictionary objectForKey:urlImage] != nil)
				{
					if (delegate)
					{
						[[mDelegateDictionary objectForKey:urlImage] addObject:delegate];
					}
					
				}
				// If this is the first ask for this image.
				else 
				{
					// Create the array.
					NSMutableArray* delegateArray = [[NSMutableArray alloc]init];
					// Add the delegate.
					if(delegate != nil)
					{
						[delegateArray addObject:delegate];
					}
					// Add the array in the delegate Dictionary.
					[mDelegateDictionary setObject:delegateArray forKey:urlImage];
					// free memory.
					[delegateArray release];
				}
				if(delegate != nil)
				{
					[delegate performSelector:@selector(willUpdateImage)];
				}
				[NSThread detachNewThreadSelector:@selector(downloadImageToCache:) toTarget:self withObject:urlImage];
				return nil;
			}
		}
	}
	return nil;
}

- (void)removeDelegateForImage:(NSString*)_imageName
{
	if (_imageName != nil)
	{
		[mDelegateDictionary removeObjectForKey:_imageName];
	}
}

- (void) removeCache
{
	[DicoImage removeAllObjects];
}

- (void) downloadImageToCache:(NSString*)urlImage
{
	NSAutoreleasePool * pool	 = [[NSAutoreleasePool alloc] init];
	
	if (!(urlImage) || (urlImage == nil)) 
	{
		[pool drain];
		return;
	}
	
	NSURL *	 url  = [NSURL URLWithString:urlImage];
	NSData * data = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
	
	if ([[DicoImage allKeys] count] > 100)
	{
		[self removeCache];
	}
	
	if (data != nil) 
	{
		UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
		if ( img != nil) 
		{
			[DicoImage setValue:img forKey:urlImage];
			NSString * img_path = [[self applicationImagesDirectory] stringByAppendingPathComponent:[[urlImage stringByReplacingOccurrencesOfString:@":" withString:@"!"] stringByReplacingOccurrencesOfString:@"/" withString:@"!"]];
			NSError * error;
			if (![data writeToFile:img_path options:0 error:&error])
			{
				C4MLog(@"-[ImageManager downloadImageToCache:] error %@",error);
			}
			
			if([mDelegateDictionary objectForKey:urlImage] != nil)
			{
				// Send for each delegate the image.
				for(NSObject<ImageManagerDelegate>* currentDelegate in [mDelegateDictionary objectForKey:urlImage])
				{
					[currentDelegate didUpdateImage:img animated:YES];
					//[currentDelegate performSelectorOnMainThread: @selector(didUpdateImage:) withObject:img waitUntilDone:NO];	
				}
			}
			// remove the delegate array.
			[mDelegateDictionary removeObjectForKey:urlImage];
		}
	}
	else
	{
		C4MLog(@"-[ImageManager downloadImageToCache:] image = nil");
		
		if([mDelegateDictionary objectForKey:urlImage] != nil)
		{
			// Send for each delegate nil.
			for(NSObject<ImageManagerDelegate>* currentDelegate in [mDelegateDictionary objectForKey:urlImage])
			{
				[currentDelegate didUpdateImage:nil animated:NO];
				//[currentDelegate performSelectorOnMainThread: @selector(didUpdateImage:) withObject:nil waitUntilDone:NO];	
			}
		}
		// remove the delegate array.
		[mDelegateDictionary removeObjectForKey:urlImage];
	}
	[pool drain];
}




@end