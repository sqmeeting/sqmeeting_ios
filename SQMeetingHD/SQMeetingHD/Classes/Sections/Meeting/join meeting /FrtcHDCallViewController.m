#import "FrtcHDCallViewController.h"
#import "Masonry.h"
#import "AppDelegate.h"
#import "FrtcUserDefault.h"
#import "FrtcMakeCallClient.h"
#import "UIStackView+Extensions.h"
#import "UIImage+Extensions.h"
#import "UIControl+Extensions.h"
#import "FrtcUserModel.h"
#import "FrtcHDCallWarnView.h"
#import "UITextField+Extensions.h"
#import "UIViewController+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcHistoryMeetingListView.h"
#import "UIView+Toast.h"
#import "MBProgressHUD+Extensions.h"


@interface FrtcHDCallViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UILabel *conferenceNumberLabel;
@property (nonatomic, strong) UITextField *conferenceNumberTextField;
@property (nonatomic, strong) FrtcHDCallWarnView *numberNotificationView;
@property (nonatomic, strong) UIView *numberPlaceholderView;

@property (nonatomic, strong) UILabel *displayNameLabel;
@property (nonatomic, strong) UITextField *displayNameTextField;
@property (nonatomic, strong) FrtcHDCallWarnView *nameNotificationView;
@property (nonatomic, strong) UIView *namePlaceholderView;


@property (nonatomic, strong) UILabel *microphoneLabel;
@property (nonatomic, strong) UISwitch *microphoneSwitch;
@property (nonatomic, strong) UILabel *line2;

@property (nonatomic, strong) UILabel *cameraLabel;
@property (nonatomic, strong) UISwitch *cameraSwitch;
@property (nonatomic, strong) UILabel *line3;

@property (nonatomic, strong) UILabel *audioOnlyLabel;
@property (nonatomic, strong) UISwitch *audioOnlySwitch;
@property (nonatomic, strong) UILabel *line4;

@property (nonatomic, strong) UIButton *callButton;

@property (nonatomic, getter=isCameraOn) BOOL cameraOn;
@property (nonatomic, getter=isMicrophoneOn) BOOL microphoneOn;
@property (nonatomic, getter=isRememberNameOn) BOOL rememberNameOn;

@property (nonatomic, strong) UIView *topContentView;
@property (nonatomic, strong) UIView *bottomContentView;
@property (nonatomic, strong) UIStackView *topStackView;

@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *alertBtn;
@property (nonatomic, strong) UIView   *divisionView;


@property (nonatomic, strong) FrtcHistoryMeetingListView *historyMeetingListView;

@end

@implementation FrtcHDCallViewController

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"join_meeting_entry",nil);
    NSString *displayName = isLoginSuccess ? [FrtcUserModel fetchUserInfo].real_name :
    [FrtcLocalInforDefault getMeetingDisPlayName];
    self.displayNameTextField.text = displayName;
    self.conferenceNumberTextField.text = [FrtcLocalInforDefault getLastMeetingNumber];
}

- (void)viewWillAppear:(BOOL)animated {
    self.conferenceNumberTextField.text = [FrtcLocalInforDefault getLastMeetingNumber];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSString *conferenceAlias = self.conferenceNumberTextField.text;
    if (!kStringIsEmpty(conferenceAlias)) {
        [FrtcLocalInforDefault saveLastMeetingNumber:conferenceAlias];
    }
    [self.navigationController.view hideToastActivity];
}

- (void)dealloc {
    KUpdateHomeView
}

