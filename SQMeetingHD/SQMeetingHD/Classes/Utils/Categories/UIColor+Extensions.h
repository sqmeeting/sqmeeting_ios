#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef UIColorHex
#define UIColorHex(_hex_)   [UIColor f_colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

@interface UIColor (Extensions)

+ (nullable UIColor *)f_colorWithHexString:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
