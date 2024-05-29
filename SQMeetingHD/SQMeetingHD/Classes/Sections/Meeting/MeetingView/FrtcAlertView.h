#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrtcAlertViewCallBack)(NSInteger index);

@interface FrtcAlertView : UIView

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  buttonTitles:(NSArray <NSString *> *)buttonTitles
             didSelectCallBack:(FrtcAlertViewCallBack)callBack;

+ (void)disMissView;

@end

NS_ASSUME_NONNULL_END
