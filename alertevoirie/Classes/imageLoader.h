//
//  imageLoader.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 15/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "imageLoaderDelegate.h"

@interface ImageLoader : NSObject
{
	NSObject <imageLoaderDelegate> *mImageLoaderDelegate;
	NSMutableDictionary* mDicoImage;
	UIImage *mDefault;
	
	BOOL nilDelegate;
}

@property (nonatomic, retain) NSMutableDictionary* mDicoImage;
@property (nonatomic, retain) UIImage *mDefault;

@property (nonatomic, retain) NSObject<imageLoaderDelegate> *mImageLoaderDelegate;

@property (nonatomic) BOOL nilDelegate;

- (id)initWithDelegate:(NSObject <imageLoaderDelegate>*)_delegate;
- (UIImage *)loadImage:(NSString*)_urlImage	forDelegate:(NSObject <imageLoaderDelegate> *)_delegate;
- (void)removeCache;
- (void) setImageLoaderDelegate:(NSObject <imageLoaderDelegate> *)_delegate;
- (void) downloadImageToCache:(NSDictionary*)Dico;
+ (ImageLoader *)sharedImageLoader;
- (void)cancelActions;

@end
