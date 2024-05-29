#import "FrtcMeetingPasscodeController.h"
#import "CustomTextField.h"
#import "Masonry.h"
#import <objc/runtime.h>
#import <FrtcCall.h>

#define KColorRGB(r,g,b,a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]

@interface FrtcMeetingPasscodeController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, CustomTextFieldDeleteDelegate>

@end

@implementation FrtcMeetingPasscodeController

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backGroundView setImage:[UIImage imageNamed:@"sdk_call_bg"]];
    [self.passcodeMainView setBackgroundColor:UIColor.whiteColor];
  
    self.title = @"Meeting Passcode";
    
    [self configView];
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)updateDiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updatePasscode {
    _setPwdTextOne.text = @"";
    _setPwdTextTwo.text = @"";
    _setPwdTextThree.text = @"";
    _setPwdTextFour.text = @"";
    _errorNotificationLabel.text = NSLocalizedString(@"pwd_invalid", nil);
    
    [_setPwdTextOne becomeFirstResponder];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    NSArray *subViews = [self.backGroundView subviews];
    
    if ([subViews count] == 0) {
        return;
    }
    
    UIView *subView = nil;
    for (subView  in subViews) {
        if([subView isKindOfClass:[UITextField class]]) {
            if ([subView isFirstResponder]) {
                [subView resignFirstResponder];
            }
        }
    }
}

-(void)configView {
    [self.passcodeMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(150);
        make.width.mas_equalTo(600);
        make.height.mas_equalTo(350);
    }];
    
    [self.passcodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(18);
        make.width.mas_equalTo(self.backGroundView.mas_width);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.setPwdTextOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.top.mas_equalTo(self.passcodeLabel.mas_bottom).mas_offset(18);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(60);
    }];
    
    [self.setPwdTextTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.setPwdTextOne.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.passcodeLabel.mas_bottom).mas_offset(18);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(60);
    }];
    
    [self.setPwdTextThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.setPwdTextTwo.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.passcodeLabel.mas_bottom).mas_offset(18);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(60);
    }];
    
    [self.setPwdTextFour mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.setPwdTextThree.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.passcodeLabel.mas_bottom).mas_offset(18);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(60);
    }];
    
    [self.errorNotificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.setPwdTextOne.mas_bottom).mas_offset(3);
        make.width.mas_equalTo(self.backGroundView.mas_width);
        make.height.mas_equalTo(22);
    }];
    
    [self.hangUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.errorNotificationLabel.mas_bottom).mas_offset(3);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(45);
    }];
}


- (void)dismissKeyBoard:(UIView *)view {
    NSArray *subViews = [view subviews];
    
    if ([subViews count] == 0) {
        return;
    }
    
    UIView *subView = nil;
    for (subView  in subViews) {
        if ([subView isFirstResponder]) {
            [subView resignFirstResponder];
            break;
        }
        [self dismissKeyBoard:subView];
    }
    return;
}

#pragma mark -- lazy load

- (UIImageView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self getScreenLandscapeWidth], [self getScreenLandscapeHeight])];
        _backGroundView.userInteractionEnabled = YES;
        [self.view addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (UIImageView *)passcodeMainView {
    if (!_passcodeMainView) {
        _passcodeMainView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 350)];
        _passcodeMainView.userInteractionEnabled = YES;
        _passcodeMainView.layer.cornerRadius = 15;
        [self.backGroundView addSubview:_passcodeMainView];
    }
    return _passcodeMainView;
}

- (CGFloat)getScreenLandscapeWidth {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width > size.height ? size.width : size.height;
}

- (CGFloat)getScreenLandscapeHeight {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.height > size.width ? size.width : size.height;
}

