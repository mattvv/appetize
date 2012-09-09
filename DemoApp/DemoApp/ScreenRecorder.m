//
//  ScreenRecorder.m
//  DemoApp
//
//  Created by Matt Van Veenendaal on 9/8/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import "ScreenRecorder.h"
#import <QuartzCore/QuartzCore.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation ScreenRecorder

@synthesize videoWriter;
@synthesize writerInput;
BOOL recording = NO;

- (void)startRecording {
    if (recording)
        [self stopRecording];
    
    [self initCapture];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
}

- (void)stopRecording {
    [writerInput markAsFinished];
    //[videoWriter endSessionAtSourceTime:…]; optional
    //todo: call on background thread;
    [videoWriter finishWriting];
}

- (void)initCapture {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    
	
    NSString* recorderFilePath = [NSString stringWithFormat:@"%@/%@.mov", DOCUMENTS_FOLDER, @"recording"];
    NSError *error = nil;
    videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:recorderFilePath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
//    CGFloat width = 320;
//    CGFloat height = 480;
//
//    if (keyWindow.bounds.size.width) {
//        width = keyWindow.bounds.size.width;
//        height = keyWindow.bounds.size.height;
//    } else {
//        //todo: support for ipad
//        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
//            width = 640;
//            height = 960;
//        }
//    }
    
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithFloat:keyWindow.bounds.size.width], AVVideoWidthKey,
                                   [NSNumber numberWithFloat:keyWindow.bounds.size.height], AVVideoHeightKey,
                                   nil];
    writerInput = [AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
}


- (UIImage *)getCurrentImage {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
	UIGraphicsBeginImageContext(keyWindow.bounds.size);
    for (UIWindow *w in [[UIApplication sharedApplication] windows])
    {
        [w.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//OpenGL get screenshot
//- (UIImage*) screenshotUIImageFromHeight:(int)height
//{
//    CGSize displaySize  = [self displaySizeInPixels];
//    CGSize winSize    = [self winSizeInPixels];
//    
//    //Create buffer for pixels
//    GLuint bufferLength = displaySize.width * displaySize.height * 4;
//    GLubyte* buffer = (GLubyte*)malloc(bufferLength);
//    
//    //Read Pixels from OpenGL
//    glReadPixels(0, height, displaySize.width, displaySize.height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
//    //Make data provider with data.
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
//    
//    displaySize.height -= height;
//    winSize.height -= height;
//    
//    //Configure image
//    int bitsPerComponent = 8;
//    int bitsPerPixel = 32;
//    int bytesPerRow = 4 * displaySize.width;
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
//    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
//    CGImageRef iref = CGImageCreate(displaySize.width, displaySize.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
//    
//    uint32_t* pixels = (uint32_t*)malloc(bufferLength);
//    CGContextRef context = CGBitmapContextCreate(pixels, winSize.width, winSize.height, 8, winSize.width * 4, CGImageGetColorSpace(iref), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    
//    CGContextTranslateCTM(context, 0, displaySize.height);
//    CGContextScaleCTM(context, 1.0f, -1.0f);
//    
//    switch (self.deviceOrientation)
//    {
//        case CCDeviceOrientationPortrait: break;
//        case CCDeviceOrientationPortraitUpsideDown:
//            CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(180));
//            CGContextTranslateCTM(context, -displaySize.width, -displaySize.height);
//            break;
//        case CCDeviceOrientationLandscapeLeft:
//            CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(-90));
//            CGContextTranslateCTM(context, -displaySize.height, 0);
//            break;
//            
//        case CCDeviceOrientationLandscapeRight:
//            CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(90));
//            CGContextTranslateCTM(context, displaySize.height-displaySize.width, -displaySize.height);
//            break;
//    }
//    
//    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, displaySize.width, displaySize.height), iref);
//    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//    UIImage *outputImage = [[[UIImage alloc] initWithCGImage:imageRef] autorelease];
//    
//    //Dealloc
//    CGImageRelease(imageRef);
//    CGDataProviderRelease(provider);
//    CGImageRelease(iref);
//    CGColorSpaceRelease(colorSpaceRef);
//    CGContextRelease(context);
//    free(buffer);
//    free(pixels);
//    
//    return outputImage;
//}

@end
