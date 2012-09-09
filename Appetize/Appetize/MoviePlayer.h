//
//  MoviePlayer.h
//  Appetize
//
//  Created by Matt Van Veenendaal on 9/8/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Video.h"

@interface MoviePlayer : NSObject

@property (nonatomic, retain) MPMoviePlayerViewController * mMPVC;

- (void) playVideo: (Video*)video withView: (UIView *)view;

@end
