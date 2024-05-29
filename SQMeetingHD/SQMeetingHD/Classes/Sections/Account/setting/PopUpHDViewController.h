#import "FrtcHDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopUpHDViewControllerDelegate <NSObject>

- (void)saveNewAddress:(NSString *)newServerAddress;

@end

@interface PopUpHDViewController : FrtcHDBaseViewController

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *serverAddressTextField;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, weak) id<PopUpHDViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
