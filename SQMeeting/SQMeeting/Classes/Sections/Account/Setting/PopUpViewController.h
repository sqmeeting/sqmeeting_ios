#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopUpViewControllerDelegate <NSObject>

- (void)saveNewAddress:(NSString *)newServerAddress;

@end

@interface PopUpViewController : BaseViewController

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *serverAddressTextField;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, weak) id<PopUpViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
