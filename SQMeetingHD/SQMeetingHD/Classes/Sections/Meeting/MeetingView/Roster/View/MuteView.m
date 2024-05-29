#import "MuteView.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "ParticipantListModel.h"
#import "UIStackView+Extensions.h"

static MuteView *muteView = nil;
static MuteViewCallBack muteCallBackBlock = nil;

@interface MuteView ()

@property (strong, nonatomic) UIView *bgView;

@property (nonatomic)         KMuteType mutetype;
@property (strong, nonatomic) UIStackView *centerView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *muteBtn;
@property (strong, nonatomic) UIButton *nameBtn;
@property (strong, nonatomic) UIButton *lectureBtn;
@property (strong, nonatomic) UIButton *removeBtn;
@property (strong, nonatomic) UIButton *pinBtn;

@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) ParticipantListModel *model;

@end

@implementation MuteView

+ (void)showMuteAlertViewWithModel:(ParticipantListModel *)model
                    isExistLecture:(BOOL)isExistLecture
                   meetingOperator:(BOOL)isMeetingOperator
                          lectures:(BOOL)isLecture
                               pin:(BOOL)isPin
                  muteViewCallBack:(MuteViewCallBack)muteBlock {
    muteView = [[MuteView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    muteView.model = model;
    muteView.nameLabel.text    = model.name;
    muteView.removeBtn.hidden  = !(isMeetingOperator && !model.isMe);
    muteView.lectureBtn.hidden = !isMeetingOperator;
    muteView.pinBtn.hidden     = !isMeetingOperator;
    //muteView.removeBtn.hidden = isLecture;
    muteView.muteBtn.hidden = isLecture;
    
    if (muteView.lectureBtn.hidden == NO && isLecture) {
        muteView.lectureBtn.selected = YES;
    }
    
    if (isLecture) {
        muteView.removeBtn.hidden = YES;
        muteView.pinBtn.hidden = YES;
    }
    
    if (isPin) {
        muteView.pinBtn.selected = YES;
    }
    
    if (isExistLecture) {
        muteView.pinBtn.hidden = YES;
    }
        
    [muteView.muteBtn setTitle:model.isMuteAudio ? NSLocalizedString(@"meeting_unmute", nil) : NSLocalizedString(@"join_Mute", nil)
                      forState:UIControlStateNormal];
    muteCallBackBlock = muteBlock;
    
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindow addSubview:muteView];
}

+ (void)disMissView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *maskView in [[[UIApplication sharedApplication].delegate window] subviews])
        {
            if ([maskView isKindOfClass:[MuteView class]]) {
                muteView = nil;
                muteCallBackBlock = nil;
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
            make.width.mas_equalTo(300);
            make.center.equalTo(self);
        }];
        
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.spacing = 8;
        [self.bgView addSubview:stackView];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing / 2);
            make.right.mas_equalTo(- KLeftSpacing /2 );
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-5);
        }];

        [stackView addArrangedSubviews:@[self.nameLabel,self.centerView,self.cancelBtn]];
        [self.centerView addArrangedSubviews:@[self.muteBtn,self.nameBtn,self.lectureBtn,self.pinBtn,self.removeBtn]];
        [stackView setCustomSpacing:3 afterView:self.muteBtn];
        
        [@[self.nameLabel,self.muteBtn,self.nameBtn,self.cancelBtn,self.removeBtn,self.lectureBtn,self.pinBtn]
         mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kButtonHeight);
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
        if (muteCallBackBlock) {
            muteCallBackBlock(self.mutetype);
        }
        muteView = nil;
        muteCallBackBlock = nil;
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
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

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = KTextColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _nameLabel;
}

- (UIButton *)muteBtn {
    if (!_muteBtn) {
        @WeakObj(self);
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteBtn.backgroundColor = UIColor.whiteColor;
        [_muteBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _muteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_muteBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.mutetype = KMuteViewTypeMute;
            [self disMiss];
        }];
    }
    return _muteBtn;
}

- (UIButton *)nameBtn {
    if (!_nameBtn) {
        @WeakObj(self);
        _nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nameBtn.backgroundColor = UIColor.whiteColor;
        [_nameBtn setTitle:NSLocalizedString(@"meeting_renamed", nil) forState:UIControlStateNormal];
        [_nameBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _nameBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_nameBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.mutetype = KMuteViewTypeName;
            [self disMiss];
        }];
    }
    return _nameBtn;
}

- (UIButton *)lectureBtn {
    if (!_lectureBtn) {
        @WeakObj(self);
        _lectureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lectureBtn.backgroundColor = UIColor.whiteColor;
        [_lectureBtn setTitle:NSLocalizedString(@"meeting_setLecture", nil) forState:UIControlStateNormal];
        [_lectureBtn setTitle:NSLocalizedString(@"meeting_cancelLecture", nil) forState:UIControlStateSelected];
        [_lectureBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _lectureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_lectureBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.mutetype = KMuteViewTypeLecture;
            [self disMiss];
        }];
    }
    return _lectureBtn;
}

- (UIButton *)pinBtn {
    if (!_pinBtn) {
        @WeakObj(self);
        _pinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pinBtn.backgroundColor = UIColor.whiteColor;
        _pinBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_pinBtn setTitle:NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_PIN", nil)
                 forState:UIControlStateNormal];
        [_pinBtn setTitle:NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_UNPIN", nil)
                 forState:UIControlStateSelected];
        [_pinBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        [_pinBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.mutetype = KMuteViewTypePin;
            [self disMiss];
        }];
    }
    return _pinBtn;
}

- (UIButton *)removeBtn {
    if (!_removeBtn) {
        @WeakObj(self);
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeBtn.backgroundColor = UIColor.whiteColor;
        [_removeBtn setTitle:NSLocalizedString(@"meeting_remove", nil) forState:UIControlStateNormal];
        [_removeBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        _removeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_removeBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.mutetype = KMuteViewTypeRemove;
            [self disMiss];
        }];
    }
    return _removeBtn;
}


- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        @WeakObj(self);
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:NSLocalizedString(@"call_cancel", nil) forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            self.mutetype = KMuteViewTypeNol;
            [self disMiss];
        }];
    }
    return _cancelBtn;
}

- (UIStackView *)centerView {
    if (!_centerView) {
        _centerView = [[UIStackView alloc]init];
        _centerView.backgroundColor = self.bgView.backgroundColor;
        _centerView.axis = UILayoutConstraintAxisVertical;
        _centerView.spacing = 1;
        _centerView.layer.cornerRadius = 4;
        _centerView.layer.masksToBounds = YES;
    }
    return _centerView;
}

@end

