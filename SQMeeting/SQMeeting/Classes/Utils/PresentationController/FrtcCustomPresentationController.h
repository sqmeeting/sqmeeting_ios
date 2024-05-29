#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcCustomPresentationController : UIPresentationController

@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, assign) CGFloat presentedViewHeight;

@end

NS_ASSUME_NONNULL_END