- (UILabel *)passcodeLabel {
    if(!_passcodeLabel) {
        _passcodeLabel = [[UILabel alloc] init];
        _passcodeLabel.textAlignment = NSTextAlignmentCenter;
        _passcodeLabel.numberOfLines = 1.0;
        _passcodeLabel.textColor = KColorRGB(36,36,36,1.0);
        _passcodeLabel.text = NSLocalizedString(@"meeting_password", nil);
        _passcodeLabel.font = [UIFont systemFontOfSize:26.0];
        [self.passcodeMainView addSubview:_passcodeLabel];
    }
    
    return _passcodeLabel;
}

- (void) editBeginTextOne:(UITextField*) sender {
    _setPwdTextOne.background = [UIImage imageNamed:@"icon_input_focus"];
    
}

- (void) editEndTextOne:(UITextField*) sender {
    _setPwdTextOne.background = [UIImage imageNamed:@"icon_input_normal"];
}

- (void) editDidChangeTextOne:(UITextField*) sender {
    
    NSString *verStr = _setPwdTextOne.text;
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (verStr.length >= 1) {
        verStr = [verStr substringToIndex:1];
        
    }
    _setPwdTextOne.text = verStr;
    
    [self checkPasscode];
}

- (void) editBeginTextTwo:(UITextField*) sender {
    _setPwdTextTwo.background = [UIImage imageNamed:@"icon_input_focus"];
}

- (void) editEndTextTwo:(UITextField*) sender {
    _setPwdTextTwo.background = [UIImage imageNamed:@"icon_input_normal"];
}

- (void) editDidChangeTextTwo:(UITextField*) sender {
    NSString *verStr = _setPwdTextTwo.text;
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (verStr.length >= 1) {
        verStr = [verStr substringToIndex:1];
        
    }
    _setPwdTextTwo.text = verStr;
    
    [self checkPasscode];
}

- (void) editBeginTextThree:(UITextField*) sender {
    _setPwdTextThree.background = [UIImage imageNamed:@"icon_input_focus"];
}

- (void) editEndTextThree:(UITextField*) sender {
    _setPwdTextThree.background = [UIImage imageNamed:@"icon_input_normal"];
}

- (void) editDidChangeTextThree:(UITextField*) sender {
    NSString *verStr = _setPwdTextThree.text;
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (verStr.length >= 1) {
        verStr = [verStr substringToIndex:1];
        
    }
    _setPwdTextThree.text = verStr;
    
    [self checkPasscode];
}

- (void) editBeginTextFour:(UITextField*) sender {
    _setPwdTextFour.background = [UIImage imageNamed:@"icon_input_focus"];
}

- (void) editEndTextFour:(UITextField*) sender {
    _setPwdTextFour.background = [UIImage imageNamed:@"icon_input_normal"];
}

- (void) editDidChangeTextFour:(UITextField*) sender {
    NSString *verStr = _setPwdTextFour.text;
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (verStr.length >= 1) {
        verStr = [verStr substringToIndex:1];
        
    }
    _setPwdTextFour.text = verStr;
    
    [self checkPasscode];
}

- (void) checkPasscode {
    _errorNotificationLabel.text = @"";
    if (self.setPwdTextOne.text.length == 0) {
        [_setPwdTextOne becomeFirstResponder];
    } else if (self.setPwdTextTwo.text.length == 0) {
        [_setPwdTextTwo becomeFirstResponder];
    } else if (self.setPwdTextThree.text.length == 0) {
        [_setPwdTextThree becomeFirstResponder];
    } else if (self.setPwdTextFour.text.length == 0) {
        [_setPwdTextFour becomeFirstResponder];
    } else {
        //send passcode to native
        _errorNotificationLabel.text = NSLocalizedString(@"meeting_connecting", nil);
        [_setPwdTextOne resignFirstResponder];
        [_setPwdTextTwo resignFirstResponder];
        [_setPwdTextThree resignFirstResponder];
        [_setPwdTextFour resignFirstResponder];
        
        NSString *passcode =[[NSString alloc]initWithFormat:@"%@%@%@%@",self.setPwdTextOne.text,self.setPwdTextTwo.text,self.setPwdTextThree.text,self.setPwdTextFour.text];
        //        NSLog(@"%@",passcode);
        [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:passcode];
    }
}

