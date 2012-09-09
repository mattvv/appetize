//
//  AppDelegate.h
//  DemoApp
//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenRecorder.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ScreenRecorder *screenRecorder;

@end