#pragma mark - ui
- (void)configUI {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"call_cancel", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    @WeakObj(self);
    [cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    [self configView];
}

-(void)configView {
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10.f);
    }];
    
    _topStackView = [[UIStackView alloc]init];
    _topStackView.axis = UILayoutConstraintAxisVertical;
    _topStackView.spacing = 12;
    [self.topContentView addSubview:_topStackView];
    
    [_topStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(KLeftSpacing);
        make.right.bottom.mas_equalTo(-KLeftSpacing);
    }];
    
    [_topStackView addArrangedSubviews:@[self.conferenceNumberLabel,self.conferenceNumberTextField,self.numberNotificationView,self.numberPlaceholderView,self.displayNameLabel,self.displayNameTextField,self.nameNotificationView,self.namePlaceholderView]];
    
    [self.numberPlaceholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.f);
    }];
    [self.namePlaceholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.f);
    }];
    [self.numberNotificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25.f);
    }];
    
    [self.nameNotificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25.f);
    }];
    
    [_topStackView setCustomSpacing:1.f afterViews:@[self.conferenceNumberTextField,self.numberNotificationView,self.displayNameTextField,self.nameNotificationView]];
    
    [self.displayNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    [self.conferenceNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.topContentView.mas_bottom).mas_offset(10);
    }];
    
    [self.microphoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(KLeftSpacing);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.microphoneSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.mas_equalTo(self.microphoneLabel.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(40);
        make.height.mas_greaterThanOrEqualTo(24);
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(self.microphoneLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(self.line2.mas_bottom).mas_offset(20);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.cameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.mas_equalTo(self.cameraLabel.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(40);
        make.height.mas_greaterThanOrEqualTo(24);
    }];
    
    [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(self.cameraLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.divisionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.line3.mas_bottom).mas_offset(0);
        make.height.mas_equalTo(10);
    }];
    
    [self.audioOnlyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.top.mas_equalTo(self.divisionView.mas_bottom).mas_offset(20);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.audioOnlySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.mas_equalTo(self.audioOnlyLabel.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(40);
        make.height.mas_greaterThanOrEqualTo(24);
    }];
    
    [self.line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(self.audioOnlyLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(self.line4.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(kButtonHeight);
    }];
    
}

#pragma mark -- private function
- (void)didClickCallButton:(UIButton*)sender {
    NSString *conferenceAlias = self.conferenceNumberTextField.text;
    NSString *conferenceName = self.displayNameTextField.text;
    
    //save meeting number
    if(!kStringIsEmpty(conferenceAlias)) {
        [FrtcLocalInforDefault saveLastMeetingNumber:conferenceAlias];
    }else{
        [self settingNumberWarnViewIsShow:YES]; return;
    }
    
    NSString *meetingName=[conferenceName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!kStringIsEmpty(meetingName)) {
        if (!isLoginSuccess) {
            [FrtcLocalInforDefault saveMeetingName:meetingName];
        }
    }else{
        [self settingNameWarnberViewIsShow:YES]; return;
    }
    
    NSString *meetingnumber = [conferenceAlias stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self joinMeetingWithMeetingNumber:meetingnumber meetingName:meetingName meetingPassword:@""];
}

- (void)joinMeetingWithMeetingNumber:(NSString *)meetingNumber meetingName:(NSString *)meetingName meetingPassword:(NSString *)meetingPassword {
    if (![FrtcHelpers isNetwork]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        return;
    }
    if ([FrtcHelpers f_isInMieeting]) {
        return;
    }
    self.callButton.enabled = NO;
    NSString *conferenceCallRate = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
    @WeakObj(self)
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    //[MBProgressHUD showActivityMessage:@""];
    FRTCSDKCallParam callParam;
    callParam.conferenceNumber = meetingNumber;
    callParam.clientName = meetingName;
    callParam.callRate = numberCallRate;
    callParam.muteCamera = !self.cameraSwitch.isOn;
    callParam.muteMicrophone = !self.microphoneSwitch.isOn;
    callParam.audioCall = self.audioOnlySwitch.isOn;
    if (isLoginSuccess) {
        callParam.userToken = [FrtcUserModel fetchUserInfo].user_token;
    }
    
    if (!kStringIsEmpty(meetingPassword)) {
        callParam.password = meetingPassword;
    }
    
    [[FrtcMakeCallClient sharedSDKContext] makeCall:self withCallParam:callParam withCallSuccessBlock:^{
        [self.navigationController.view hideToastActivity];
        self.callButton.enabled = YES;
    } withCallFailureBlock:^(FRTCMeetingStatusReason status, NSString * _Nonnull errMsg) {
        if (kStringIsEmpty(errMsg)) { return; }
        @StrongObj(self)
        self.callButton.enabled = YES;
        [self.navigationController.view hideToastActivity];
    } withInputPassCodeCallBack:^{
        self.callButton.enabled = YES;
        [self.navigationController.view hideToastActivity];
        @StrongObj(self)
        [self showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil) textFieldStyle:FTextFieldPassword alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
            if (index == 1) {
                [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:alertString];
                [[FrtcUserDefault sharedUserDefault] setObject:alertString forKey:MEETING_PASSWORD];
            }else{
                [[FrtcCall frtcSharedCallClient] frtcHangupCall];
            }
        }];
    }];
}

