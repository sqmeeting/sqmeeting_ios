#import "FrtcShareLiveUrlMaskView.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcInvitationInfoManage.h"
#import "FrtcLiveStatusModel.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcUserModel.h"

static FrtcShareLiveUrlMaskView *shareMaskView = nil;
static FrtcShareLiveUrlMaskViewCallBack alertViewBlock = nil;

@interface FrtcShareLiveUrlMaskView () <CAAnimationDelegate>

@property (strong, nonatomic) UIView  *bgView;
@property (strong, nonatomic) UILabel *titleLable;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *meeting_title;

@property (strong, nonatomic) UILabel *meeting_share;
@property (strong, nonatomic) UILabel *meeting_shareUrl;
@property (strong, nonatomic) UILabel *meeting_password;
@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) FHomeMeetingListModel *meetingInfo;
@property (strong, nonatomic) FrtcLiveStatusModel *liveStatusModel;

@end

@implementation FrtcShareLiveUrlMaskView

+ (void) showShareLiveView:(FHomeMeetingListModel *)meetingInfo
            liveStatusInfo:(FrtcLiveStatusModel *)liveStatusInfo
         didSelectCallBack:(FrtcShareLiveUrlMaskViewCallBack)callBack {
    shareMaskView = [[FrtcShareLiveUrlMaskView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    shareMaskView.liveStatusModel = liveStatusInfo;
    shareMaskView.meetingInfo     = meetingInfo;
    alertViewBlock                = callBack;
    
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindow addSubview:shareMaskView];
}

+ (void)disMissView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *maskView in [[[UIApplication sharedApplication].delegate window] subviews])
        {
            if ([maskView isKindOfClass:[FrtcShareLiveUrlMaskView class]]) {
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
            make.width.mas_equalTo(LAND_SCAPE_HEIGHT);
            make.centerX.equalTo(self);
            make.bottom.mas_equalTo(0);
        }];
        
        UIStackView *titleStackView = [[UIStackView alloc]init];
        titleStackView.axis = UILayoutConstraintAxisHorizontal;
        titleStackView.distribution = UIStackViewDistributionEqualSpacing;
        [self.bgView addSubview:titleStackView];
        
        [titleStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing12);
            make.right.mas_equalTo(- KLeftSpacing12);
            make.top.mas_equalTo(KLeftSpacing12);
        }];
        
        [titleStackView addArrangedSubviews:@[self.titleLable,self.cancelBtn]];
        
        [self.bgView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleStackView.mas_bottom).offset(10);
            make.left.mas_equalTo(KLeftSpacing12);
            make.right.mas_equalTo(-KLeftSpacing12);
        }];
        
        UIStackView *contentStackView = [[UIStackView alloc]init];
        contentStackView.axis = UILayoutConstraintAxisVertical;
        contentStackView.spacing = 6;
        [self.contentView addSubview:contentStackView];
        
        [contentStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(KLeftSpacing12);
            make.bottom.right.mas_equalTo(-KLeftSpacing12);
        }];
        
        [contentStackView addArrangedSubviews:@[self.meeting_title,self.meeting_share,self.meeting_shareUrl,self.meeting_password]];
        
        [contentStackView setCustomSpacing:10 afterView:self.meeting_title];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
        }];
        
        [self.bgView addSubview:self.doneBtn];
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 40));
            make.top.equalTo(self.contentView.mas_bottom).offset(10);
            make.bottom.mas_equalTo(-KLeftSpacing12);
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

- (void)changeStatusBarOrientation:(NSInteger)orientation {
    UIViewController * viewController = [FrtcHelpers getCurrentVC];
    self.frame = viewController.view.bounds;
}

