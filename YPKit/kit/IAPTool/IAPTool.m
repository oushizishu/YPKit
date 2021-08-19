//
//  IAPVC.m
//  demo
//
//  Created by  on 2019/12/12.
//  Copyright © 2019 qmnl. All rights reserved.
//

#import "IAPTool.h"
#import <StoreKit/StoreKit.h>

@interface IAPTool () <SKPaymentQueueDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, copy) void(^payCallback)(NSString *info);
@property (nonatomic) NSString *productID;
@property (strong ,nonatomic) UIActivityIndicatorView *indicator;   // 加载指示器

@end

@implementation IAPTool
    
+ (instancetype)shared {
    static IAPTool *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super alloc] init];
    });
    return _sharedSingleton;
}
    
- (void)startIAP {
    
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    if (transactions.count > 0) {
        //检测是否有已经完成的交易, 结束掉
        SKPaymentTransaction* transaction = [transactions firstObject];
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[UIApplication sharedApplication].keyWindow addSubview:self.indicator];
}
    
- (void)destoryIAP {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    self.payCallback = nil;
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    self.indicator = nil;
}
    
- (void)payToApple:(NSString *)productID payCallback:(void(^)(NSString *string))payCallback {
    [self.indicator stopAnimating];
    [self.indicator startAnimating];
    
//    productID = @"1";
    //productID 是 在iTunes connect上配置的id
    
    if ([SKPaymentQueue canMakePayments]) {

        self.payCallback = payCallback;
        self.productID = productID;
        NSArray *productIDArray = [[NSArray alloc]initWithObjects:productID, nil];
        NSSet *sets = [[NSSet alloc]initWithArray:productIDArray];
        SKProductsRequest *sKProductsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:sets];
        sKProductsRequest.delegate = self;
        [sKProductsRequest start];
    }
    else {
        [self payCallback:nil transactionId:nil payload:nil];
    }
}
 
- (void)verifyTransactionResult:(SKPaymentTransaction *)paymentTransaction {
    // 产品id
    NSString *productID = paymentTransaction.payment.productIdentifier;
    // 交易订单号
    NSString *transID = paymentTransaction.transactionIdentifier;
    // 交易凭证信息
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [[NSData alloc] initWithContentsOfURL:receiptUrl];
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];
    
    // 支付成功的回调
    if ([self.productID isEqualToString:productID]) {
        [self payCallback:productID transactionId:transID payload:receiptString];
    }
}
    
#pragma mark -
    
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray<SKProduct *> *arr = response.products;
    if (arr.count == 0) {
        [self payCallback:nil transactionId:nil payload:nil];
    }
    else {
        for (SKProduct *product in arr) {
            // 创建票据
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
}
    
- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    /*
     case purchasing  正在购买, 已经加入队列
     case purchased   在队列里, 用户已经付款. app需要结束此交易
     case failed      交易被取消或者失败
     case restored    从购买历史中还原了此次交易, 即已经购买过了,重复购买.app需要结束此交易
     case deferred    交易还在队列里面, 但是最终状态还没有决定
     */
    for (SKPaymentTransaction *aTransaction in transactions) {
        switch (aTransaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"zishu: 正在购买...");
                break;
                
            case SKPaymentTransactionStatePurchased:
                NSLog(@"zishu: 购买成功, 然后去server端校验...");
                [queue finishTransaction:aTransaction];
                [self verifyTransactionResult:aTransaction];
                [self.indicator stopAnimating];
                
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"zishu: 购买失败了...");
                [queue finishTransaction:aTransaction];
                [self payCallback:nil transactionId:nil payload:nil];
                [self.indicator stopAnimating];
                break;
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"zishu: 已经买过一次了...");
                [queue finishTransaction:aTransaction];
                [self.indicator stopAnimating];
                break;
                
            case SKPaymentTransactionStateDeferred:
                NSLog(@"zishu: 还在等待最终的状态...");
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - private

// 当参数某个为空的时候, 即为支付失败
- (void)payCallback:(nullable NSString *)productId transactionId:(nullable NSString *)transactionId payload:(nullable NSString *)payload {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        NSMutableDictionary *dictM = [NSMutableDictionary new];
        dictM[@"productId"] = productId ?: @"";
        dictM[@"transactionId"] = transactionId ?: @"";
        dictM[@"payload"] = payload ?: @"";
        
        [strongSelf.indicator stopAnimating];
        
        NSString *json = [strongSelf tojson:dictM];
        if (strongSelf.payCallback != nil) {
            strongSelf.payCallback(json);
        }
    });
}

- (nullable NSString *)tojson:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        NSLog(@"%s, %d, 转json出错", __FILE__, __LINE__);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - getter
-(UIActivityIndicatorView *)indicator{
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _indicator.frame = [UIScreen mainScreen].bounds;
    }
    return _indicator;
}

    
@end
