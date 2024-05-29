#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcOverlayRepeatView : UIView

@property (nonatomic, strong) UITextField *numberField;

@property (nonatomic, assign, readonly) NSInteger repeatNmber; //Default 3 , min 1, max 10

@end

NS_ASSUME_NONNULL_END
