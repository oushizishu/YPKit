//
//  ZSPictureToVideo.h
//  MakeTextureToVideo
//
//  Created by zishu on 9/3/19.
//  Copyright © 2019 zishu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZSPictureToVideo : NSObject

// 默认 每秒30帧
// CGFloat timeScale = 30;

// 默认 视频尺寸 720 * 720
// CGSize targetSize = (360, 360)
/**
 多张图片合成一个视频
 
 @param images 图片数组
 @param desPath 目标路径, 存放合成后的视频的路径
 @param handler handler description
 */
+ (void)compressedMovieWithImages:(NSArray *)images desPath:(NSString *)desPath completionHandlerOnMainThread:(void (^)(NSString *videoPath))handler;

@end

NS_ASSUME_NONNULL_END