- (void)settingNumberWarnViewIsShow:(BOOL)isShow {
    [UIView animateWithDuration:0.25 animations:^{
        self.numberNotificationView.alpha = isShow ? 1.0f : 0.f;
        self.numberNotificationView.hidden = !isShow;
    } completion:nil];
}

- (void)settingNameWarnberViewIsShow:(BOOL)isShow {
    [UIView animateWithDuration:0.25 animations:^{
        self.nameNotificationView.alpha = isShow ? 1.0f : 0.f;
        self.nameNotificationView.hidden = !isShow;
    } completion:nil];
}

- (void)textFieldTextDidChange {
    
    _clearBtn.hidden =  !(self.conferenceNumberTextField.text.length > 0);
    
    NSString *placeholder = @" ";
    
    NSRange currentTextRange = [self.conferenceNumberTextField selectedRange];
    NSInteger rangeLength = currentTextRange.length;
    
    NSString *subCursorCurrentString = [self.conferenceNumberTextField.text substringToIndex:currentTextRange.location];
    NSString *noSpaceSubCursorChangedString = [subCursorCurrentString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSInteger spaceCount = subCursorCurrentString.length - noSpaceSubCursorChangedString.length;
    NSRange noSpaceCurrentRange = NSMakeRange(currentTextRange.location-spaceCount, rangeLength);
    
    long subCursorChangedSpaceCount = 0;
    if (noSpaceSubCursorChangedString.length >= 1) {
        subCursorChangedSpaceCount = (noSpaceSubCursorChangedString.length -1) / 3;
    }
    
    NSRange changedTextRange = NSMakeRange(noSpaceCurrentRange.location+subCursorChangedSpaceCount, rangeLength);
    
    NSString *noSpaceTextString = [self.conferenceNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableString *muStr = [noSpaceTextString mutableCopy];
    if (muStr.length >3) {
        int i=2;
        while (i<muStr.length) {
            if ((i+1)%4==0) {
                [muStr insertString:placeholder atIndex:i];
            }
            i++;
        }
    }
    self.conferenceNumberTextField.text = muStr;
    [self.conferenceNumberTextField setSelectedRange:changedTextRange];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.conferenceNumberTextField setSelectedRange:changedTextRange];
    });
}

- (void)setHistoryMeetingListWithList:(NSArray *)meetingList {
    @WeakObj(self);
    if (self.historyMeetingListView) {
        [self.historyMeetingListView disMiss];
        self.historyMeetingListView = nil;
    }else {
        self.historyMeetingListView = [[FrtcHistoryMeetingListView alloc]init];
        self.historyMeetingListView.historyArray = meetingList;
        self.historyMeetingListView.history = YES;
        self.historyMeetingListView.historySelectedBlock = ^(FHomeMeetingListModel * _Nonnull info) {
            @StrongObj(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.conferenceNumberTextField.text = info.meetingNumber;
                [self textFieldTextDidChange];
                self.historyMeetingListView = nil;
            });
        };
        self.historyMeetingListView.clearhistoryBlock = ^{
            @StrongObj(self)
            [self showAlertWithTitle:NSLocalizedString(@"clear_history", nil) message:NSLocalizedString(@"clear_history_detail", nil) buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
                if (index == 0) { return; }
                if ([FrtcHomeMeetingListPresenter deleteAllMeeting]) {
                    [self.conferenceNumberTextField resignFirstResponder];
                    self.clearBtn.frame  = CGRectMake(60, 0, 40, 30);
                    self.alertBtn.hidden = YES;
                    [self.historyMeetingListView disMiss];
                    self.historyMeetingListView = nil;
                    KUpdateHomeView
                }
            }];
        };
        [self.view addSubview:self.historyMeetingListView];
        [self.historyMeetingListView mas_makeConstraints:^(MASConstraintMaker *make) {
            @StrongObj(self)
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.height.mas_equalTo(190);
            make.top.mas_equalTo(self.conferenceNumberTextField.mas_bottom).mas_offset(10);
        }];
    }
}

