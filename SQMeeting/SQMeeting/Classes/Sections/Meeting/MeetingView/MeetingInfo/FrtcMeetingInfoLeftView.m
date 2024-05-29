#import "FrtcMeetingInfoLeftView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcUserModel.h"
#import "FrtcInvitationInfoManage.h"

#define KMeetingInfoLeftTopSpacing  15


@interface FrtcMeetingInfoLeftView ()

@property (nonatomic, strong) UILabel *numberLable;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *passwordLabel;
@property (nonatomic, strong) UILabel *sharedLable;
@property (nonatomic, strong) UIButton *infoCopyBtn;

@property (nonatomic, strong) UILabel *meetingNumberLable;
@property (nonatomic, strong) UILabel *meetingNameLable;
@property (nonatomic, strong) UILabel *meetingPasswordLabel;
@property (nonatomic, strong) UILabel *meetingSharedLable;
@property (nonatomic, getter=isShowPassword) BOOL showPassword;

@end

@implementation FrtcMeetingInfoLeftView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self meetingLeftInfoViewLayout];
    }
    return self;
}

- (void)meetingLeftInfoViewLayout {
    
    [self.numberLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(85);
        make.top.mas_equalTo(KMeetingInfoLeftTopSpacing);
    }];
    
    [self.meetingNumberLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.numberLable);
        make.left.equalTo(self.numberLable.mas_right).mas_offset(10);
    }];
    
    [self.infoCopyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.meetingNumberLable.mas_right).mas_offset(10);
        make.centerY.equalTo(self.meetingNumberLable);
        make.right.mas_equalTo(0);
    }];
    
    [self.nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.numberLable);
        make.width.equalTo(self.numberLable);
        make.top.equalTo(self.numberLable.mas_bottom).mas_offset(KMeetingInfoLeftTopSpacing);
    }];
    
    [self.meetingNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLable);
        make.left.equalTo(self.nameLable.mas_right).mas_offset(10);
    }];
    
    [self.passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.numberLable);
        make.width.equalTo(self.numberLable);
        make.top.equalTo(self.nameLable.mas_bottom).mas_offset(KMeetingInfoLeftTopSpacing);
    }];
    
    [self.meetingPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.passwordLabel);
        make.left.equalTo(self.passwordLabel.mas_right).mas_offset(10);
    }];
    
    [self.sharedLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.numberLable);
        make.width.equalTo(self.numberLable);
        make.top.equalTo(self.passwordLabel.mas_bottom).mas_offset(KMeetingInfoLeftTopSpacing);
    }];
    
    [self.meetingSharedLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sharedLable.mas_top);
        make.left.equalTo(self.meetingNameLable);
        make.right.mas_equalTo(0);
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - action

- (void)setMeetingInfo:(FHomeMeetingListModel *)meetingInfo {
    _meetingInfo = meetingInfo;
    self.meetingNumberLable.text = _meetingInfo.meetingNumber;
    self.meetingNameLable.text = _meetingInfo.ownerUserName;
    self.meetingPasswordLabel.text = _meetingInfo.meetingPassword;
    self.showPassword = _meetingInfo.isPassword;
    self.meetingSharedLable.text = _meetingInfo.meetingUrl;
}

- (void)setShowPassword:(BOOL)showPassword {
    _showPassword = showPassword;
    if (!_showPassword) {
        self.passwordLabel.hidden = self.meetingPasswordLabel.hidden = YES;
        [self.sharedLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.nameLable.mas_bottom).mas_offset(KMeetingInfoLeftTopSpacing);
        }];
    }
}

- (void)shareMeetingInfo {
    [FrtcInvitationInfoManage shareInvitationInfo:_meetingInfo];
}

#pragma mark - lazy

- (UILabel *)numberLable {
    if (!_numberLable) {
        _numberLable = [[UILabel alloc]init];
        _numberLable.text = NSLocalizedString(@"call_number", nil);
        _numberLable.textColor = UIColor.whiteColor;
        _numberLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_numberLable];
    }
    return _numberLable;
}

- (UILabel *)nameLable {
    if (!_nameLable) {
        _nameLable = [[UILabel alloc]init];
        _nameLable.text = NSLocalizedString(@"meeting_host", nil);
        _nameLable.textColor = UIColor.whiteColor;
        _nameLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_nameLable];
    }
    return _nameLable;
}

- (UILabel *)passwordLabel {
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc]init];
        _passwordLabel.text = NSLocalizedString(@"string_pwd", nil);
        _passwordLabel.textColor = UIColor.whiteColor;
        _passwordLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_passwordLabel];
    }
    return _passwordLabel;
}

- (UILabel *)sharedLable {
    if (!_sharedLable) {
        _sharedLable = [[UILabel alloc]init];
        _sharedLable.text = NSLocalizedString(@"meeting_invite_link", nil);
        _sharedLable.textColor = UIColor.whiteColor;
        _sharedLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_sharedLable];
    }
    return _sharedLable;
}

- (UILabel *)meetingNumberLable {
    if (!_meetingNumberLable) {
        _meetingNumberLable = [[UILabel alloc]init];
        _meetingNumberLable.text = @"";
        _meetingNumberLable.textColor = UIColor.whiteColor;
        _meetingNumberLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_meetingNumberLable];
    }
    return _meetingNumberLable;
}

- (UILabel *)meetingNameLable {
    if (!_meetingNameLable) {
        _meetingNameLable = [[UILabel alloc]init];
        _meetingNameLable.text = @"";
        _meetingNameLable.textColor = UIColor.whiteColor;
        _meetingNameLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_meetingNameLable];
    }
    return _meetingNameLable;
}

- (UILabel *)meetingPasswordLabel {
    if (!_meetingPasswordLabel) {
        _meetingPasswordLabel = [[UILabel alloc]init];
        _meetingPasswordLabel.text = @"";
        _meetingPasswordLabel.textColor = UIColor.whiteColor;
        _meetingPasswordLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_meetingPasswordLabel];
    }
    return _meetingPasswordLabel;
}

- (UILabel *)meetingSharedLable {
    if (!_meetingSharedLable) {
        _meetingSharedLable = [[UILabel alloc]init];
        _meetingSharedLable.text = @"";
        _meetingSharedLable.textColor = UIColor.whiteColor;
        _meetingSharedLable.numberOfLines = 0;
        _meetingSharedLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_meetingSharedLable];
    }
    return _meetingSharedLable;
}

- (UIButton *)infoCopyBtn {
    if (!_infoCopyBtn) {
        @WeakObj(self);
        _infoCopyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_infoCopyBtn setImage:[UIImage imageNamed:@"meeting_copyinfo"] forState:UIControlStateNormal];
        [_infoCopyBtn setTitle:NSLocalizedString(@"meeting_copy_info", nil) forState:UIControlStateNormal];
        _infoCopyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_infoCopyBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_infoCopyBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        _infoCopyBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_infoCopyBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self shareMeetingInfo];
        }];
        [self addSubview:_infoCopyBtn];
    }
    return _infoCopyBtn;
}
@end
