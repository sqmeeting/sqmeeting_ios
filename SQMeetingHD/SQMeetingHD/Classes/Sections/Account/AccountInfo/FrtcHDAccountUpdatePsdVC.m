#import "FrtcHDAccountUpdatePsdVC.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "UIStackView+Extensions.h"
#import "FrtcAccountPresenter.h"
#import "MBProgressHUD+Extensions.h"
#import "UIViewController+Extensions.h"
#import "AppDelegate.h"
#import "UITextField+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIView+Toast.h"
#import "FrtcUserModel.h"

#define kTextField_Height 58

@interface FrtcHDAccountUpdatePsdVC () <FrtcAccountProtocol,UITextFieldDelegate>

@property (nonatomic, strong) FAccountTextField *oldPwdTextField;
@property (nonatomic, strong) FAccountTextField *pwdNewTextField;
@property (nonatomic, strong) FAccountTextField *againNewPwdTextField;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) FrtcAccountPresenter *presenter;

@end

@implementation FrtcHDAccountUpdatePsdVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"update_password", nil);
}

- (void)dealloc {
}

#pragma mark - UI

- (void)configUI {
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(kTextField_Height * 3);
    }];
    
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 0;
    [bgView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
    }];
    
    [stackView addArrangedSubviews:@[self.oldPwdTextField,self.pwdNewTextField,self.againNewPwdTextField]];
    
    [self.oldPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kTextField_Height);
    }];
    
    [self.pwdNewTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kTextField_Height);
    }];
    
    [self.againNewPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kTextField_Height);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(bgView.mas_bottom).mas_offset(25);
        make.width.equalTo(self.saveButton);
        make.height.mas_equalTo(kButtonHeight);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.equalTo(self.cancelButton.mas_top);
        make.left.equalTo(self.cancelButton.mas_right).mas_offset(20);
        make.width.height.equalTo(self.cancelButton);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    return YES;
}

#pragma mark - FrtcAccountProtocol
- (void)responseChangeUserPasswordWithSuccess:(BOOL)result {
    [MBProgressHUD hideHUD];
    if (result) {
        [self showAlertWithTitle:NSLocalizedString(@"psd_change_ok", nil) message:NSLocalizedString(@"psd_loginchange_ok", nil) buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
            [FrtcLocalInforDefault savePasswordState:NO];

            AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [myAppDelegate setEntryViewRootViewController];
        }];
    }else{
        [MBProgressHUD showMessage:NSLocalizedString(@"psd_change_error", nil)];
    }
}

#pragma mark -- private function

- (void)cancelButton:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButton:(UIButton*)sender {
    if (kStringIsEmpty(self.oldPwdTextField.text)) {
        [MBProgressHUD showMessage:NSLocalizedString(@"password_low", nil)]; return;
    }

    NSString *pwdnew = self.pwdNewTextField.text;
    if (kStringIsEmpty(pwdnew)) {
        [MBProgressHUD showMessage:NSLocalizedString(@"password_low", nil)]; return;
    }
    
    if (kStringIsEmpty(self.againNewPwdTextField.text)) {
        [MBProgressHUD showMessage:NSLocalizedString(@"password_low", nil)]; return;
    }
    
    if (![self.pwdNewTextField.text isEqualToString:self.againNewPwdTextField.text]) {
        [self.view makeToast:NSLocalizedString(@"psd_two_error", nil)]; return;
    }
    
    BOOL isLevelHigh = [FrtcUserModel fetchUserInfo].isLevelHigh;
    if (isLevelHigh) {
        BOOL isMatch = [self checkPasswork:pwdnew];
        if (!isMatch) {
            [self.view makeToast:NSLocalizedString(@"password_high", nil)]; return;
        }
    }
    
    [self.presenter modiyUserPasswordWithOldPassword:self.oldPwdTextField.text newPassword:self.pwdNewTextField.text];
}

- (void)saveBtnEnabled {
    BOOL isEnabled = (self.pwdNewTextField.text.length >= 6 && self.againNewPwdTextField.text.length >= 6);
    self.saveButton.enabled = isEnabled;
}

- (int)checkPasswork:(NSString*)password{
    NSString *newPattern = @"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,48}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",newPattern];
    return [pred evaluateWithObject:password];
}

