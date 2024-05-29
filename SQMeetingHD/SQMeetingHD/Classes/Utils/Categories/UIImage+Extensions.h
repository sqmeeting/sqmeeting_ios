#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extensions)

+ ( UIImage *)imageFromColor:(UIColor *)color;

- (UIImage *)maskImageWithColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
