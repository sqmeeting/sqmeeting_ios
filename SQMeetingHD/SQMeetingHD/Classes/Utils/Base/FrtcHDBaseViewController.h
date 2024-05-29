#import <UIKit/UIKit.h>
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcHDBaseViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;

- (void)leftButtonClicked;

- (void)configUI;

@end

NS_ASSUME_NONNULL_END