#pragma mark - lazy

- (FrtcAccountPresenter *)presenter {
    if (!_presenter) {
        _presenter = [FrtcAccountPresenter new];
        [_presenter bindAccountView:self];
    }
    return _presenter;
}

- (FAccountTextField *)oldPwdTextField {
    if (!_oldPwdTextField) {
        _oldPwdTextField = [self getTextFieldWithLeftTitle:NSLocalizedString(@"old_password", nil) placeholder:NSLocalizedString(@"check_you_password", nil) addBorder:YES];
    }
    return _oldPwdTextField;
}

- (FAccountTextField *)pwdNewTextField {
    if (!_pwdNewTextField) {
        _pwdNewTextField = [self getTextFieldWithLeftTitle:NSLocalizedString(@"new_password", nil) placeholder:NSLocalizedString(@"new_pwd", nil) addBorder:YES];
    }
    return _pwdNewTextField;
}

- (FAccountTextField *)againNewPwdTextField {
    if (!_againNewPwdTextField) {
        _againNewPwdTextField = [self getTextFieldWithLeftTitle:NSLocalizedString(@"psd_confirm", nil) placeholder:NSLocalizedString(@"confirm_password", nil) addBorder:NO];
    }
    return _againNewPwdTextField;
}

- (UIButton *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:NSLocalizedString(@"dialog_cancel", nil) forState:UIControlStateNormal];
        [_cancelButton setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageFromColor:KGreyColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageFromColor:KGreyHoverColor] forState:UIControlStateHighlighted];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0];;
        [_cancelButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _cancelButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = KCornerRadius;
        [self.contentView addSubview:_cancelButton];
    }
    
    return _cancelButton;
}

- (UIButton *)saveButton {
    if(!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:NSLocalizedString(@"dialog_save", nil) forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_saveButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:14.0];;
        [_saveButton addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
        _saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _saveButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        _saveButton.layer.masksToBounds = YES;
        _saveButton.layer.cornerRadius = KCornerRadius;
        [self.contentView addSubview:_saveButton];
    }
    
    return _saveButton;
}

- (FAccountTextField *)getTextFieldWithLeftTitle:(NSString *)title placeholder:(NSString *)placeholder addBorder:(BOOL)isAddBorder{
    UILabel *lelftLabel = [[UILabel alloc]init];
    lelftLabel.text = title;
    lelftLabel.textColor = KTextColor;
    lelftLabel.font = [UIFont boldSystemFontOfSize:16.f];
    @WeakObj(self);

    FAccountTextField *textField = [[FAccountTextField alloc]init];
    textField.placeholder = placeholder;
    textField.leftView = lelftLabel;
    textField.delegate = self;
    textField.secureTextEntry = YES;
    textField.fLengthLimit = 48;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"icon_psd_hide"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"icon_psd_show"] forState:UIControlStateSelected];
    [rightBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        textField.secureTextEntry = !btn.selected;
    }];
    textField.rightView = rightBtn;
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    textField.didChangeBlock = ^(NSInteger index) {
        @StrongObj(self)
        [self saveBtnEnabled];
    };
    if (isAddBorder) {
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = KLineColor.CGColor;
        bottomBorder.frame = CGRectMake(0.0f, kTextField_Height-1, KScreenWidth, 0.5f);
        [textField.layer addSublayer:bottomBorder];
    }
    return textField;
}

@end



@implementation FAccountTextField

- (CGRect)textRectForBounds:(CGRect)bounds{
    CGRect textRect = [super textRectForBounds:bounds];
    if (self.leftView ==nil) {
        return CGRectInset(textRect, 10,0);
    }
    CGFloat offset = 70 - textRect.origin.x;
    textRect.origin.x = 70;
    textRect.size.width = textRect.size.width - offset - 10;
    return textRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    CGRect textRect = [super editingRectForBounds:bounds];
    if (self.leftView ==nil) {
        return CGRectInset(textRect, 10,0);
    }
    CGFloat offset = 70 - textRect.origin.x;
    textRect.origin.x = 70;
    textRect.size.width = textRect.size.width - offset - 10;
    return textRect;
}

@end
