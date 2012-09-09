//
//  ScreenRecorder.h
//  DemoApp
//
//  Created by Matt Van Veenendaal on 9/8/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ScreenRecorder : NSObject

@property (nonatomic, retain) AVAssetWriter *videoWriter;
@property (nonatomic, retain) AVAssetWriterInput* writerInput;


- (void)startRecording;
- (void)stopRecording;

@end
