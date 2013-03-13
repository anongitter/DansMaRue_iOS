/*
 *  JSonResponseHandler.h
 *  TendanceSante
 *
 *  Created by Olivier Bonal on 13/11/09.
 *  Copyright 2009 C4M Prod. All rights reserved.
 *
 */

@protocol ImageManagerDelegate

- (void) didUpdateImage:(UIImage *)img animated:(BOOL)_animated;
- (void) willUpdateImage;

@end