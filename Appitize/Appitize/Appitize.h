//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Appitize/EventCaptureApplication.h>

@interface Appitize : NSObject

+ (Appitize *) sharedEngine;

- (void) initializeWithApplication: (UIApplication*) application;

@end