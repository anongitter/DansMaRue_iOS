/*
 * JSonResponseHandler.h
 * TendanceSante
 *
 * Created by Olivier Bonal on 13/11/09.
 * Copyright 2009 C4M Prod. All rights reserved.
 *
 */


@protocol JSonResponseHandler

- (void) parseJSonResponse:(NSString*)jsonResponse;
- (void) jsonRequestFailed:(NSError *)error;
@end
