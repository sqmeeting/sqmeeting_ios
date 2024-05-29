#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopUpRateControllerDelegate <NSObject>

- (void)saveNewCallRate:(NSString *)newCallRate;

@end

@interface PopUpRateController : BaseViewController

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *callRateTextField;
@property (nonatomic, strong) UIButton *notificationBtn;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, weak) id<PopUpRateControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
