#import "FrtcShareMeetingMaskView.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcInvitationInfoManage.h"
#import "FrtcUserModel.h"

static FrtcShareMeetingMaskView *shareMaskView = nil;
static FShareMeetingMaskCallBack alertViewBlock = nil;

@interface FrtcShareMeetingMaskView () <CAAnimationDelegate>

@property (strong, nonatomic) UIView  *bgView;
@property (strong, nonatomic) UILabel *titleLable;
@property (strong, nonatomic) UIView  *contentView;
@property (strong, nonatomic) UILabel *meeting_title;
@property (strong, nonatomic) UILabel *meeting_theme;
@property (strong, nonatomic) UILabel *meeting_startTime;
@property (strong, nonatomic) UILabel *meeting_endTime;
@property (strong, nonatomic) UILabel *meeting_share;
@property (strong, nonatomic) UILabel *meeting_shareUrl;
@property (strong, nonatomic) UILabel *meeting_number;
@property (strong, nonatomic) UILabel *meeting_password;
@property (strong, nonatomic) UILabel *meeting_des;
@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) FHomeMeetingListModel *meetingInfo;

@end

@implementation FrtcShareMeetingMaskView

+ (void)showShareView:(FHomeMeetingListModel *)meetingInfo
    didSelectCallBack:(FShareMeetingMaskCallBack)callBack {
    shareMaskView = [[FrtcShareMeetingMaskView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    shareMaskView.meetingInfo = meetingInfo;
    alertViewBlock = callBack;
    //[[[UIApplication sharedApplication].delegate window] addSubview:shareMaskView];
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindow addSubview:shareMaskView];

}

+ (void)disMissView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *maskView in [[[UIApplication sharedApplication].delegate window] subviews])
        {
            if ([maskView isKindOfClass:[FrtcShareMeetingMaskView class]]) {
                shareMaskView = nil;
                alertViewBlock = nil;
                [maskView removeFromSuperview];
            }
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.layer.backgroundColor = [UIColor colorWithRed:33/255.0 green:34/255.0 blue:35/255.0 alpha:0.4].CGColor;
        [self addSubview:self.bgView];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.width.mas_equalTo(350);
            make.width.mas_equalTo(LAND_SCAPE_WIDTH/2);
            make.centerX.equalTo(self);
            make.bottom.mas_equalTo(0);
        }];
        
        UIStackView *titleStackView = [[UIStackView alloc]init];
        titleStackView.axis = UILayoutConstraintAxisHorizontal;
        titleStackView.distribution = UIStackViewDistributionEqualSpacing;
        [self.bgView addSubview:titleStackView];
        
        [titleStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(- KLeftSpacing);
            make.top.mas_equalTo(KLeftSpacing);
        }];
        
        [titleStackView addArrangedSubviews:@[self.titleLable,self.cancelBtn]];
        
        [self.bgView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleStackView.mas_bottom).offset(10);
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
        }];
        
        UIStackView *contentStackView = [[UIStackView alloc]init];
        contentStackView.axis = UILayoutConstraintAxisVertical;
        contentStackView.spacing = 10;
        [self.contentView addSubview:contentStackView];
        
        [contentStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(KLeftSpacing);
            make.bottom.right.mas_equalTo(-KLeftSpacing);
        }];
        
        [contentStackView addArrangedSubviews:@[self.meeting_title,self.meeting_theme,self.meeting_startTime,/*self.meeting_endTime,*/self.meeting_number,self.meeting_password,self.meeting_des,self.meeting_share,self.meeting_shareUrl]];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
        }];
        
        [self.bgView addSubview:self.doneBtn];
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40));
            make.top.equalTo(self.contentView.mas_bottom).offset(KLeftSpacing);
            make.bottom.mas_equalTo(-KLeftSpacing*2);
            make.centerX.equalTo(self.bgView);
        }];
        
        [self animationAlert:self.bgView];
    }
    return self;
}

- (void)disMiss{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        shareMaskView = nil;
        alertViewBlock = nil;
    }];
}

