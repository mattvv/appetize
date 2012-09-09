
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
#import "ScreenRecorder.h"
#import "Video.h"
#import "RecordCell.h"


@interface Appitize ()

@property (nonatomic, strong) RecordControlViewController *viewController;
@property (nonatomic, strong) ScreenRecorder *recorder;
@property (nonatomic, weak) UIApplication *application;

//+ (NSBundle *)frameworkBundle;
- (void) showRecordingControlViewController;
- (void) addTouchOverlayForEvent:(UIEvent*)event;
- (IBAction)handleStopRecordingGesture:(UIGestureRecognizer *) sender;

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
        
        //todo: This should be removed.
        [RecordCell _keepAtLinkTime];
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
    
    self.recorder = [[ScreenRecorder alloc] init];

//    Video *video = [[Video alloc]init];
//    video.name = @"Sept 8, 2012, 8:42PM";
//    video.time = @"2:52 minutes";
//    [lastVideos addObject:video];
    
}

- (void) showRecordingControlViewController
{
    if (self.viewController != nil)
    {
        [self.viewController.view removeFromSuperview];
        self.viewController = nil;
    }
    
    RecordControlViewController *viewController = [[RecordControlViewController alloc] init];
    viewController.recorder = self.recorder;
    self.viewController = viewController;


    id<UIApplicationDelegate> myDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = myDelegate.window;

    self.viewController.view.alpha = 0.0f;
    [window addSubview:self.viewController.view];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.viewController.view.alpha = 1.0f; 
    }];
}

- (void) addTouchOverlayForEvent:(UIEvent*)event
{
    UITouch *touch = [event.allTouches anyObject];

    if (self.viewController == nil)
    {
        [self showRecordingControlViewController];

        UITapGestureRecognizer *stopRecordingGesture = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self action:@selector(handleStopRecordingGesture:)];
        stopRecordingGesture.numberOfTapsRequired = 2;
        stopRecordingGesture.numberOfTouchesRequired = 1;
        stopRecordingGesture.enabled = YES;
        id<UIApplicationDelegate> myDelegate = [UIApplication sharedApplication].delegate;
        UIWindow *window = myDelegate.window;
        [window addGestureRecognizer:stopRecordingGesture];

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

- (IBAction)handleStopRecordingGesture:(UIGestureRecognizer *) sender
{
    NSLog(@"handleStopRecordingSwipe...");
    // Make this prettier ... someday
    if (self.viewController.recorder.recording == YES)
    {
        [self.viewController.recorder stopRecording];
        [self showRecordingControlViewController];
    }
    // Guard against loading this again if already loaded...
    else if (self.viewController.view.superview == nil)
    {
        [self showRecordingControlViewController];
    }
}

#pragma mark - Add Video

- (void) addVideo: (Video*) newVideo
{
    [lastVideos insertObject:newVideo atIndex:0];
    // Hack!!
    [self.viewController reloadData];
    
}

@end