- (void)meetingNumberFieldRightView {
    @WeakObj(self)
    NSArray *meetingList = [FrtcHomeMeetingListPresenter getMeetingList];
    
    UIView *numberRightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _clearBtn.hidden = YES;
    [_clearBtn setImage:[UIImage imageNamed:@"icon_cancle_textfield"] forState:UIControlStateNormal];
    [_clearBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        self.conferenceNumberTextField.text = @"";
        [self.conferenceNumberTextField resignFirstResponder];
        self.clearBtn.hidden = YES;
    }];
    _clearBtn.frame = meetingList.count <= 0 ?  CGRectMake(60, 0, 40, 30) : CGRectMake(20, 0, 40, 30);
    
    _alertBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_alertBtn setImage:[UIImage imageNamed:@"icon_triangle"] forState:UIControlStateNormal];
    _alertBtn.frame = CGRectMake(60, 0, 40, 30);
    _alertBtn.hidden = meetingList.count <= 0 ? YES : NO;
    
    [_alertBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self.conferenceNumberTextField resignFirstResponder];
        [self setHistoryMeetingListWithList:meetingList];
    }];
    
    [numberRightView addSubview:_clearBtn];
    [numberRightView addSubview:_alertBtn];
    self.conferenceNumberTextField.rightView = numberRightView;
    self.conferenceNumberTextField.rightViewMode = UITextFieldViewModeAlways;
}


#pragma mark -- lazy load

- (UILabel *)conferenceNumberLabel {
    if(!_conferenceNumberLabel) {
        _conferenceNumberLabel = [[UILabel alloc] init];
        _conferenceNumberLabel.text = NSLocalizedString(@"meeting_id", nil);
        _conferenceNumberLabel.textColor = KTextColor;
        _conferenceNumberLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _conferenceNumberLabel;
}

- (UITextField *)conferenceNumberTextField {
    @WeakObj(self)
    if(!_conferenceNumberTextField) {
        _conferenceNumberTextField = [[UITextField alloc] init];
        _conferenceNumberTextField.delegate = self;
        _conferenceNumberTextField.textAlignment = NSTextAlignmentLeft;
        _conferenceNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
        _conferenceNumberTextField.textColor = KTextColor;
        _conferenceNumberTextField.font = [UIFont systemFontOfSize:16.0];
        _conferenceNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self meetingNumberFieldRightView];
        [_conferenceNumberTextField addBlockForControlEvents:UIControlEventEditingDidBegin block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.clearBtn.hidden = kStringIsEmpty(self.conferenceNumberTextField.text);
            [self settingNumberWarnViewIsShow:NO];
        }];
        [_conferenceNumberTextField addBlockForControlEvents:UIControlEventEditingChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self textFieldTextDidChange];
        }];
        NSString *textStr = [FrtcLocalInforDefault getLastMeetingNumber];
        _conferenceNumberTextField.text = textStr;
    }
    return _conferenceNumberTextField;
}

- (UILabel *)displayNameLabel {
    if(!_displayNameLabel) {
        _displayNameLabel = [[UILabel alloc] init];
        _displayNameLabel.textAlignment = NSTextAlignmentLeft;
        _displayNameLabel.numberOfLines = 1.0;
        _displayNameLabel.text = NSLocalizedString(@"display_name", nil);
        _displayNameLabel.textColor = [UIColor blackColor];
        _displayNameLabel.font = [UIFont systemFontOfSize:16.0];
    }
    
    return _displayNameLabel;
}

