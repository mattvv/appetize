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
#import <AssetsLibrary/AssetsLibrary.h>
#import "Appitize.h"
#import "Video.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation ScreenRecorder

@synthesize videoWriter;
@synthesize writerInput;
@synthesize adaptor;
@synthesize timer;
@synthesize time;
@synthesize fileURL;
@synthesize startTime;

BOOL recording = NO;

- (void)startRecording {
    time = 0;
    if (recording)
        [self stopRecording];
    
    recording = YES;
    startTime = [NSDate date];
    
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
    while (!adaptor.assetWriterInput.readyForMoreMediaData) {
        NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
    }
    
    if (!recording)
        return;
    
    CVPixelBufferRef buffer = NULL;
    buffer = [self pixelBufferFromCGImage:[[self getCurrentImage] CGImage]];
    [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(time, 600)];
    time += 30; //todo: calculate this per interval
}

- (void)stopRecording {
    if (!recording)
        return;
    
    //todo UIActivity Indicator
    
    recording = NO;
    [timer invalidate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [writerInput markAsFinished];
        [videoWriter finishWriting];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveToPhotoAlbumn];
        });
        
    });
}

- (void)saveToPhotoAlbumn {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *outputURL = [NSURL URLWithString:fileURL];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    NSDate *endTime = [NSDate date];
                    NSTimeInterval length = [endTime timeIntervalSinceDate:startTime];
                    
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"MMM dd, yyyy, HH:mm"];
                    
                    Video *video = [[Video alloc]init];
                    video.assetURL = assetURL;
                    int minutes = floor(((int)length % (1000*60*60)) / (1000*60));
                    int seconds = floor((((int)length % (1000*60*60)) % (1000*60)) / 1000);

                    if (minutes) {
                        video.time = [NSString stringWithFormat:@"%d:%d minutes", minutes,seconds];
                        video.mainLength = [NSString stringWithFormat:@"00:%d:%d", minutes,seconds];
                    } else {
                        video.time = [NSString stringWithFormat:@"0:%d minutes", seconds];
                        video.mainLength = [NSString stringWithFormat:@"00:00:%d", seconds];
                    }
                    video.name = [format stringFromDate:startTime];
                    
                    Appitize *appitize = [Appitize sharedEngine];
                    [appitize.lastVideos addObject:video];
                    //todo: show start view
                }
            });
        }];
    }
}

- (void)initCapture {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
    //todo: timestamp
    NSString * timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSLog(@"%@", timestamp);
    fileURL = [NSString stringWithFormat:@"%@/%@.mov", DOCUMENTS_FOLDER, timestamp];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL])
        [[NSFileManager defaultManager] removeItemAtPath:fileURL error:nil];
    
    NSError *error = nil;
    videoWriter = [[AVAssetWriter alloc] initWithURL:
                   [NSURL fileURLWithPath:fileURL] fileType:AVFileTypeQuickTimeMovie
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
