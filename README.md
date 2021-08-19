# YPKit

存放一些日常写的小轮子

## 1.emoji
判断一个给定的字符串是否为 纯系统 的emoji
 
## 2. network speed
读取网卡当前获取的数据，从而计算当前的网速

## 3. asset operator
操作系统相册, 创建相册, 存图片/视频到系统相册, 从自定义的相册里删除视频/图片

在存文件 和 读取文件的时候, 加了 dispatch_semaphore_t, 以防止顺序错乱.

只有简单的创建相册/存文件/读取文件, 展示数据的ui, 我没有上传, 毕竟需求都不一样, 需要什么样子的, 最好自己写;

> 毕竟, 数据源都有了, 想咋展示还不随意吗?

## 4. IAP tool
ios 内购工具类

## 5. 纹理 -> 图片 -> 视频
#### 流程:
1. MakeTextureInstance里面读取图片, 生成texture, 加载到opengl的contenxt里面,
2. ZSTextureToPicture依据textureId取到texture, 消费该纹理, 渲染成图片后, 请求下一帧
3. 纹理生成完毕, 回调 ZSTextureToPicture, 开始合成视频

#### tips:
- 使用GLKit渲染纹理为图片, 需要实例化GLKView
