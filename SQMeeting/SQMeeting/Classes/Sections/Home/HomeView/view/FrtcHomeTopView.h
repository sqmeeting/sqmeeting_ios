#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^didClickButtonBlock)(NSInteger index);

@interface FrtcHomeTopView : UIView

@property (nonatomic, copy) didClickButtonBlock clickBtnBlock;

@end


NS_ASSUME_NONNULL_END
