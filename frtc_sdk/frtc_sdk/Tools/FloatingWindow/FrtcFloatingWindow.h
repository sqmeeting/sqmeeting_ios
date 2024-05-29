#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcFloatingWindow : UIWindow

@property (nonatomic, weak) UIWindow *lastKeyWindow;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
