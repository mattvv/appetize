
//
//  EventCaptureApplication.m
//  Appitize
//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import "Appitize.h"

#import <objc/runtime.h>

#import "RecordControlViewController.h"

#import "Video.h"


@interface Appitize ()

@property (nonatomic, strong) RecordControlViewController *viewController;
@property (nonatomic, weak) UIApplication *application;

//+ (NSBundle *)frameworkBundle;
- (void) addTouchOverlayForEvent:(UIEvent*)event;

@end

@interface UIApplication (AppitizeEventRecording)

- (void) fakeSendEvent:(UIEvent*)event;

@end

@implementation UIApplication (AppitizeEventRecording)

- (void) fakeSendEvent:(UIEvent*)event
{
    //NSLog(@"Event: %@", event);
    
    [[Appitize sharedEngine] addTouchOverlayForEvent: event];

    // Note this won't endlessly loop as this will have been swizzeled...
    [self fakeSendEvent:event];
}


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
    lastVideos = [[NSMutableArray alloc]init];
    
    NSLog(@"initializeWithApplication:%@", application);
    Method myReplacementMethod =
    class_getInstanceMethod([UIApplication class], @selector(fakeSendEvent:));
    Method applicationSendEvent =
    class_getInstanceMethod([UIApplication class], @selector(sendEvent:));
    method_exchangeImplementations(myReplacementMethod, applicationSendEvent);
    NSLog(@"Events Hooked up!");
    
    Video *video = [[Video alloc]init];
    video.name = @"Sept 8, 2012, 8:42PM";
    video.time = @"2:52 minutes";
    
}

- (void) addTouchOverlayForEvent:(UIEvent*)event
{
    
    UITouch *touch = [event.allTouches anyObject];

    if (self.viewController == nil)
    {
        RecordControlViewController *viewController = [[RecordControlViewController alloc] init];

        self.viewController = viewController;
        
        id<UIApplicationDelegate> myDelegate = [UIApplication sharedApplication].delegate;
        UIWindow *window = myDelegate.window;
        
//        viewController.view.center = window.center;
        
        [window addSubview:self.viewController.view];
    }

    
    if (touch.phase == UITouchPhaseBegan)
    {
        UIImage *touchDownImage = [UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"finger_press1" ofType:@"png"]];
        UIImage *touchRipple1Image = [UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"finger_press2" ofType:@"png"]];
        UIImage *touchRipple2Image = [UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"finger_press3" ofType:@"png"]];
        if (touchDownImage && touchRipple1Image && touchRipple2Image)
        {
            UIImageView *touchDownImageView = [[UIImageView alloc] initWithImage:touchDownImage];
            UIImageView *touchRipple1ImageView = [[UIImageView alloc] initWithImage:touchRipple1Image];
            UIImageView *touchRipple2ImageView = [[UIImageView alloc] initWithImage:touchRipple2Image];
            
            NSArray *imageViews = @[touchDownImageView, touchRipple1ImageView, touchRipple2ImageView];

            id<UIApplicationDelegate> myDelegate = [UIApplication sharedApplication].delegate;
            UIWindow *window = myDelegate.window;
            CGPoint point = [touch locationInView:window];
            
            for (UIImageView *imageView in imageViews)
            {
                imageView.center = point;
                imageView.alpha = 0;
                [window addSubview:imageView];
            }
            
            const float AnimationInterval = 0.0875f;
            [UIView animateWithDuration:AnimationInterval
                             animations:^{
                                 touchDownImageView.alpha = 1.0;
                                 touchRipple1ImageView.alpha = 0.1;
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:AnimationInterval animations:^{
                                     touchDownImageView.alpha = 0.0;
                                     touchRipple1ImageView.alpha = 1.0;
                                     touchRipple2ImageView.alpha = 0.1;
                                 } completion:^(BOOL finished) {
                                     [UIView animateWithDuration:AnimationInterval animations:^{
                                         touchDownImageView.alpha = 0.0;
                                         touchRipple1ImageView.alpha = 0.0;
                                         touchRipple2ImageView.alpha = 1.0;
                                     } completion:^(BOOL finished) {
                                         for (UIImageView *imageView in imageViews)
                                         {
                                             [imageView removeFromSuperview];
                                         }
                                     }];
                                 }];
                             }];
        }
        else
        {
            NSLog(@"WARNING: You haven't configured your bundle correctly. Please see http://appetize.co for details!");
        }
    }
}

// Load the framework bundle.
+ (NSBundle *)frameworkBundle
{
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Appitize.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}


@end
