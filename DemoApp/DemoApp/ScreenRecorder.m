//
//  ScreenRecorder.m
//  DemoApp
//
//  Created by Matt Van Veenendaal on 9/8/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import "ScreenRecorder.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation ScreenRecorder

@synthesize videoWriter;
@synthesize writerInput;
@synthesize adaptor;
@synthesize timer;
@synthesize time;

BOOL recording = NO;

- (void)startRecording {
    time = 0;
    if (recording)
        [self stopRecording];
    
    [self initCapture];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    //convert uiimage to CGImage.
    //use 0.003 after i perfect
    timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                     target:self
                                   selector:@selector(addImage)
                                   userInfo:nil
                                    repeats:YES];
    
}

- (void)addImage {
    CVPixelBufferRef buffer = NULL;
    buffer = [self pixelBufferFromCGImage:[[self getCurrentImage] CGImage]];
    [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(time, 600)];
    time += 30; //todo: calculate this per interval
}

- (void)stopRecording {
    if (!recording)
        return;
    
    recording = NO;
    [timer invalidate];
    [writerInput markAsFinished];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [videoWriter finishWriting];
    });
}

- (void)initCapture {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
    //todo: timestamp
    NSString* recorderFilePath = [NSString stringWithFormat:@"%@/%@.mov", DOCUMENTS_FOLDER, @"recording13"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:recorderFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:recorderFilePath error:nil];
    
    NSError *error = nil;
    videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:recorderFilePath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithFloat:keyWindow.bounds.size.width], AVVideoWidthKey,
                                   [NSNumber numberWithFloat:keyWindow.bounds.size.height], AVVideoHeightKey,
                                   nil];
    writerInput = [AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings];
    
    adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:nil];
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

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, keyWindow.bounds.size.width,
                                         keyWindow.bounds.size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, keyWindow.bounds.size.width,
                                                 keyWindow.bounds.size.height, 8, 4*keyWindow.bounds.size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
