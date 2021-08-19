//
//  MakeTextureInstance.h
//  MakeTextureToVideo
//
//  Created by zishu on 9/3/19.
//  Copyright © 2019 zishu. All rights reserved.
//

// 用来生成texture

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MakeTextureInstance : NSObject

+ (instancetype)shared;

- (void)startMakeTexture;

- (void)requestNextFrame;

// recorder init, imageSize: 图片原始的size
@property(nonatomic, copy) void (^initRecorderCallback)(CGSize imageSize);
// 接受纹理, texture ID
@property(nonatomic, copy) void (^recordFrameCallback)(GLuint);

//@property(nonatomic, copy) void (^startRecorderCallback)(void);
@property(nonatomic, copy) void (^stopRecorderCallback)(void);

@end

NS_ASSUME_NONNULL_END
