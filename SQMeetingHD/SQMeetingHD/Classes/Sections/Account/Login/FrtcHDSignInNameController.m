#import "FrtcHDSignInNameController.h"
#import "Masonry.h"
#import "FrtcUserDefault.h"
#import "MBProgressHUD+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIImage+Extensions.h"
#import "FrtcManagement.h"
#import "FrtcSignLoginPresenter.h"
#import "AppDelegate.h"
#import "UIControl+Extensions.h"
#import "SettingHDViewController.h"
#import "HDUserInfoModel.h"
#import "UINavigationItem+Extensions.h"
#import "UIViewController+Extensions.h"

#define kTextField_Height 45

@interface FrtcHDSignInNameController ()<UIGestureRecognizerDelegate, UITextFieldDelegate,FrtcSignLoginProtocol>

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
//@property (nonatomic, strong) UIButton *forgetPwdButton;
@property (nonatomic, strong) UIButton *loginButton;
//@property (nonatomic, strong) UIButton *meetingNumberButton;
@property (nonatomic, strong) FrtcSignLoginPresenter *loginPresenter;

@end

@implementation FrtcHDSignInNameController

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.contentView.hidden = YES;
    [self configUI];
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
}

#pragma mark - UI

- (void)configUI {
    
    @WeakObj(self)
    [self.navigationItem initWithLeftButtonImage:@"nav_back_icon" back:^{
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:^{ }];
    }];
    
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [settingsBtn setImage:[UIImage imageNamed:@"icon_setting"]forState:UIControlStateNormal];
    [settingsBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [settingsBtn.imageView setTintColor:UIColor.grayColor];
    [settingsBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        SettingHDViewController *settingViewController = [[SettingHDViewController alloc] init];
        [self.navigationController pushViewController:settingViewController animated:YES];
    }];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    [self.navigationItem setRightBarButtonItems:@[settingsItem]];
    
    self.contentView.backgroundColor = UIColor.whiteColor;
    UIStackView *verticalStacView = [UIStackView new];
    verticalStacView.spacing = 14.f;
    verticalStacView.axis = UILayoutConstraintAxisVertical;
    [self.contentView addSubview:verticalStacView];
    
    [verticalStacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
        
    [verticalStacView addArrangedSubviews:@[self.nameLabel,self.nameTextField,self.passwordTextField,self.loginButton]];
    
    [verticalStacView setCustomSpacing:50.f afterView:self.nameLabel];
    [verticalStacView setCustomSpacing:32.f afterView:self.passwordTextField];
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kTextField_Height);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.nameTextField.mas_height);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kButtonHeight);
    }];
    
    [self loginBtnEnabled];
}


#pragma mark - FrtcSignLoginProtocol

- (void)loadLoginSuccess:(HDUserInfoModel *)userInfo errMsg:(NSString *)errMsg isLock:(BOOL)isLock{
    //[MBProgressHUD hideHUD];
    if (isLock) {
        [self showAlertWithTitle:NSLocalizedString(@"account_locking", nil) message:NSLocalizedString(@"account_unlocking", nil) buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) {
            
        }];
    }else{
        if (!errMsg) {
            [FrtcLocalInforDefault saveLoginName:self.nameTextField.text];
            [FrtcLocalInforDefault savePasswordState:YES];
            [FrtcLocalInforDefault saveLoginPassword:self.passwordTextField.text];
            [MBProgressHUD showSuccess:NSLocalizedString(@"login_success", nil)];
            AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [myAppDelegate setHomeViewRootViewController];
        }else{
            [MBProgressHUD showSuccess:errMsg];
        }
        
    }
}

#pragma mark -- private function

- (void)didClickJoinMeetingButton:(UIButton *)sender {
    if (kStringIsEmpty([FrtcLocalInforDefault getMeetingDisPlayName])) {
        [FrtcLocalInforDefault saveMeetingName:@"iPad"];
    }
    UIViewController *viewController = [[NSClassFromString(@"FrtcHDCallViewController") alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didClickLoginButton:(UIButton*)sender {
    if (self.nameTextField.text.length == 0) {
        return;
    }
    [self.view endEditing:YES];
    [self.loginPresenter requestLoginWithName:self.nameTextField.text
                                     password:self.passwordTextField.text];
}

- (void)nameFieldDidChange:(UITextField*) sender {
    if (sender.text.length > 48) {
        sender.text = [sender.text substringToIndex:48];
    }
    [self loginBtnEnabled];
}

- (void)passwordFieldDidChange:(UITextField *)sender {
    if (sender.text.length > 48) {
        sender.text = [sender.text substringToIndex:48];
    }
    [self loginBtnEnabled];
}

- (void)loginBtnEnabled {
    BOOL isEnabled = (self.nameTextField.text.length > 0 && self.passwordTextField.text.length >= 6);
    self.loginButton.enabled = isEnabled;
}

#pragma mark -- lazy load

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:22.f];
        _nameLabel.text = NSLocalizedString(@"account_password_login", nil);
        _nameLabel.textColor = KTextColor;
    }
    
    return _nameLabel;
}

- (UITextField *)nameTextField {
    if(!_nameTextField) {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.delegate = self;
        _nameTextField.textColor = KTextColor;
        _nameTextField.placeholder = NSLocalizedString(@"username_account", nil);
        _nameTextField.clipsToBounds = YES;
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.font = [UIFont systemFontOfSize:16.0];
        [_nameTextField addTarget:self  action:@selector(nameFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = KLineColor.CGColor;
        bottomBorder.frame = CGRectMake(0.0f, kTextField_Height-1, KScreenWidth, 1.0f);
        [_nameTextField.layer addSublayer:bottomBorder];
        
        _nameTextField.text = [FrtcLocalInforDefault getLoginName];
    }
    return _nameTextField;
}

- (UITextField *)passwordTextField {
    if(!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.delegate = self;
        _passwordTextField.textColor = KTextColor;
        _passwordTextField.placeholder = NSLocalizedString(@"string_pwd", nil);
        _passwordTextField.clipsToBounds = YES;
        _passwordTextField.borderStyle = UITextBorderStyleNone;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.font = [UIFont systemFontOfSize:16.0];
        [_passwordTextField addTarget:self
                               action:@selector(passwordFieldDidChange:)
                     forControlEvents:UIControlEventEditingChanged];
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = KLineColor.CGColor;
        bottomBorder.frame = CGRectMake(0.0f, kTextField_Height-1, KScreenWidth, 1.0f);
        [_passwordTextField.layer addSublayer:bottomBorder];
    }
    return _passwordTextField;
}

- (UIButton *)loginButton {
    if(!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:NSLocalizedString(@"sign_in", nil) forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.enabled = NO;
        _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];;
        [_loginButton addTarget:self action:@selector(didClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _loginButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [_loginButton setBackgroundImage:[UIImage imageFromColor:KMainDisabledColor] forState:UIControlStateDisabled];
        [_loginButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        _loginButton.layer.masksToBounds = YES;
        _loginButton.layer.cornerRadius = KCornerRadius;
    }
    
    return _loginButton;
}

- (FrtcSignLoginPresenter *)loginPresenter {
    if (!_loginPresenter) {
        _loginPresenter = [[FrtcSignLoginPresenter alloc]init];
        [_loginPresenter bindView:self];
    }
    return _loginPresenter;
}

@end