- (void)setMeetingInfo:(FHomeMeetingListModel *)meetingInfo {
    _meetingInfo = meetingInfo;
    self.titleLable.text = _meetingInfo.meetingName;

    NSString *userName = [FrtcUserModel fetchUserInfo].real_name;
    self.meeting_title.text = [NSString stringWithFormat:@"%@ %@", (kStringIsEmpty(userName) ? @"" : userName),NSLocalizedString(@"share_invitation", nil)];
    self.meeting_theme.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"meeting_theme", nil), _meetingInfo.meetingName];
    if (!kStringIsEmpty(_meetingInfo.meetingStartTime) && [_meetingInfo.meetingStartTime intValue] != 0) {
        self.meeting_startTime.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"meeting_start_time", nil) ,[FrtcHelpers getDateStringWithTimeStr:_meetingInfo.meetingStartTime]];
    }
    if (!kStringIsEmpty(_meetingInfo.meetingEndTime)  && [_meetingInfo.meetingEndTime intValue] != 0) {
        self.meeting_endTime.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"meeting_end_time", nil), _meetingInfo.meetingTime];
    }
    if (kStringIsEmpty(_meetingInfo.meetingUrl)) {
        self.meeting_share.hidden = self.meeting_shareUrl.hidden = YES;
    }else {
        self.meeting_share.hidden = self.meeting_shareUrl.hidden = NO;
        self.meeting_share.text = NSLocalizedString(@"meeting_clickUrlJoin", nil);
        self.meeting_shareUrl.text = _meetingInfo.meetingUrl;
    }
    self.meeting_number.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"meeting_id", nil), _meetingInfo.meetingNumber];
    if (kStringIsEmpty(_meetingInfo.meetingPassword)) {
        self.meeting_password.hidden = YES;
    }else{
        self.meeting_password.hidden = NO;
        self.meeting_password.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"meeting_psd", nil) , _meetingInfo.meetingPassword];
    }
    self.meeting_des.text = NSLocalizedString(@"share_content", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bgView setCornerRadius:16 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    });
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)animationAlert:(UIView *)view
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [view.layer addAnimation:transition forKey:nil];
}

#pragma mark - lazy

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = UIView.alloc.init;
        _bgView.layer.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0].CGColor;
    }
    return _bgView;
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = UILabel.alloc.init;
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.textColor = KTextColor;
        _titleLable.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _titleLable;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = UIView.alloc.init;
        _contentView.backgroundColor = UIColor.whiteColor;
        _contentView.layer.cornerRadius  = 4;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;;
        _contentView.layer.borderWidth = 1;
    }
    return _contentView;
}

- (UILabel *)meeting_title {
    if (!_meeting_title) {
        _meeting_title = UILabel.alloc.init;
        _meeting_title.textColor = KTextColor;
        _meeting_title.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_title;
}

- (UILabel *)meeting_theme {
    if (!_meeting_theme) {
        _meeting_theme = UILabel.alloc.init;
        _meeting_theme.textColor = KTextColor;
        _meeting_theme.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_theme;
}

- (UILabel *)meeting_startTime {
    if (!_meeting_startTime) {
        _meeting_startTime = UILabel.alloc.init;
        _meeting_startTime.textColor = KTextColor;
        _meeting_startTime.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_startTime;
}

- (UILabel *)meeting_endTime {
    if (!_meeting_endTime) {
        _meeting_endTime = UILabel.alloc.init;
        _meeting_endTime.textColor = KTextColor;
        _meeting_endTime.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_endTime;
}

- (UILabel *)meeting_share {
    if (!_meeting_share) {
        _meeting_share = UILabel.alloc.init;
        _meeting_share.textColor = KTextColor;
        _meeting_share.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_share;
}

- (UILabel *)meeting_shareUrl {
    if (!_meeting_shareUrl) {
        _meeting_shareUrl = UILabel.alloc.init;
        _meeting_shareUrl.textColor = KTextColor;
        _meeting_shareUrl.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_shareUrl;
}

- (UILabel *)meeting_number {
    if (!_meeting_number) {
        _meeting_number = UILabel.alloc.init;
        _meeting_number.textColor = KTextColor;
        _meeting_number.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_number;
}

- (UILabel *)meeting_password {
    if (!_meeting_password) {
        _meeting_password = UILabel.alloc.init;
        _meeting_password.textColor = KTextColor;
        _meeting_password.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_password;
}

- (UILabel *)meeting_des {
    if (!_meeting_des) {
        _meeting_des = UILabel.alloc.init;
        _meeting_des.textColor = KTextColor;
        _meeting_des.numberOfLines = 0;
        _meeting_des.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_des;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        @WeakObj(self);
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setImage:[UIImage imageNamed:@"frtc_copy"] forState:UIControlStateNormal];
        [_doneBtn setTitle:NSLocalizedString(@"meeting_inviteJoinCopy", nil) forState:UIControlStateNormal];
        [_doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _doneBtn.layer.cornerRadius = 4;
        _doneBtn.layer.masksToBounds = YES;
        _doneBtn.backgroundColor = kMainColor;
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [_doneBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [FrtcInvitationInfoManage shareInvitationInfo:self->_meetingInfo];
            [self disMiss];
        }];
    }
    return _doneBtn;
}


- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        @WeakObj(self);
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"frtc_cancle"] forState:UIControlStateNormal];
        [_cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self disMiss];
        }];
    }
    return _cancelBtn;
}


@end
