//
//  IAPVC.h
//  demo
//
//  Created by xyp on 2019/12/12.
//  Copyright © 2019 qmnl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IAPTool : NSObject
    
+ (instancetype)shared;
- (void)startIAP;
- (void)destoryIAP;
- (void)payToApple:(NSString *)productID payCallback:(void(^)(NSString *string))payCallback;
    
    @end

NS_ASSUME_NONNULL_END
