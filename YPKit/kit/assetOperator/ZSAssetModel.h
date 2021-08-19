//
//  ZSAssetModel.h
//  ZSAssetOperator
//
//  Created by zishu on 9/11/19.
//  Copyright © 2019 zishu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, ZSAssetType) {
    ZSAssetType_Photo = 1,
    ZSAssetType_Video = 2,
};


NS_ASSUME_NONNULL_BEGIN

@interface ZSAssetModel : NSObject

/** asset的类别 */
@property (nonatomic, assign) ZSAssetType assetType;

/** asset的标识 */
@property (nonatomic, copy) NSString *localIdentifier;

/**
 assetType == photo, imagew为照片;
 assetType == video, imagew为视频的缩略图;
 */
@property (nonatomic, strong) UIImage *image;

/**
 assetType == photo, avAsset为空;
 assetType == video, avAsset为本地相册的视频
 你可以这样使用 AVAsset: [[AVPlayer alloc] initWithPlayerItem: [AVPlayerItem playerItemWithAsset:avAsset]]
 */
@property (nonatomic, strong) AVAsset *avAsset;

@end

NS_ASSUME_NONNULL_END
