#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerConfigDlg : UIViewController

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *serverAddressTextField;
@property (nonatomic, strong) UILabel *serverNotificationLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

NS_ASSUME_NONNULL_END
