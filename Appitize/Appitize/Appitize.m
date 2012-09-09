
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

- (void) addTouchOverlayForEvent:(UIEvent*)event;

@end

@implementation UIApplication (AppitizeEventRecording)

- (void) fakeSendEvent:(UIEvent*)event
{
    NSLog(@"Event: %@", event);
    
    [self addTouchOverlayForEvent: event];

    // Note this won't endlessly loop as this will have been swizzeled...
    [self fakeSendEvent:event];
}

- (void) addTouchOverlayForEvent:(UIEvent*)event
{
    
    UITouch *touch = [event.allTouches anyObject];
    
    if (touch.phase == UITouchPhaseBegan)
    {
        UIImage *touchImage = [UIImage imageNamed:@"first"];
        UIImageView *touchImageView = [[UIImageView alloc] initWithImage:touchImage];
        
        id<UIApplicationDelegate> myDelegate = [UIApplication sharedApplication].delegate;
        UIWindow *window = myDelegate.window;

        CGPoint point = [touch locationInView:window];
        
        touchImageView.center = point;
        touchImageView.alpha = 0;
        [window addSubview:touchImageView];
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             touchImageView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.25f animations:^{
                                 touchImageView.alpha = 0.0;
                             } completion:^(BOOL finished) {
                                 [touchImageView removeFromSuperview];
                             }];

                         }];
        
    }
}


@end


@interface Appitize ()

@property (nonatomic, weak) UIApplication *application;

@end

@implementation Appitize

@synthesize application = _application;
@synthesize lastVideos;

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
    self.application = application;
    
    NSLog(@"initializeWithApplication:%@", application);
    Method myReplacementMethod =
    class_getInstanceMethod([UIApplication class], @selector(fakeSendEvent:));
    Method applicationSendEvent =
    class_getInstanceMethod([UIApplication class], @selector(sendEvent:));
    method_exchangeImplementations(myReplacementMethod, applicationSendEvent);
    NSLog(@"Events Hooked up!");
}

@end
