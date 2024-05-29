#import "FrtcHDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopUpHDRateControllerDelegate <NSObject>

- (void)saveNewCallRate:(NSString *)newCallRate;

@end

@interface PopUpHDRateController : FrtcHDBaseViewController

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *callRateTextField;
@property (nonatomic, strong) UIButton *notificationBtn;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;


@property (nonatomic, weak) id<PopUpHDRateControllerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
