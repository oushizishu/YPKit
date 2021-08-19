//
//  YPEmoji.m
//  YPEmoji
//
//  Created by 辛亚鹏 on 2021/8/19.
//

#import "YPEmoji.h"

@implementation YPEmoji

// 判断string是否为 纯系统 的emoji
+ (BOOL)_isPureSystemEmoji:(NSString *)string {
    __block BOOL isPure = YES;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        BOOL res = [self characterIsEmoji:substring];
        if (res == NO) {
            *stop = YES;
            isPure = NO;
        }
    }];
    
    return isPure;
}

// 判断单个字符是否是emoji
+ (BOOL)characterIsEmoji:(NSString *)string {
    // OC对Unicode并不友好, swift修复了这一点, 如果是swift的话, 可以直接使用unicode来判断, see: https://unicode.org/Public/UNIDATA/emoji/emoji-data.txt
    // 国际通用Unicode是21位的,但是OC只有16位, 看苹果的文档, 看明白oc到底是怎么切割的
    if ([string length] < 2) {
        return NO;
    }
    
    static NSCharacterSet *_variationSelectors;
    _variationSelectors = [NSCharacterSet characterSetWithRange:NSMakeRange(0xFE00, 16)];
    
    if ([string rangeOfCharacterFromSet: _variationSelectors].location != NSNotFound) {
        return YES;
    }
    const unichar high = [string characterAtIndex:0];
    // Surrogate pair (U+1D000-1F9FF)
    if (0xD800 <= high && high <= 0xDBFF)
    {
        const unichar low = [string characterAtIndex: 1];
        const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
        return (0x1D000 <= codepoint && codepoint <= 0x1F9FF);
        // Not surrogate pair (U+2100-27BF)
    }
    else {
        return (0x2100 <= high && high <= 0x27BF);
    }
}

@end
