//
//  ZSAssetOperator.h
//  ZSAssetOperator
//
//  Created by zishu on 9/11/19.
//  Copyright © 2019 zishu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZSAssetOperator : NSObject

/**
 单例
 */
+ (instancetype)sharedOperator;

/**
 创建一个相册
 
 @param albumsName 相册名字
 */
- (void)createAlbums:(NSString *)albumsName;

/**
 获取相册里面的图片和视频
 */
- (NSArray <ZSAssetModel *>* _Nullable )getImagesAndVideoFromFolder;

/**
 保存图片到系统相册
 
 @param img img
 @param completionHandler 回调
 */
- (void)saveImage:(UIImage *)img  completionHandler:(nullable void(^)(BOOL success, NSError * _Nullable error))completionHandler;

/**
 保存视频到系统相册
 
 @param videoPath 视频路径
 @param completionHandler 保存后的回调
 */
- (void)saveVideoPath:(NSString *)videoPath completionHandler:(nullable void(^)(BOOL success,  NSError * _Nullable  error))completionHandler;

- (void)saveVideoPathURL:(NSURL *)videoPathURL completionHandler:(nullable void(^)(BOOL success, NSError * _Nullable error))completionHandler;

/**
 *  删除系统相册中的文件
 *  @param localIdentifier  本地相册中相片的标识
 */

/**
 *  删除系统相册中的文件
 *  @param localIdentifier  本地相册中相片的标识
 *  @param completionHandler 删除后的回调
 */
- (void)deleteFileWith:(NSString *)localIdentifier completionHandler:(void(^)(BOOL success, NSError * _Nullable error))completionHandler;

/// gif 文件保存
/// @param path path
/// @param completion 回调
+ (void)saveGif:(NSString *)path completion:(nullable void(^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
