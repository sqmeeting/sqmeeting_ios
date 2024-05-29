#import "MBProgressHUD.h"

#define kHudShowTime 2.0

@interface MBProgressHUD (Extensions)

#pragma mark 在指定的view上显示hud
+ (void)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showWarning:(NSString *)Warning toView:(UIView *)view;
+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showActivityMessage:(NSString*)message view:(UIView *)view;
+ (MBProgressHUD *)showProgressBarToView:(UIView *)view;


#pragma mark 在window上显示hud
+ (void)showMessage:(NSString *)message;
+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (void)showWarning:(NSString *)Warning;
+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message;
+ (MBProgressHUD *)showActivityMessage:(NSString*)message;


#pragma mark 移除hud
+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end

//NS_ASSUME_NONNULL_END
