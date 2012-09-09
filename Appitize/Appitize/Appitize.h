//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Appitize : NSObject

@property (nonatomic, retain) NSMutableArray *lastVideos;

+ (Appitize *) sharedEngine;

- (void) initializeWithApplication: (UIApplication*) application;

@end