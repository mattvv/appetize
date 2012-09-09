//
//  main.m
//  DemoApp
//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import <Appitize/Appitize.h>

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSLog(@"It Works %@",[EventCaptureApplication class]);
        return UIApplicationMain(argc, argv, @"EventCaptureApplication", NSStringFromClass([AppDelegate class]));
    }
}
