#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Add)

+ ( UIImage *)imageFromColor:(UIColor *)color;

+ (UIImage *)imageBundlePath:(NSString *)path;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
