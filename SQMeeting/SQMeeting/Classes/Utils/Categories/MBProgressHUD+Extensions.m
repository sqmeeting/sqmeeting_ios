#import "MBProgressHUD+Extensions.h"
#import "AppDelegate.h"

@implementation MBProgressHUD (Extensions)

+ (void)showMessage:(NSString *)message toView:(UIView *)view{
    [self show:message icon:nil view:view];
}

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.label.text = text;
    hud.contentColor = UIColor.whiteColor;
    if (icon == nil) {
        hud.mode = MBProgressHUDModeText;
    }else{
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]];
        img = img == nil ? [UIImage imageNamed:icon] : img;
        hud.customView = [[UIImageView alloc] initWithImage:img];
        hud.mode = MBProgressHUDModeCustomView;
    }
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:kHudShowTime];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view{
    [self show:success icon:@"success.png" view:view];
}

+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showWarning:(NSString *)Warning toView:(UIView *)view{
    [self show:Warning icon:@"warn" view:view];
}

+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view{
    [self show:message icon:imageName view:view];
}

+ (MBProgressHUD *)showActivityMessage:(NSString*)message view:(UIView *)view{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.label.text = message;
    hud.contentColor = UIColor.whiteColor;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (MBProgressHUD *)showProgressBarToView:(UIView *)view{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"加载中...";
    return hud;
}

+ (void)showMessage:(NSString *)message{
    [self showMessage:message toView:nil];
}

+ (void)showSuccess:(NSString *)success{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error{
    [self showError:error toView:nil];
}

+ (void)showWarning:(NSString *)Warning{
    [self showWarning:Warning toView:nil];
}

+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message{
    [self showMessageWithImageName:imageName message:message toView:nil];
}

+ (MBProgressHUD *)showActivityMessage:(NSString*)message{
    return [self showActivityMessage:message view:nil];
}

+ (void)hideHUDForView:(UIView *)view{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        for (UIWindow *window in [UIApplication sharedApplication].windows) {
    //            [self hideHUDForView:window animated:YES];
    //        }
    //    });
}

+ (void)hideHUD{
    [self hideHUDForView:nil];
}

@end
