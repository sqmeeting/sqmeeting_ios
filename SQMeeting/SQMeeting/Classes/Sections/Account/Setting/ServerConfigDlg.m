#import "ServerConfigDlg.h"
#import "Masonry.h"
#import "FrtcUserDefault.h"
#import "FrtcCall.h"
#import "FrtcManagement.h"

@implementation ServerConfigDlg

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:shadowView];
    shadowView.alpha = 0.3;
    
    self.backView = [UIView new];
    self.backView.frame = CGRectMake(0, 160, self.view.frame.size.width, 180);
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = 5;
    [self.view addSubview:self.backView];
    
    [self configFRView];
}

- (void)configFRView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView.mas_centerX);
        make.top.mas_equalTo(self.backView.mas_top).mas_offset(24);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.serverAddressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(16);
        make.width.mas_equalTo(self.backView.frame.size.width - 40);
        make.height.mas_equalTo(36);
    }];
    
    [self.serverNotificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.serverAddressTextField.mas_bottom).mas_offset(2);
        make.width.mas_equalTo(self.view.frame.size.width - 40);
        make.height.mas_equalTo(16);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.serverNotificationLabel.mas_bottom).mas_offset(2);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.serverNotificationLabel.mas_bottom).mas_offset(2);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark -- private function
- (void)cancelButton:(UIButton*)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- private function
- (void)saveButton:(UIButton*)sender {
    if (self.serverAddressTextField.text.length == 0) {
        _serverNotificationLabel.text = NSLocalizedString(@"set_ip_error", nil);
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    [[FrtcUserDefault sharedUserDefault] setObject:_serverAddressTextField.text forKey:SERVER_ADDRESS];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1.0;
        _titleLabel.text = NSLocalizedString(@"server_address", nil);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        [self.backView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UITextField *)serverAddressTextField {
    if(!_serverAddressTextField) {
        _serverAddressTextField = [[UITextField alloc] init];
        _serverAddressTextField.textColor = [UIColor blackColor];
        _serverAddressTextField.backgroundColor = UIColorHex(0xeff1f5);
        _serverAddressTextField.textAlignment = NSTextAlignmentLeft;
        _serverAddressTextField.borderStyle = UITextBorderStyleRoundedRect;
        _serverAddressTextField.font = [UIFont systemFontOfSize:13.0];
        _serverAddressTextField.text = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
        [self.backView addSubview:_serverAddressTextField];
    }
    return _serverAddressTextField;
}

- (UIButton *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:NSLocalizedString(@"dialog_cancel", nil) forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelButton.backgroundColor = UIColorHex(0xeff1f5);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0];;
        [_cancelButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _cancelButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.backView addSubview:_cancelButton];
    }
    
    return _cancelButton;
}
 
- (UIButton *)saveButton {
    if(!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:NSLocalizedString(@"string_save", nil) forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveButton.backgroundColor = UIColorHex(0x125f7b);
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:14.0];;
        [_saveButton addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
        _saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _saveButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.backView addSubview:_saveButton];
    }
    
    return _saveButton;
}

- (UILabel *)serverNotificationLabel {
    if(!_serverNotificationLabel) {
        _serverNotificationLabel = [[UILabel alloc] init];
        _serverNotificationLabel.textAlignment = NSTextAlignmentLeft;
        _serverNotificationLabel.textColor = UIColorHex(0xeb3c0);
        _serverNotificationLabel.text = @"";
        _serverNotificationLabel.font = [UIFont systemFontOfSize:13.0];
        [self.backView addSubview:_serverNotificationLabel];
    }
    
    return _serverNotificationLabel;
}


@end
