#import "UIImage+Add.h"
#import "FrtcBundleTools.h"
#import "FrtcUIMacro.h"

@implementation UIImage (Add)

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageBundlePath:(NSString *)path {
    
    if (kStringIsEmpty(path)) {
        return [UIImage new];
    }
    
    NSString *imagePath = [FrtcBundleTools getBundlePath:path];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    return image;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
