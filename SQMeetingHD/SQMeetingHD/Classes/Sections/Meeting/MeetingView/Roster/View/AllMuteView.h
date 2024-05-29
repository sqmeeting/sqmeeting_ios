#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AllowMuteCallBack)(BOOL isAllow);

@interface AllMuteView : UIView

+ (void)showAllMuteAlertView:(BOOL)isAllMute allMuteCallBack:(AllowMuteCallBack)allowMuteCallBack;

@end

NS_ASSUME_NONNULL_END
