//
//  ZSPictureToVideo.m
//  MakeTextureToVideo
//
//  Created by zishu on 9/3/19.
//  Copyright © 2019 zishu. All rights reserved.
//

#import "ZSPictureToVideo.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation ZSPictureToVideo

#pragma mark - 多张图片合成视频

+ (void)compressedMovieWithImages:(NSArray *)images desPath:(NSString *)desPath completionHandlerOnMainThread:(void (^)(NSString *videoPath))handler {
    // 默认 每秒30帧
    CGFloat timeScale = 30;
    
    NSAssert(images.count, @"源图片数组为空");
    
    
    // 默认 720 * 720
    CGSize targetSize = CGSizeMake(720, 720);
    
    NSLog(@"开始合成");
    //NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
    NSString *moviePath = desPath;
    
    NSError *error =nil;
    
    //    NSLog(@"moviePath is ->%@",moviePath);
    unlink([desPath UTF8String]);
    //    NSLog(@"unlink 之后  moviePath is ->%@",moviePath);
    
    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath] fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings= [NSDictionary dictionaryWithObjectsAndKeys:
                                  AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:targetSize.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:targetSize.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor
                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                    sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if (![videoWriter canAddInput:writerInput]) return;
    
    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame = 0;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData]) {
            if(frame >= images.count) {
                [writerInput markAsFinished];
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (handler) {
                            handler(moviePath);
                        }
                    });
                }];
                break;
            }
            
            CVPixelBufferRef buffer =NULL;
            
            int idx = frame;
            //            NSLog(@"idx==%d",idx);
            
            buffer =(CVPixelBufferRef)[self pixelBufferFromCGImage:[[images objectAtIndex:idx] CGImage] size:targetSize];
            
            if (buffer) {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,timeScale)]) {
                    //                    NSLog(@"FAIL");
                    
                } else {
                    //                    NSLog(@"OK");
                    CFRelease(buffer);
                }
            }
            frame++;
        }
    }];
}

#pragma mark - UIImage转buffer
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer =NULL;
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata !=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context,CGRectMake(0,0,size.width,size.height),image);//CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}



@end
