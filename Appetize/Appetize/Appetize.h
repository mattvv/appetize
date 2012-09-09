//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Video;

@interface Appetize : NSObject

@property (nonatomic, retain) NSMutableArray *lastVideos;

+ (Appetize *) sharedEngine;

- (void) initializeWithApplication: (UIApplication*) application;

+ (NSBundle *)frameworkBundle;

- (void) addVideo: (Video*) newVideo;

@end