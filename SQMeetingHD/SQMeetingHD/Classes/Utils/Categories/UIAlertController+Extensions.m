#import "UIAlertController+Extensions.h"

@implementation UIAlertController (Extensions)

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title image:(NSString *)image imageSize:(CGSize)imageSize preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:image];
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title customView:imageView viewSize:imageSize preferredStyle:preferredStyle];
    
    return alertCtrl;
}

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title customView:(UIView *)customView viewSize:(CGSize)viewSize preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat lineHeight = scale == 2 ? 18 : 16;
    
    NSInteger count = ceilf(viewSize.height / lineHeight);
    NSMutableString *msg = @"".mutableCopy;
    for (NSInteger i = 0; i < count; i++) {
        [msg appendString:@"\n"];
    }

    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    [alertCtrl.view addSubview:customView];
    
    [customView.centerXAnchor constraintEqualToAnchor:alertCtrl.view.centerXAnchor].active = YES;
    [customView.centerYAnchor constraintEqualToAnchor:alertCtrl.view.centerYAnchor].active = YES;
    [customView.widthAnchor constraintEqualToConstant:viewSize.width].active = YES;
    [customView.heightAnchor constraintEqualToConstant:viewSize.height].active = YES;
    
    return alertCtrl;
}
@end