- (CustomTextField *)setPwdTextOne {
    if(!_setPwdTextOne) {
        _setPwdTextOne = [[CustomTextField alloc] init];
        _setPwdTextOne.delegate = self;
        _setPwdTextOne.custom_delegate = self;
        _setPwdTextOne.background = [UIImage imageNamed:@"icon_input_normal"];
        _setPwdTextOne.textAlignment = NSTextAlignmentCenter;
        _setPwdTextOne.keyboardType = UIKeyboardTypeNumberPad;
        _setPwdTextOne.borderStyle = UITextBorderStyleNone;
        _setPwdTextOne.font = [UIFont systemFontOfSize:26.0];
        _setPwdTextOne.textColor = [UIColor blackColor];
        [_setPwdTextOne addTarget:self action:@selector(editBeginTextOne:)
                 forControlEvents:UIControlEventEditingDidBegin];
        [_setPwdTextOne addTarget:self action:@selector(editEndTextOne:)
                 forControlEvents:UIControlEventEditingDidEnd];
        [_setPwdTextOne addTarget:self action:@selector(editDidChangeTextOne:)
                 forControlEvents:UIControlEventEditingChanged];
        
        [_setPwdTextOne becomeFirstResponder];
        
        [self.passcodeMainView addSubview:_setPwdTextOne];
    }
    return _setPwdTextOne;
}

- (CustomTextField *)setPwdTextTwo {
    if(!_setPwdTextTwo) {
        _setPwdTextTwo = [[CustomTextField alloc] init];
        _setPwdTextTwo.delegate = self;
        _setPwdTextTwo.custom_delegate = self;
        _setPwdTextTwo.background = [UIImage imageNamed:@"icon_input_normal"];
        _setPwdTextTwo.textAlignment = NSTextAlignmentCenter;
        _setPwdTextTwo.keyboardType = UIKeyboardTypeNumberPad;
        _setPwdTextTwo.borderStyle = UITextBorderStyleNone;
        _setPwdTextTwo.font = [UIFont systemFontOfSize:26.0];
        _setPwdTextTwo.textColor = [UIColor blackColor];
        [_setPwdTextTwo addTarget:self action:@selector(editBeginTextTwo:)
                 forControlEvents:UIControlEventEditingDidBegin];
        [_setPwdTextTwo addTarget:self action:@selector(editEndTextTwo:)
                 forControlEvents:UIControlEventEditingDidEnd];
        [_setPwdTextTwo addTarget:self action:@selector(editDidChangeTextTwo:)
                 forControlEvents:UIControlEventEditingChanged];
        
        [self.passcodeMainView addSubview:_setPwdTextTwo];
    }
    return _setPwdTextTwo;
}

- (CustomTextField *)setPwdTextThree {
    if(!_setPwdTextThree) {
        _setPwdTextThree = [[CustomTextField alloc] init];
        _setPwdTextThree.delegate = self;
        _setPwdTextThree.custom_delegate = self;
        _setPwdTextThree.background = [UIImage imageNamed:@"icon_input_normal"];
        _setPwdTextThree.textAlignment = NSTextAlignmentCenter;
        _setPwdTextThree.keyboardType = UIKeyboardTypeNumberPad;
        _setPwdTextThree.borderStyle = UITextBorderStyleNone;
        _setPwdTextThree.font = [UIFont systemFontOfSize:26.0];
        _setPwdTextThree.textColor = [UIColor blackColor];
        [_setPwdTextThree addTarget:self action:@selector(editBeginTextThree:)
                   forControlEvents:UIControlEventEditingDidBegin];
        [_setPwdTextThree addTarget:self action:@selector(editEndTextThree:)
                   forControlEvents:UIControlEventEditingDidEnd];
        [_setPwdTextThree addTarget:self action:@selector(editDidChangeTextThree:)
                   forControlEvents:UIControlEventEditingChanged];
        
        [self.passcodeMainView addSubview:_setPwdTextThree];
    }
    return _setPwdTextThree;
}

