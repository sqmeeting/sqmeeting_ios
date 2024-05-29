#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define KHomeMeetingListHeaderViewHeight 52.0

typedef void (^DidCancleButtonBlock)(void);

@interface FrtcHomeMeetingListHeaderView : UIView

@property (nonatomic, copy) DidCancleButtonBlock cancleBtnBlock;
@property (nonatomic, strong) UIButton *clearButton;

@end

NS_ASSUME_NONNULL_END
