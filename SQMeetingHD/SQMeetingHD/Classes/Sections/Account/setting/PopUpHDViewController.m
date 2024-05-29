#import "PopUpHDViewController.h"
#import "Masonry.h"
#import "FrtcUserDefault.h"
#import "Masonry.h"
#import "FrtcUserDefault.h"
#import "UIImage+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import <FrtcManagement.h>
#import "UIViewController+Extensions.h"
#import "AppDelegate.h"

@interface PopUpHDViewController () <UITextFieldDelegate>

@end

@implementation PopUpHDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"server_setting", nil);
    self.backView = [UIView new];
    self.backView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(120);
    }];
    
    [self configFRView];
}

- (void)configFRView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(15);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.serverAddressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(16);
        make.height.mas_equalTo(40);
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
    
    NSString *textFieldAddress = self.serverAddressTextField.text;
    NSString *defaultAddress = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    if ([defaultAddress isEqualToString:textFieldAddress]) {
        return;
    }
    
    if (kStringIsEmpty(textFieldAddress)) {
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(saveNewAddress:)]) {
        [self.delegate saveNewAddress:textFieldAddress];
    }
    
    NSString *address = [self removeSpaceAndNewline:textFieldAddress];
    
    NSString *inputString = address;
    NSArray *components = [inputString componentsSeparatedByString:@":"];
    if (components.count > 1) {
        NSString *portString = components[1];
        NSCharacterSet *numericCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
        BOOL isNumeric = [portString rangeOfCharacterFromSet:[numericCharacterSet invertedSet]].location == NSNotFound;
        if (isNumeric) {

        } else {
            NSCharacterSet *nonNumericCharacterSet = [numericCharacterSet invertedSet];
            NSString *filteredPort = [[portString componentsSeparatedByCharactersInSet:nonNumericCharacterSet] componentsJoinedByString:@""];
            address = [NSString stringWithFormat:@"%@:%@",components[0],filteredPort];
        }
    }
    [[FrtcUserDefault sharedUserDefault] setObject:address forKey:SERVER_ADDRESS];
    [[FrtcManagement sharedManagement] setFRTCSDKConfig:FRTCSDK_SERVER_ADDRESS withSDKConfigValue:[self WebURLEncodeWithUrl:address]];
    
    [MBProgressHUD showMessage:NSLocalizedString(@"server_saved", nil)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isLoginSuccess) {
            [self showAlertWithTitle:NSLocalizedString(@"setting_server_modified", nil) message:NSLocalizedString(@"setting_server_modified_success", nil) buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) {
                AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [myAppDelegate setEntryViewRootViewController];
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}

- (NSString *)removeSpaceAndNewline:(NSString *)str{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

- (NSString *)WebURLEncodeWithUrl:(NSString *)url
{
    NSString *charactersToEscape = @"`%^{}\"[]|\\<>·";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [[url description] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString* str = textField.text;
    for (int i = 0; i<str.length; i++)
    {
        NSString*string = [str substringFromIndex:i];
        NSString *regex = @"[\u4e00-\u9fa5]{0,}$";
        NSPredicate *predicateRe1 = [NSPredicate predicateWithFormat:@"self matches %@", regex];
        BOOL resualt = [predicateRe1 evaluateWithObject:string];
        if (resualt)
        {
            str =  [str stringByReplacingOccurrencesOfString:[str substringFromIndex:i] withString:@""];
        }
    }
    textField.text = str;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.text = NSLocalizedString(@"server_address", nil);
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        [self.backView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UITextField *)serverAddressTextField {
    if(!_serverAddressTextField) {
        _serverAddressTextField = [[UITextField alloc] init];
        _serverAddressTextField.textColor = KTextColor;
        _serverAddressTextField.borderStyle = UITextBorderStyleRoundedRect;
        _serverAddressTextField.font = [UIFont systemFontOfSize:16.0];
        _serverAddressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _serverAddressTextField.delegate = self;
        _serverAddressTextField.text = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
        [_serverAddressTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:(UIControlEventEditingChanged)];
        [self.backView addSubview:_serverAddressTextField];
    }
    return _serverAddressTextField;
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
