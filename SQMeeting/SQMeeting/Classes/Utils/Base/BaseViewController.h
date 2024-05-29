#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;

- (void)leftButtonClicked;

- (void)configUI;

@end

NS_ASSUME_NONNULL_END
