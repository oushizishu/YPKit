//
//  CheckNetworkSpeed.m
//  demo
//
//  Created by zishu on 2018/10/10.
//  Copyright © 2018年 zishu. All rights reserved.
//

#import "CheckNetworkSpeed.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@interface CheckNetworkSpeed ()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) long preByts;

@end

@implementation CheckNetworkSpeed
static CheckNetworkSpeed *obj;
+ (instancetype)networkSpeed {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[CheckNetworkSpeed alloc] init];
    });
    return obj;
}

- (void)start {
    if (!self.timer || !self.timer.isValid) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateNetworkSpeed) userInfo:nil repeats:YES];
    }
}

- (void)stop {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateNetworkSpeed {
    long latesBytes = [self getInterfaceBytes];
    NSString *string = [self transformedValue:(latesBytes - self.preByts)];
    self.preByts = latesBytes;
    NSLog(@"speed is: %@ / s", string);
}

- (long)getInterfaceBytes
{
    struct ifaddrs *ifa_list = 0, *ifa;
    
    if (getifaddrs(&ifa_list) == -1){
        return 0;
    }
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next){
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        /* Not a loopback device. */
        
        if (strncmp(ifa->ifa_name, "lo", 2)){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    NSLog(@"\n[getInterfaceBytes-Total]%d,%d",iBytes,oBytes);
    
    return iBytes;
}

- (NSString *)transformedValue:(long)value
{
    NSNumber* valueNumber = [NSNumber numberWithUnsignedInteger:value];
    double convertedValue = [valueNumber doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB", @"ZB", @"YB"];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@", convertedValue, tokens[multiplyFactor]];
}


@end