- (CustomTextField *)setPwdTextFour {
    if(!_setPwdTextFour) {
        _setPwdTextFour = [[CustomTextField alloc] init];
        _setPwdTextFour.delegate = self;
        _setPwdTextFour.custom_delegate = self;
        _setPwdTextFour.background = [UIImage imageNamed:@"icon_input_normal"];
        _setPwdTextFour.textAlignment = NSTextAlignmentCenter;
        _setPwdTextFour.keyboardType = UIKeyboardTypeNumberPad;
        _setPwdTextFour.borderStyle = UITextBorderStyleNone;
        _setPwdTextFour.font = [UIFont systemFontOfSize:26.0];
        _setPwdTextFour.textColor = [UIColor blackColor];
        [_setPwdTextFour addTarget:self action:@selector(editBeginTextFour:)
                  forControlEvents:UIControlEventEditingDidBegin];
        [_setPwdTextFour addTarget:self action:@selector(editEndTextFour:)
                  forControlEvents:UIControlEventEditingDidEnd];
        [_setPwdTextFour addTarget:self action:@selector(editDidChangeTextFour:)
                  forControlEvents:UIControlEventEditingChanged];
        
        [self.passcodeMainView addSubview:_setPwdTextFour];
    }
    return _setPwdTextFour;
}

- (UILabel *)errorNotificationLabel {
    if(!_errorNotificationLabel) {
        _errorNotificationLabel = [[UILabel alloc] init];
        _errorNotificationLabel.textAlignment = NSTextAlignmentCenter;
        _errorNotificationLabel.textColor = KColorRGB(235,60,0,1.0);
        _errorNotificationLabel.text = @"";
        _errorNotificationLabel.font = [UIFont systemFontOfSize:18.0];
        [self.backGroundView addSubview:_errorNotificationLabel];
    }
    
    return _errorNotificationLabel;
}

- (void)customTextFieldDeleteBackward:(CustomTextField *)textField {
    if (textField == self.setPwdTextFour) {
        if ([textField.text isEqualToString:@""]) {
            [_setPwdTextThree becomeFirstResponder];
            _setPwdTextThree.text = @"";
        }
    } else if (textField == self.setPwdTextThree) {
        if ([textField.text isEqualToString:@""]) {
            [_setPwdTextTwo becomeFirstResponder];
            _setPwdTextTwo.text = @"";
        }
    } else if (textField == self.setPwdTextTwo) {
        if ([textField.text isEqualToString:@""]) {
            [_setPwdTextOne becomeFirstResponder];
            _setPwdTextOne.text = @"";
        }
    }
}

- (UIButton *)hangUpButton {
    if(!_hangUpButton) {
        _hangUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangUpButton setTitle:NSLocalizedString(@"hang_up", nil) forState:UIControlStateNormal];
        [_hangUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _hangUpButton.layer.borderColor = KColorRGB(235,60,0,1.0).CGColor;
        _hangUpButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        
 
        [_hangUpButton setTitleColor:KColorRGB(235,60,0,1.0) forState:UIControlStateNormal];
               _hangUpButton.layer.cornerRadius = 4;
               _hangUpButton.layer.borderWidth = 2;
               _hangUpButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        
        [_hangUpButton addTarget:self action:@selector(onClickHangUp:) forControlEvents:UIControlEventTouchUpInside];
        _hangUpButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _hangUpButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.backGroundView addSubview:_hangUpButton];
    }
    
    return _hangUpButton;
}

#pragma mark -- private function
- (void)onClickHangUp:(UIButton*)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = NO;
}

@end


