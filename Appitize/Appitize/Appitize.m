
//
//  EventCaptureApplication.m
//  Appitize
//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import "Appitize.h"

#import <objc/runtime.h>

@interface UIApplication (AppitizeEventRecording)

- (void) fakeSendEvent:(UIEvent*)event;

@end


@implementation UIApplication (AppitizeEventRecording)

- (void) fakeSendEvent:(UIEvent*)event
{
    NSLog(@"Event: %@", event);
    
    // Note this won't endlessly loop as this will have been swizzeled...
    [self fakeSendEvent:event];
}


@end


@implementation Appitize

+ (Appitize *) sharedEngine;
{
    static Appitize* appitizeEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appitizeEngine = [[Appitize alloc] init];
    });
    return appitizeEngine;
}

- (void) initializeWithApplication: (UIApplication*) application
{
    NSLog(@"initializeWithApplication:%@", application);
    Method myReplacementMethod =
    class_getInstanceMethod([UIApplication class], @selector(fakeSendEvent:));
    Method applicationSendEvent =
    class_getInstanceMethod([UIApplication class], @selector(sendEvent:));
    method_exchangeImplementations(myReplacementMethod, applicationSendEvent);
    NSLog(@"Events Hooked up!");
    //[application sendEvent:nil];
}

@end
