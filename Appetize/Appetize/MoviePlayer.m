//
//  MoviePlayer.m
//  Appetize
//
//  Created by Matt Van Veenendaal on 9/8/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "MoviePlayer.h"

@implementation MoviePlayer

@synthesize mMPVC;

- (void) playVideo: (Video*)video withView: (UIView *)view {
    mMPVC = [[MPMoviePlayerViewController alloc] initWithContentURL:video.assetURL];
    
    [mMPVC.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [mMPVC.moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:mMPVC.moviePlayer];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [mMPVC.view setFrame:keyWindow.bounds];
    
    [view addSubview:mMPVC.view];
    [mMPVC.moviePlayer play];

}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    [mMPVC.moviePlayer stop];
    [mMPVC.moviePlayer.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:mMPVC.moviePlayer];
}

@end