- (UITextField *)displayNameTextField {
    @WeakObj(self)
    if(!_displayNameTextField) {
        _displayNameTextField = [[UITextField alloc] init];
        _displayNameTextField.delegate = self;
        _displayNameTextField.textAlignment = NSTextAlignmentLeft;
        _displayNameTextField.textColor = [UIColor blackColor];
        _displayNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _displayNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _displayNameTextField.placeholder = NSLocalizedString(@"please_name", nil);
        _displayNameTextField.text = [FrtcLocalInforDefault getMeetingDisPlayName];
        _displayNameTextField.font = [UIFont systemFontOfSize:16.0];
        [_displayNameTextField addBlockForControlEvents:UIControlEventEditingDidBegin block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self settingNameWarnberViewIsShow:NO];
        }];
        [_displayNameTextField addBlockForControlEvents:UIControlEventEditingChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            UITextField *serverField = (UITextField *)sender;
            NSString *str = serverField.text;
           
            if (str.length > 30) {
                self.displayNameTextField.text = [str substringToIndex:30];
                [self.navigationController.view makeToast:NSLocalizedString(@"setting_cannot_char", nil)];
            }
        }];
    }
    return _displayNameTextField;
}

//limit the name length
#pragma mark - UITextFieldDelegate
-(void)textFiledEditChanged:(NSNotification *)obj{
    if ([obj.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)obj.object;
        
        NSString *toBeString = textField.text;
        if (toBeString.length > 20) {
            textField.text = [toBeString substringToIndex:20];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _clearBtn.hidden = YES;
}

- (FrtcHDCallWarnView *)nameNotificationView {
    if(!_nameNotificationView) {
        _nameNotificationView = [[FrtcHDCallWarnView alloc]init];
        _nameNotificationView.content = NSLocalizedString(@"meeting_name_error", nil);
        _nameNotificationView.hidden = YES;
    }
    return _nameNotificationView;
}

- (FrtcHDCallWarnView *)numberNotificationView {
    if (!_numberNotificationView) {
        _numberNotificationView = [[FrtcHDCallWarnView alloc]init];
        _numberNotificationView.content = NSLocalizedString(@"meeting_id_error", nil);
        _numberNotificationView.hidden = YES;
    }
    return _numberNotificationView;
}

- (UILabel *)microphoneLabel {
    if(!_microphoneLabel) {
        _microphoneLabel = [[UILabel alloc] init];
        _microphoneLabel.textAlignment = NSTextAlignmentLeft;
        _microphoneLabel.numberOfLines = 1.0;
        _microphoneLabel.text = NSLocalizedString(@"phone_microphone", nil);
        _microphoneLabel.textColor = [UIColor blackColor];
        _microphoneLabel.font = [UIFont systemFontOfSize:16.0];
        [self.bottomContentView addSubview:_microphoneLabel];
    }
    
    return _microphoneLabel;
}

- (UISwitch *)microphoneSwitch {
    if(!_microphoneSwitch) {
        _microphoneSwitch = [[UISwitch alloc] init];
        _microphoneSwitch.on = NO;
        [_microphoneSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
        }];
        _microphoneSwitch.onTintColor = kMainColor;
        [self.bottomContentView addSubview:_microphoneSwitch];
    }
    
    return _microphoneSwitch;
}

- (UILabel *)line2 {
    if(!_line2) {
        _line2 = [[UILabel alloc] init];
        _line2.backgroundColor = KLineColor;
        [self.bottomContentView addSubview:_line2];
    }
    
    return _line2;
}

- (UILabel *)cameraLabel {
    if(!_cameraLabel) {
        _cameraLabel = [[UILabel alloc] init];
        _cameraLabel.textAlignment = NSTextAlignmentLeft;
        _cameraLabel.numberOfLines = 1.0;
        _cameraLabel.text = NSLocalizedString(@"phone_camera", nil);
        _cameraLabel.textColor = [UIColor blackColor];
        _cameraLabel.font = [UIFont systemFontOfSize:16.0];
        [self.bottomContentView addSubview:_cameraLabel];
    }
    
    return _cameraLabel;
}

- (UISwitch *)cameraSwitch {
    @WeakObj(self)
    if(!_cameraSwitch) {
        _cameraSwitch = [[UISwitch alloc] init];
        _cameraSwitch.on = NO;
        _cameraSwitch.onTintColor = kMainColor;
        [_cameraSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.cameraSwitch.isOn) {
                self.audioOnlySwitch.on = NO;
            }
        }];
        [self.bottomContentView addSubview:_cameraSwitch];
    }
    return _cameraSwitch;
}

