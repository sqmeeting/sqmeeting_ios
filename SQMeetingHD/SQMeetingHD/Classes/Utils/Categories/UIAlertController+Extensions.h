#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (Extensions)

+ (instancetype _Nonnull)alertControllerWithTitle:(nullable NSString *)title customView:(UIView *_Nonnull)customView viewSize:(CGSize)viewSize preferredStyle:(UIAlertControllerStyle)preferredStyle;

@end

NS_ASSUME_NONNULL_END
