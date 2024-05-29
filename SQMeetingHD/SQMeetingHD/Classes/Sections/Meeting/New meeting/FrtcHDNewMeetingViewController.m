#import "FrtcHDNewMeetingViewController.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "FrtcHistoryMeetingListView.h"
#import "FrtcNewMeetingPresenter.h"
#import "FrtcNewMeetingRoomListModel.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcCall.h"
#import "FrtcMakeCallClient.h"
#import "UIViewController+Extensions.h"
#import "FrtcUserModel.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "UIView+Toast.h"

@interface FrtcHDNewMeetingViewController () <FrtcNewMeetingProtocol>

@property (nonatomic, getter=isPersonal) BOOL personal;

@property (nonatomic, strong) UIView *openVideoView;
@property (nonatomic, strong) UIView *meetingNumberView;
@property (nonatomic, strong) UITextField *meetingNumbertextField;
@property (nonatomic, strong) UIView *meetingNumberBottomView;
@property (nonatomic, strong) UIButton *beginMeetingBtn;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UISwitch *openVideoSwitch;
@property (nonatomic, strong) UISwitch *meetingNumberSwitch;
@property (nonatomic, strong) UIStackView *verticalStackView;

@property (nonatomic, strong) FrtcNewMeetingPresenter *presenter;
@property (nonatomic, strong) NSMutableArray <FNewMeetingRoomListInfo *> *meetingRoomList;
@property (nonatomic, strong) FrtcHistoryMeetingListView *historyMeetingListView;
@property (nonatomic, strong) FNewMeetingRoomListInfo *currentRoomInfo;

@end

@implementation FrtcHDNewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"new_meeting", nil);
}

- (void)viewWillAppear:(BOOL)animated { }

- (void)dealloc {
    KUpdateHomeView
}

#pragma mark - add view

- (void)configUI {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"dialog_cancel", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    @WeakObj(self);
    [cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    
    [self addOpenVideoView];
    [self addMeetingNumberView];
    
    [self.beginMeetingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(40.f);
        make.top.equalTo(self.meetingNumberView.mas_bottom).mas_offset(20);
    }];
}

- (void)addOpenVideoView {
    
    [self.openVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50.f);
        make.top.mas_equalTo(10);
    }];
    
    UILabel *titleLable = [UILabel new];
    titleLable.text = NSLocalizedString(@"open_video", nil);
    titleLable.textColor = KTextColor;
    titleLable.font = [UIFont systemFontOfSize:16.f];
    
    UIStackView *stackView = [UIStackView new];
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    [self.openVideoView addSubview:stackView];
    
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.equalTo(self.openVideoView);
    }];
    [stackView addArrangedSubviews:@[titleLable,self.openVideoSwitch]];
}