- (UILabel *)line3 {
    if(!_line3) {
        _line3 = [[UILabel alloc] init];
        _line3.backgroundColor = KLineColor;
        [self.bottomContentView addSubview:_line3];
    }
    return _line3;
}

- (UILabel *)audioOnlyLabel {
    if(!_audioOnlyLabel) {
        _audioOnlyLabel = [[UILabel alloc] init];
        _audioOnlyLabel.textAlignment = NSTextAlignmentLeft;
        _audioOnlyLabel.numberOfLines = 1.0;
        _audioOnlyLabel.text = NSLocalizedString(@"audio_only", nil);
        _audioOnlyLabel.textColor = [UIColor blackColor];
        _audioOnlyLabel.font = [UIFont systemFontOfSize:16.0];
        [self.bottomContentView addSubview:_audioOnlyLabel];
    }
    
    return _audioOnlyLabel;
}

- (UISwitch *)audioOnlySwitch{
    @WeakObj(self)
    if(!_audioOnlySwitch) {
        _audioOnlySwitch = [[UISwitch alloc] init];
        _audioOnlySwitch.on =  NO;
        _audioOnlySwitch.onTintColor = kMainColor;
        [_audioOnlySwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.audioOnlySwitch.isOn) {
                [MBProgressHUD showMessage:NSLocalizedString(@"audio_only_message", nil)];
                self.cameraSwitch.on = NO;
            }
        }];
        [self.bottomContentView addSubview:_audioOnlySwitch];
    }
    
    return _audioOnlySwitch;
}

- (UILabel *)line4 {
    if(!_line4) {
        _line4 = [[UILabel alloc] init];
        _line4.backgroundColor = KLineColor;
        [self.bottomContentView addSubview:_line4];
    }
    return _line4;
}

- (UIButton *)callButton {
    if(!_callButton) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callButton setTitle:NSLocalizedString(@"join_meeting", nil) forState:UIControlStateNormal];
        [_callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_callButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_callButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        _callButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_callButton addTarget:self action:@selector(didClickCallButton:) forControlEvents:UIControlEventTouchUpInside];
        _callButton.layer.masksToBounds = YES;
        _callButton.layer.cornerRadius = KCornerRadius;
        [self.bottomContentView addSubview:_callButton];
    }
    
    return _callButton;
}

- (UIView *)topContentView {
    if (!_topContentView) {
        _topContentView = [[UIView alloc]init];
        _topContentView.backgroundColor = UIColor.whiteColor;
        _topContentView.clipsToBounds = YES;
        [self.contentView addSubview:_topContentView];
    }
    return _topContentView;
}

- (UIView *)bottomContentView {
    if (!_bottomContentView) {
        _bottomContentView = [[UIView alloc]init];
        _bottomContentView.backgroundColor = UIColor.whiteColor;
        _bottomContentView.clipsToBounds = YES;
        [self.contentView addSubview:_bottomContentView];
    }
    return _bottomContentView;
}

- (UIView *)numberPlaceholderView {
    if (!_numberPlaceholderView) {
        _numberPlaceholderView = [UIView new];
    }
    return _numberPlaceholderView;;
}

- (UIView *)namePlaceholderView {
    if (!_namePlaceholderView) {
        _namePlaceholderView = [UIView new];
    }
    return _namePlaceholderView;;
}

- (UIView *)divisionView {
    if (!_divisionView) {
        _divisionView = [[UIView alloc]init];
        _divisionView.backgroundColor = KBGColor;
        [self.bottomContentView addSubview:_divisionView];
    }
    return _divisionView;
}

#pragma mark -- private function
- (void)cancelButton:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
