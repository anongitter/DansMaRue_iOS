//
//  UpdateFormPictureDelegate.h
//  InfoVoirie
//
//  Created by Christophe Boivin on 14/06/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UpdateFormPictureDelegate

-(void) updateImageFar:(UIImage*) _Image;
-(void) updateImageNear:(UIImage*) _Image;

@end
