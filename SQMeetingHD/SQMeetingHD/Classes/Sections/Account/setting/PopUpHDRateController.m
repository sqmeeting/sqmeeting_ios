#import "PopUpHDRateController.h"
#import "Masonry.h"
#import "FrtcUserDefault.h"
#import "UIImage+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import <FrtcManagement.h>
#import "UIViewController+Extensions.h"
#import "AppDelegate.h"

@interface PopUpHDRateController ()

@end

@implementation PopUpHDRateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"phone_testing_title", nil);
    self.backView = [UIView new];
    self.backView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(150);
    }];
    [self configFRView];
    // Do any additional setup after loading the view.
}

- (void)configFRView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(15);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.callRateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(16);
        make.height.mas_equalTo(40);
    }];
    
    [self.notificationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(self.callRateTextField.mas_bottom).mas_offset(16);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(self.backView.mas_bottom).mas_offset(25);
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

#pragma mark -- private function
- (void)cancelButton:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- private function
- (void)saveButton:(UIButton*)sender {
    
    if (kStringIsEmpty(_callRateTextField.text)) {
        return;
    }
    
    int callRate = [_callRateTextField.text intValue];
    if((callRate > 2048) || (callRate < 0) || (callRate > 0 && callRate < 64)){
        NSLog(@"callRate is %d and not valid",callRate);
        [_notificationBtn setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"rate_limit", nil)] forState:UIControlStateNormal];
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(saveNewCallRate:)]) {
        [self.delegate saveNewCallRate:_callRateTextField.text];
    }
    [MBProgressHUD showMessage:NSLocalizedString(@"server_saved", nil)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.text = NSLocalizedString(@"phone_testing", nil);
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        [self.backView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UITextField *)callRateTextField {
    if(!_callRateTextField) {
        _callRateTextField = [[UITextField alloc] init];
        _callRateTextField.textColor = KTextColor;
        _callRateTextField.borderStyle = UITextBorderStyleRoundedRect;
        _callRateTextField.font = [UIFont systemFontOfSize:16.0];
        _callRateTextField.keyboardType = UIKeyboardTypeNumberPad;
        _callRateTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.backView addSubview:_callRateTextField];
        _callRateTextField.text = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    }
    return _callRateTextField;
}

- (UIButton *)notificationBtn {
    if(!_notificationBtn) {
        _notificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_notificationBtn setImage:[UIImage imageNamed:@"setting_warn"] forState:UIControlStateNormal];
        [_notificationBtn setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"phone_rate_notice", nil)] forState:UIControlStateNormal];
        [_notificationBtn setTitleColor:KTextColor666666 forState:UIControlStateNormal];
        _notificationBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [self.backView addSubview:_notificationBtn];
    }
    return _notificationBtn;
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


@end
