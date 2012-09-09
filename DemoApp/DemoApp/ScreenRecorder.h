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
@property (nonatomic, retain) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int time;

- (void)startRecording;
- (void)stopRecording;
- (void)addImage;

@end