- (void)addMeetingNumberView {
    
    [self.meetingNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.openVideoView);
        make.top.equalTo(self.openVideoView.mas_bottom).mas_offset(10);
    }];
    
    UILabel *titleLable = [UILabel new];
    titleLable.text = NSLocalizedString(@"use_per_meetingn", nil);
    titleLable.textColor = KTextColor;
    titleLable.font = [UIFont systemFontOfSize:16.f];
    
    UIStackView *horizontalStackView = [UIStackView new];
    horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
    horizontalStackView.distribution = UIStackViewDistributionEqualSpacing;
    
    [self.meetingNumberView addSubview:self.verticalStackView];
    
    [self.verticalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.top.mas_equalTo(13);
        make.bottom.mas_equalTo(-13);
    }];
    
    [horizontalStackView addArrangedSubviews:@[titleLable,self.meetingNumberSwitch]];
    
    [self.verticalStackView addArrangedSubviews:@[horizontalStackView,self.meetingNumberBottomView]];
    
    [self.meetingNumberBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - FrtcNewMeetingProtocol

- (void)responseMeetingRoomSuccess:(NSArray <FNewMeetingRoomListInfo *> * _Nullable)result errMsg:(NSString * _Nullable)errMsg {
    if (!errMsg) {
        [self.meetingRoomList removeAllObjects];
        [self.meetingRoomList addObjectsFromArray:result];
        if (self.meetingRoomList.count > 0 ) {
            [self roomMeetingNumberShow:YES];
            _currentRoomInfo = self.meetingRoomList[0];
            self.meetingNumbertextField.text = self.meetingRoomList[0].meeting_number;
        }else{
            self.meetingNumberSwitch.on = NO;
            self.personal = NO;
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_not_meetingNumber", nil)];
        }
    }else{
        [MBProgressHUD showMessage:errMsg];
    }
}

- (void)responseScheduleMeetingInfoSuccess:(FNewMeetingScheduleMeetingInfo *)info errMsg:(NSString *)errMsg {
    if (!errMsg) {
        [self configCallParameter:info.meeting_number meetingName:info.meeting_name password:info.meeting_password];
    }else{
        self.beginMeetingBtn.enabled = YES;
        [MBProgressHUD showMessage:errMsg];
    }
}

#pragma mark - config join Meeting
- (void)configCallParameter:(NSString *)meetingNumbver meetingName:(NSString *)meetingName password:(NSString *)password {
    NSString *conferenceCallRate = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
    ISMLog(@"numberCallRate = %d",numberCallRate);
    FRTCSDKCallParam callParam;
    callParam.conferenceNumber = meetingNumbver;
    NSString *displayName = [FrtcUserModel fetchUserInfo].real_name;
    callParam.clientName = displayName;
    callParam.callRate = numberCallRate;
    callParam.muteCamera = !self.openVideoSwitch.isOn;
    callParam.muteMicrophone = YES;
    callParam.audioCall = NO;
    if (isLoginSuccess) {
        callParam.userToken = [FrtcUserModel fetchUserInfo].user_token;
    }
    if (!kStringIsEmpty(password)) {
        callParam.password = password;
    }
    [self joinMeetingWithCallParam:callParam];
}

- (void)joinMeetingWithCallParam:(FRTCSDKCallParam)callParam {
    if (![FrtcHelpers isNetwork]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        return;
    }
    @WeakObj(self);
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    [[FrtcMakeCallClient sharedSDKContext] makeCall:self withCallParam:callParam withCallSuccessBlock:^{
        [self.navigationController.view hideToastActivity];
        self.beginMeetingBtn.enabled = YES;
    } withCallFailureBlock:^(FRTCMeetingStatusReason status, NSString * _Nonnull errMsg) {
        if (kStringIsEmpty(errMsg)) { return; }
        @StrongObj(self)
        [self.navigationController.view hideToastActivity];
        self.beginMeetingBtn.enabled = YES;
    } withInputPassCodeCallBack:^{
        [self.navigationController.view hideToastActivity];
        self.beginMeetingBtn.enabled = YES;
    }];
}

#pragma mark - action
- (void)popUpHistoryMeetingVC {
    @WeakObj(self);
    if (self.historyMeetingListView) {
        [self.historyMeetingListView disMiss];
        self.historyMeetingListView = nil;
    }else {
        self.historyMeetingListView = [[FrtcHistoryMeetingListView alloc]init];
        self.historyMeetingListView.array = self.meetingRoomList;
        self.historyMeetingListView.selectedBlock = ^(FNewMeetingRoomListInfo * _Nonnull info) {
            @StrongObj(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_currentRoomInfo = info;
                self.meetingNumbertextField.text = info.meeting_number;
                self.historyMeetingListView = nil;
            });
        };
        [self.view addSubview:self.historyMeetingListView];
        [self.historyMeetingListView mas_makeConstraints:^(MASConstraintMaker *make) {
            @StrongObj(self)
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.height.mas_equalTo(190);
            make.top.mas_equalTo(self.meetingNumbertextField.mas_bottom).mas_offset(10);
        }];
    }
}

- (void)startMeeting {
        
    if ([FrtcHelpers f_isInMieeting]) {
        return;
    }

    self.beginMeetingBtn.enabled = NO;
    //if personal meeting
    if (self.isPersonal) {
        if (!kStringIsEmpty(self.meetingNumbertextField.text) && self.meetingRoomList.count > 0) {
            [self configCallParameter:_currentRoomInfo.meeting_number meetingName: _currentRoomInfo.meetingroom_name password:_currentRoomInfo.meeting_password];
        }
    }else{
        [self.presenter requestScheduleMeeting];
    }
}

- (void)roomMeetingNumberShow:(BOOL)isShow{
    [UIView animateWithDuration:0.25 animations:^{
        self.meetingNumberBottomView.alpha = isShow ? 1.0 : 0.0;
        self.meetingNumberBottomView.hidden = !isShow;
        [self.verticalStackView layoutIfNeeded];
    }];
}

