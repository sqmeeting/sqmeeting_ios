#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extensions)

- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner;

- (void)addGradientWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

- (UIViewController*)viewController;

- (UIViewController *)topMostController;

@end

NS_ASSUME_NONNULL_END