- (void)setMeetingInfo:(FHomeMeetingListModel *)meetingInfo {
    
    _meetingInfo = meetingInfo;
    self.titleLable.text = NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL_TITLE", @"Share Live Streaming");
    
    NSString *userName = isLoginSuccess ? [FrtcUserModel fetchUserInfo].username : @"";
    self.meeting_title.text = [NSString stringWithFormat:NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL_INVITE", @"%@ invites you to a\"%@\"live streaming."), userName, _meetingInfo.meetingName];
    
    self.meeting_share.text = NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL", @"Click the link to watch:");
    self.meeting_shareUrl.text = [NSString stringWithFormat:@"%@ \n",_liveStatusModel.liveMeetingUrl];
    
    if (kStringIsEmpty(_liveStatusModel.liveMeetingPwd)) {
        self.meeting_password.hidden = YES;
    }else{
        self.meeting_password.hidden = NO;
        self.meeting_password.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"FM_VIDEO_STREAMING_PASSWORD_LIVE", @"Password:") , _liveStatusModel.liveMeetingPwd];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bgView setCornerRadius:16 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    });
}

- (void)shareLiveMeetingInfo {
    
    NSMutableString *meetingInfoCopy = [NSMutableString stringWithCapacity:10];
    
    NSString *userName = isLoginSuccess ? [FrtcUserModel fetchUserInfo].username : @"";
    NSString *meetingTitle = [NSString stringWithFormat:NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL_INVITE", @"%@ invites you to a\"%@\"live streaming."), userName, _meetingInfo.meetingName];;
    [meetingInfoCopy appendFormat:@"%@",meetingTitle];
    [meetingInfoCopy appendFormat:@"\n"];
    [meetingInfoCopy appendFormat:@"\n"];
    
    NSString *meetingShare = NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL", @"Click the link to watch:");
    [meetingInfoCopy appendFormat:@"%@ \n",meetingShare];
    
    NSString *meetingShareUrl = [NSString stringWithFormat:@"%@ \n",_liveStatusModel.liveMeetingUrl];
    [meetingInfoCopy appendFormat:@"%@ \n ",meetingShareUrl];
    
    if (!kStringIsEmpty(_liveStatusModel.liveMeetingPwd)) {
        NSString *meetingpwd =  self.meeting_password.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"FM_VIDEO_STREAMING_PASSWORD_LIVE", @"Password:") , _liveStatusModel.liveMeetingPwd];
        [meetingInfoCopy appendFormat:@"%@",meetingpwd];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = meetingInfoCopy;
    [MBProgressHUD showMessage:NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL_REMINDER", @"Live info copied to the clipboard")];
}

- (void)dealloc {
    
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

- (UILabel *)meeting_share {
    if (!_meeting_share) {
        _meeting_share = UILabel.alloc.init;
        _meeting_share.textColor = KTextColor;
        _meeting_share.numberOfLines = 0;
        _meeting_share.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_share;
}

- (UILabel *)meeting_shareUrl {
    if (!_meeting_shareUrl) {
        _meeting_shareUrl = UILabel.alloc.init;
        _meeting_shareUrl.textColor = KTextColor;
        _meeting_shareUrl.numberOfLines = 0;
        _meeting_shareUrl.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_shareUrl;
}

- (UILabel *)meeting_password {
    if (!_meeting_password) {
        _meeting_password = UILabel.alloc.init;
        _meeting_password.textColor = KTextColor;
        _meeting_password.font = [UIFont boldSystemFontOfSize:13.f];
    }
    return _meeting_password;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        @WeakObj(self);
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setImage:[UIImage imageNamed:@"frtc_copy"] forState:UIControlStateNormal];
        [_doneBtn setTitle:NSLocalizedString(@"FM_VIDEO_STREAMING_SHARE_URL_BUTTON", @"Copy live info") forState:UIControlStateNormal];
        [_doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _doneBtn.layer.cornerRadius = 4;
        _doneBtn.layer.masksToBounds = YES;
        _doneBtn.backgroundColor = kMainColor;
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [_doneBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self shareLiveMeetingInfo];
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
