//
//  ImageManager.h
//  Universal
//
//  Created by Jean-Denis Pauleau on 14/04/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "ImageManagerDelegate.h"

@interface ImageManager : NSObject
{
	NSMutableDictionary*		DicoImage;	
	NSMutableDictionary*		mDelegateDictionary;
}

@property (nonatomic, retain) NSMutableDictionary* DicoImage;
@property (nonatomic, retain) NSMutableDictionary* mDelegateDictionary;

- (UIImage *)	   getImageNamed:(NSString *)urlImage withDelegate:(NSObject<ImageManagerDelegate> *)delegate;
- (void)		   removeCache;
- (void)		   removeDelegateForImage:(NSString*)_imageName;
+ (ImageManager *) sharedImageManager;

@end