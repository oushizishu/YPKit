//
//  MakeTextureInstance.m
//  MakeTextureToVideo
//
//  Created by zishu on 9/3/19.
//  Copyright © 2019 zishu. All rights reserved.
//

#import "MakeTextureInstance.h"

#import <GLKit/GLKit.h>

@interface MakeTextureInstance()

@property (nonatomic) NSMutableArray <UIImage *> *images;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation MakeTextureInstance

+ (instancetype)shared {
    static MakeTextureInstance *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super alloc] init];
    });
    return _sharedSingleton;
}

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
        
        for (int i = 0; i < 50; i++) {
            NSString *imageName = [NSString stringWithFormat:@"%02d.jpg",i];
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
            NSAssert((image != nil), @"图片加载失败");
            [_images addObject:image];
        }
    }
    return _images;
}

- (void)startMakeTexture {
    self.currentIndex = 0;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    if (self.initRecorderCallback != nil) {
        self.initRecorderCallback(self.images.firstObject.size);
    }
    [self loadTextureFromImages];
}

- (void)requestNextFrame {
    
    self.currentIndex += 1;
    [self loadTextureFromImages];
}

- (void)loadTextureFromImages {
    // 消除 UIKit 和 GLKit 的坐标差异，否则会上下颠倒
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    if (self.currentIndex < self.images.count) {
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[self.images[self.currentIndex] CGImage]
                                                                   options:options
                                                                     error:NULL];
        if (self.recordFrameCallback != nil) {
            self.recordFrameCallback(textureInfo.name);
        }
    }
    else {
        if (self.stopRecorderCallback != nil) {
            self.stopRecorderCallback();
        }
    }
}




@end
