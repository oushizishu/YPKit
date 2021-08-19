//
//  ZSTextureToPicture.m
//  MakeTextureToVideo
//
//  Created by zishu on 9/3/19.
//  Copyright © 2019 zishu. All rights reserved.
//

#import "ZSTextureToPicture.h"

#import <GLKit/GLKit.h>
#import "ZSPictureToVideo.h"
#import "MakeTextureInstance.h"

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;

@interface ZSTextureToPicture() <GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
// 顶点数组
@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic) NSMutableArray <UIImage *>* imageList;
// 保存 合成后的视频 的路径
@property (nonatomic) NSString *destPath;
// 图片原始尺寸
@property (nonatomic) CGSize imageSize;


@end

@implementation ZSTextureToPicture

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setCallback];
    self.imageList = [NSMutableArray array];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 40, 40)];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}

- (void)start {
    [[MakeTextureInstance shared] startMakeTexture];
}

- (void)dealloc {
    //    if ([EAGLContext currentContext] == self.glkView.context) {
    //        [EAGLContext setCurrentContext:nil];
    //    }
    // C语言风格的数组，需要手动释放
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}

- (void)setCallback {
    MakeTextureInstance *textureIns = [MakeTextureInstance shared];
    __weak typeof(self) weakSelf = self;
    
    // 此地址为示例地址, 如果你使用此demo, 需要换成你自己的地址, 或者换成沙盒地址
//    __block NSString *desPath = @"/Users/qmnl-01/Desktop/shoubiao.mp4";
    
    // 更换为沙盒地址
    __block NSString *desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.mp4"];
    textureIns.initRecorderCallback = ^(CGSize imageSize) {
        [weakSelf commonInitWithSize:imageSize destPath:desPath];
    };
    textureIns.recordFrameCallback = ^(GLuint textId) {
        // 纹理 -> 图片
        [weakSelf setTextureID:textId];
    };
    
    textureIns.stopRecorderCallback = ^{
        // 图片 -> 视频
        [weakSelf makeVideoFromImages];
    };
    
}

// 纹理 -> 图片
- (void)commonInitWithSize:(CGSize)imageSize destPath:(NSString *)destPath {
    
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    self.imageSize = imageSize;
    self.destPath = destPath;
    
    NSLog(@"zishu: size: %@, dest: %@ ", NSStringFromCGSize(imageSize), self.destPath);
    
    // 与unity共享一个OpenGL的context, 如果获取不到, 则直接报错
    // unity里已经创建了context, 传过来的texture id也是基于此context
    EAGLContext *context = [EAGLContext currentContext];
    
    if (context == nil) {
        NSAssert(0, @"无法获取当前的contenx");
        
        return;
    }
    
    // 创建顶点数组
    self.vertices = malloc(sizeof(SenceVertex) * 4); // 4 个顶点
    
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上角
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下角
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}}; // 右上角
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}}; // 右下角
    
    // 初始化 GLKView
    CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.glkView = [[GLKView alloc] initWithFrame:frame context:context];
    self.glkView.backgroundColor = [UIColor clearColor];
    self.glkView.delegate = self;
    
    [self.view addSubview:self.glkView];
    // 初始化 baseEffect
    self.baseEffect = [[GLKBaseEffect alloc] init];
    // 为了避免不必要的内存数据紊乱, 先清空数组
    [self.imageList removeAllObjects];
    
    //    [[NSFileManager defaultManager] createDirectoryAtPath:DOCUMENT(@"uImages") withIntermediateDirectories:NO attributes:nil error:nil];
}

//static int a = 0;
- (void)setTextureID:(GLuint)textureID {
    self.baseEffect.texture2d0.name = textureID;
    [self.glkView display];
    UIImage *image = self.glkView.snapshot;
    NSData *jpegData = UIImageJPEGRepresentation(image, 0.8); // 91570byte
    UIImage *newImage = [[UIImage alloc] initWithData:jpegData];
    [self.imageList addObject:newImage];
    
    [[MakeTextureInstance shared] requestNextFrame];
    //    NSString *fileName = [NSString stringWithFormat:@"uImages/%d.jpg", a];
    //    a++;
    //    [jpegData writeToFile:DOCUMENT(fileName) atomically:YES];
    
}

// 图片数组 -> 视频
- (void)makeVideoFromImages {
    NSLog(@"%s", __func__);
    
    __weak typeof(self) weakSelf = self;
    [ZSPictureToVideo compressedMovieWithImages:self.imageList desPath:self.destPath completionHandlerOnMainThread:^(NSString * _Nonnull videoPath) {
        __strong typeof(self) strongSelf = weakSelf;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSLog(@"开始合成 - 结束");
        NSLog(@"zishu: makevideo: 22time: %f dest: %@, videpath:%@", time, strongSelf.destPath, videoPath);
        if ([videoPath isEqualToString:strongSelf.destPath]) {
//            [[IOSAPPInterface shared] recoderStateChange:RecordStateSuccess];
        }
    }];
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.baseEffect prepareToDraw];
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    // 创建顶点缓存
    GLuint vertexBuffer;
    // 1 2 3 4 5 6 7 的步骤, 不要搞错了 !!! by: zihsu
    // 1：生成
    glGenBuffers(1, &vertexBuffer);
    // 2：绑定
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    // 3：缓存数据
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    // 4：启用或禁用
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // 5：设置指针
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    // 设置纹理数据
    // 4：启用或禁用
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    // 5：设置指针
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    // 开始绘制
    // 6：绘图
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 删除顶点缓存
    // 7：删除
    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
}



@end
