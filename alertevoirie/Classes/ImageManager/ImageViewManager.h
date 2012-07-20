//
//  ImageViewManager.h
//  PlayGround
//
//  Created by Prigent roudaut on 15/09/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageManagerDelegate.h"



//"imageInstance"///.image = [[ImageManager sharedImageManager] getImageNamed:///@"URLNAME"// withDelegate://"imageInstance"//];

@interface ImageViewManager : UIImageView<ImageManagerDelegate>
{
	UIActivityIndicatorView *	mIndicator;
}

@end
