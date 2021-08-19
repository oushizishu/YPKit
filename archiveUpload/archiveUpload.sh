#!/bin/bash
#Use:命令行进入目录直接执行sh APP_BUILD.sh即可完成打包安装

#  ./archive.sh ~/Desktop/xcode/unity1217-1 1218.1
 #-------------------------脚本配置信息--------------------------------------------
 
 echo "~~~~~~~~~~~~~~~~检查脚本参数~~~~~~~~~~~~~~~~"
 
 if ["$1" == ""];then
    echo "第1各参数为工程主目录, 不能为空"
    exit 1
 else
    echo "工程主目录: $1"
 fi
 
 if ["$2" == ""];then
    echo "第2个参数是build version, 不能为空, 设置格式, 日期.数字(一天内自增), 例如 1218.1, 1218.2"
    exit 1
 else
    echo "build version: $2"
 fi
 
 # 配置一些变量
 
 #工程目录
 #BASE_PROJECT=$(dirname $1)
 BASE_PROJECT=$1
 
 # app 版本
 MARKETING_VERSION=0.2
 
 # build版本 第二个参数, 设置格式, 日期.数字(一天内自增), 例如 1218.1, 1218.2
 CURRENT_PROJECT_VERSION=$2
 
 #工程名称
 PROJECT_NAME="Test"

 #编译模式 工程默认有 Debug Release
 CONFIGURATION_TARGET=Debug
 
 #代码签名, 自动签名
 CODE_SIGN="iPhone Developer"
 
 #证书配置文件, 自动签名
 PROFILE="Automatic"
 
 # see: https://appstoreconnect.apple.com/access/api, 用于上传ipa
 # 前置步骤: 需要把私钥下载到 用户目录新建一个private_keys 的目录下(即: ~/private_keys/xx.p8),否则会报错
 API_KEY=""
 API_ISSUER_KEY=""
 
 #archi
 VALID_ARCHS="arm64 arm64e armv7s"

 #输出路径
 BUILDPATH=~/Desktop/xcode/output
 
 #导出ipa 所需plist
 ADHOCExportOptionsPlist=$(pwd)/ExportOptions.plist

 #archive Path
 ARCHIVEPATH=${BUILDPATH}/archive/${PROJECT_NAME}_$(date +%F-%T)/${PROJECT_NAME}.xcarchive
 
 #ipa Path
 IPAPATH=${BUILDPATH}/ipa/ipa_$(date +%F-%T)/
 
 echo "~~~~~~~~~~~~~~~~开始执行脚本~~~~~~~~~~~~~~~~"
 
 #---------------------------------------------------------------------------------
 if [ ! -d ${BASE_PROJECT} ]; then
        echo ${BASE_PROJECT}"不存在!"
        exit 1
 else
        echo "工程目录--->>"${BASE_PROJECT}
        cd ${BASE_PROJECT}
 fi

 echo "~~~~~~~~~~~~~~~~开始清理~~~~~~~~~~~~~~~~~~~"
 # 清理 避免出现一些莫名的错误
 xcodebuild clean -workspace ${PROJECT_NAME}.xcworkspace -scheme ${PROJECT_NAME} -configuration ${CONFIGURATION_TARGET}

 echo "~~~~~~~~~~~~~~~~开始解锁~~~~~~~~~~~~~~~~~~~"
 #执行解锁命令
 ln -s ~/Library/Keychains/login.keychain-db ~/Library/Keychains/login.keychain
 security unlock -p <password> /Users/<username>/Library/Keychains/login.keychain

 echo "~~~~~~~~~~~~~~~~开始编译构建~~~~~~~~~~~~~~~~~~~"
 
 #开始构建 配置一些 build setting
 #ONLY_ACTIVE_ARCH=NO ENABLE_BITCODE=NO VALID_ARCHS="arm64 arm64e armv7s"
 # MARKETING_VERSION=0.2
 # CURRENT_PROJECT_VERSION=1217.1
 xcodebuild archive -workspace ${PROJECT_NAME}.xcworkspace -scheme ${PROJECT_NAME} -archivePath ${ARCHIVEPATH} ONLY_ACTIVE_ARCH=NO ENABLE_BITCODE=NO VALID_ARCHS="${VALID_ARCHS}" MARKETING_VERSION=${MARKETING_VERSION} CURRENT_PROJECT_VERSION=${CURRENT_PROJECT_VERSION} -configuration ${CONFIGURATION_TARGET} CODE_SIGN_IDENTITY="${CODE_SIGN}" PROVISIONING_PROFILE="${PROFILE}"

 echo "~~~~~~~~~~~~~~~~检查是否编译构建成功~~~~~~~~~~~~~~~~~~~"
 # xcarchive 实际是一个文件夹不是一个文件,使用 -d 判断
 if [ -d "$ARCHIVEPATH" ]
 then
        echo "编译构建成功 🎉🎉🎉🎉🎉"
 else
        echo "编译构建失败......"
        #rm -rf ${ARCHIVEPATH}
 exit 1
 fi
 endTime=`date +%s`
 ArchiveTime="构建编译时间$[ endTime - beginTime ]秒"

 echo "~~~~~~~~~~~~~~~~导出ipa~~~~~~~~~~~~~~~~~~~"

 beginTime=`date +%s`

 xcodebuild -exportArchive -archivePath ${ARCHIVEPATH} -exportPath ${IPAPATH} -exportOptionsPlist ${ADHOCExportOptionsPlist} CODE_SIGN_IDENTITY="${CODE_SIGN}" PROVISIONING_PROFILE="${PROFILE}"

 echo "~~~~~~~~~~~~~~~~检查是否成功导出  ipa~~~~~~~~~~~~~~~~~~~"
 IPAPATH=${IPAPATH}/${PROJECT_NAME}.ipa
 if [ -f "$IPAPATH" ]
 then
         echo "导出ipa成功 🎉🎉🎉🎉🎉"

 else
         echo "导出ipa失败 ......"
 # 结束时间
 endTime=`date +%s`
        echo "$ArchiveTime"
        echo "导出ipa时间$[ endTime - beginTime ]秒"
 exit 1
 fi

 
 echo "~~~~~~~~上传ipa到test flight~~~~~~~~~~~"
 
 # 上传ipa
 xcrun altool --upload-app -f ${IPAPATH} -t iOS --apiKey ${API_KEY} --apiIssuer ${API_ISSUER_KEY} --verbose

 echo "~~~~~~~~ 上传ipa,  end  ~~~~~~~~~~~"
