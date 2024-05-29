#import "AllMuteView.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "ParticipantListModel.h"
#import "UIStackView+Extensions.h"

static AllMuteView *muteView = nil;
static AllowMuteCallBack allowMuteBlock = nil;

@interface AllMuteView ()

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UILabel *allMuteLabel;
@property (strong, nonatomic) UIButton *allMuteBtn;
@property (strong, nonatomic) UIButton *cancelBtn;

@property (strong, nonatomic) UILabel *unMuteLabel;
@property (strong, nonatomic) UISwitch *muteSwitch;
@property (strong, nonatomic) ParticipantListModel *model;
@property (strong, nonatomic) UIStackView *bottomStackView;


@property (nonatomic, getter=isAllMute) BOOL allMute;
@property (nonatomic, getter=isAllow) BOOL allow;


@end

@implementation AllMuteView

+ (void)showAllMuteAlertView:(BOOL)isAllMute allMuteCallBack:(AllowMuteCallBack)allowMuteCallBack {
    muteView = [[AllMuteView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    allowMuteBlock = allowMuteCallBack;
    muteView.bottomStackView.hidden = !isAllMute;
    muteView.allMuteLabel.text = isAllMute ? NSLocalizedString(@"meeting_mute_participants", nil) : NSLocalizedString(@"meeting_numute_participants", nil);
    [muteView.allMuteBtn setTitle:isAllMute ? NSLocalizedString(@"meeting_muteall", nil) : NSLocalizedString(@"meeting_unmute_all", nil)
                         forState:UIControlStateNormal];
    muteView.allow = YES;
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindow addSubview:muteView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        [muteView disMiss];
    }];
    [muteView addGestureRecognizer:tap];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.layer.backgroundColor = [UIColor colorWithRed:33/255.0 green:34/255.0 blue:35/255.0 alpha:0.4].CGColor;
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(320);
            make.center.equalTo(self);
        }];
        
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.spacing = 15;
        [self.bgView addSubview:stackView];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(- KLeftSpacing);
            make.top.mas_equalTo(KLeftSpacing);
            make.bottom.mas_equalTo(-KLeftSpacing);
        }];
        
        _bottomStackView = [[UIStackView alloc]init];
        _bottomStackView.distribution = UIStackViewDistributionEqualSpacing;
        
        [stackView addArrangedSubviews:@[self.allMuteLabel,self.allMuteBtn,self.cancelBtn,_bottomStackView]];
        
        [_bottomStackView addArrangedSubviews:@[self.unMuteLabel,self.muteSwitch]];
        
        [self.allMuteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kButtonHeight);
        }];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kButtonHeight);
        }];
        
        [self.unMuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_bottomStackView.mas_width).mas_offset(-50);
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
        muteView = nil;
        allowMuteBlock = nil;
    }];
}

- (void)animationAlert:(UIView *)view
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:popAnimation forKey:nil];
}

#pragma mark - lazy

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0].CGColor;
        _bgView.layer.cornerRadius = 16;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)allMuteLabel {
    if (!_allMuteLabel) {
        _allMuteLabel = [[UILabel alloc]init];
        _allMuteLabel.text = NSLocalizedString(@"meeting_mute_participants", nil);
        _allMuteLabel.textColor = KTextColor;
        _allMuteLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _allMuteLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _allMuteLabel;
}

- (UIButton *)allMuteBtn {
    if (!_allMuteBtn) {
        @WeakObj(self);
        _allMuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allMuteBtn.backgroundColor = kMainColor;
        [_allMuteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _allMuteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _allMuteBtn.layer.cornerRadius = KCornerRadius;
        [_allMuteBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self disMiss];
            if (allowMuteBlock) {
                allowMuteBlock(self.isAllow);
            }
        }];
    }
    return _allMuteBtn;
}


- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        @WeakObj(self);
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:NSLocalizedString(@"call_cancel", nil) forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _cancelBtn.layer.cornerRadius = KCornerRadius;
        _cancelBtn.backgroundColor = UIColor.whiteColor;
        [_cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self disMiss];
        }];
    }
    return _cancelBtn;
}

- (UILabel *)unMuteLabel {
    if (!_unMuteLabel) {
        _unMuteLabel = [[UILabel alloc]init];
        _unMuteLabel.text = NSLocalizedString(@"meeting_allParticipants_unmute", nil);
        _unMuteLabel.textColor = KTextColor;
        _unMuteLabel.font = [UIFont systemFontOfSize:14.f];
        _unMuteLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _unMuteLabel;
}

- (UISwitch *)muteSwitch {
    if (!_muteSwitch) {
        @WeakObj(self);
        _muteSwitch = [[UISwitch alloc]init];
        [_muteSwitch setOn:YES];
        _muteSwitch.onTintColor = kMainColor;
        [_muteSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.allow = self.muteSwitch.on;
        }];
    }
    return _muteSwitch;
}


@end
