# 1. archiveUpload
xcode11, 使用xcodebuild 构建.xcarchive 和 导出.ipa, 使用xrun altool 上传至test flight

# 2. shell需要配置的参数
 - PROJECT_NAME, 工程名字
 - MARKETING_VERSION, app版本号
 - CONFIGURATION_TARGET, Debug 或者 Release
 - VALID_ARCHS, 导出的cpu架构, 可选配置
 - API_KEY 和 API_ISSUER_KEY, 用于上传ipa到test flight, 如果只需要导出ipa, 可以不配置
 > API_KEY 和 API_ISSUER_KEY 在 : 用户和访问 > 秘钥 > 生成秘钥 , 需要把私钥下载到 用户目录新建一个private_keys 的目录下(即: ~/private_keys/xx.p8),否则会报错
 
# 3. 使用示例

```
./archiveUpload.sh <项目路径> <build version>

例如:
./archiveUpload.sh ~/Desktop/Demo 1218.1

Tip: 1. 第一个参数为工程的路径, 此路径下需要有 .xcworkspace 文件
     2. 第二个参数build version只是为了上传test flight, 如果只为了导ipa, 可以自行修改脚本文件.        
```

# 4. Note
此脚本默认使用```.xcworkspace```进行构建, 如果工程没用使用pod, 就只有```.xcodeproj```文件, 没有 ```.xcworkspace ```文件, 需要自行改动脚本里面```xcodebuild```后面的参数.

# 5. 简书
[链接](https://www.jianshu.com/p/eef05892638d)