#pragma mark - lazy

- (UIView *)openVideoView {
    if (!_openVideoView) {
        _openVideoView = [[UIView alloc]init];
        _openVideoView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:_openVideoView];
    }
    return _openVideoView;
}

- (UIView *)meetingNumberView {
    if (!_meetingNumberView) {
        _meetingNumberView = [[UIView alloc]init];
        _meetingNumberView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:_meetingNumberView];
    }
    return _meetingNumberView;
}

- (UITextField *)meetingNumbertextField {
    if (!_meetingNumbertextField) {
        _meetingNumbertextField = [UITextField new];
        _meetingNumbertextField.enabled =  NO;
        _meetingNumbertextField.placeholder = NSLocalizedString(@"please_you_meetingN", nil);
        _meetingNumbertextField.borderStyle = UITextBorderStyleNone;
    }
    return _meetingNumbertextField;
}

- (UIView *)meetingNumberBottomView {
    if (!_meetingNumberBottomView) {
        _meetingNumberBottomView = [[UIView alloc]init];
        _meetingNumberBottomView.hidden = YES;
        _meetingNumberBottomView.layer.borderColor = KLineColor.CGColor;
        _meetingNumberBottomView.layer.borderWidth = 1.0;
        _meetingNumberBottomView.layer.cornerRadius = KCornerRadius;
        _meetingNumberBottomView.layer.masksToBounds = YES;
        UIStackView *stackView = [UIStackView new];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        [_meetingNumberBottomView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.right.mas_equalTo(-14);
            make.top.bottom.mas_equalTo(0);
        }];
        [stackView addArrangedSubviews:@[self.meetingNumbertextField,self.rightBtn]];
    }
    return _meetingNumberBottomView;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        @WeakObj(self);
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"btn_more_normal_22x22_"] forState:UIControlStateNormal];
        [_rightBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self popUpHistoryMeetingVC];
        }];
    }
    return _rightBtn;
}

- (UIButton *)beginMeetingBtn {
    @WeakObj(self)
    if(!_beginMeetingBtn) {
        _beginMeetingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beginMeetingBtn setTitle:NSLocalizedString(@"start_meeting", nil) forState:UIControlStateNormal];
        [_beginMeetingBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _beginMeetingBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_beginMeetingBtn setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_beginMeetingBtn setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        [_beginMeetingBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self startMeeting];
        }];
        _beginMeetingBtn.layer.masksToBounds = YES;
        _beginMeetingBtn.layer.cornerRadius = KCornerRadius;
        [self.contentView addSubview:_beginMeetingBtn];
    }
    return _beginMeetingBtn;
}

- (UISwitch *)meetingNumberSwitch {
    if (!_meetingNumberSwitch) {
        @WeakObj(self);
        _meetingNumberSwitch = [[UISwitch alloc]init];
        [_meetingNumberSwitch setOn:NO];
        _meetingNumberSwitch.onTintColor = kMainColor;
        [_meetingNumberSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            UISwitch *tch = (UISwitch *)sender;
            self.personal = tch.on;
            if (self.personal) {
                [self.presenter requestMeetingRoomList];
            }else{
                self.meetingNumbertextField.text = @"";
                [self roomMeetingNumberShow:NO];
            }
        }];
    }
    return _meetingNumberSwitch;
}

- (UISwitch *)openVideoSwitch {
    if (!_openVideoSwitch) {
        _openVideoSwitch = [[UISwitch alloc]init];
        [_openVideoSwitch setOn:NO];
        _openVideoSwitch.onTintColor = kMainColor;
        [_openVideoSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            ISMLog(@"sender.isOn = %@",sender);
        }];
    }
    return _openVideoSwitch;
}

- (UIStackView *)verticalStackView {
    if (!_verticalStackView) {
        _verticalStackView = [UIStackView new];
        _verticalStackView.axis = UILayoutConstraintAxisVertical;
        _verticalStackView.spacing = 10;
    }
    return _verticalStackView;
}

- (FrtcNewMeetingPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[FrtcNewMeetingPresenter alloc]init];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (NSMutableArray *)meetingRoomList {
    if (!_meetingRoomList) {
        _meetingRoomList = [NSMutableArray new];
    }
    return _meetingRoomList;
}

@end
