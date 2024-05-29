#import "FrtcAlertView.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "ParticipantListModel.h"
#import "UIStackView+Extensions.h"
#import "FrtcMakeCallClient.h"

static FrtcAlertView *alertView = nil;
static FrtcAlertViewCallBack alertViewBlock = nil;

@interface FrtcAlertView ()

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UILabel *titleLable;
@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *cancelBtn;

@end

@implementation FrtcAlertView

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  buttonTitles:(NSArray <NSString *> *)buttonTitles
             didSelectCallBack:(FrtcAlertViewCallBack)callBack {
    NSInteger count = buttonTitles.count;
    alertView = [[FrtcAlertView alloc]initWithFrame:UIScreen.mainScreen.bounds count:count];
    alertView.titleLable.text = title;
    alertView.contentLabel.text = message;
    [alertView.cancelBtn setTitle:(count == 0) ? NSLocalizedString(@"call_cancel", nil) : buttonTitles[0] forState:UIControlStateNormal];
    if (count > 1) {
        [alertView.doneBtn setTitle:buttonTitles[1] forState:UIControlStateNormal];
    }
    alertViewBlock = callBack;
    [[UIApplication sharedApplication].windows.lastObject addSubview:alertView];
}

+ (void)disMissView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *maskView in [[[UIApplication sharedApplication].delegate window] subviews])
        {
            if ([maskView isKindOfClass:[FrtcAlertView class]]) {
                alertView = nil;
                alertViewBlock = nil;
                [[FrtcMakeCallClient sharedSDKContext] setValue:[NSNumber numberWithBool:NO]
                                                               forKey:@"showUnMuteView"];
                [maskView removeFromSuperview];
            }
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count {
    
    if (self = [super initWithFrame:frame]) {
        self.layer.backgroundColor = [UIColor colorWithRed:33/255.0 green:34/255.0 blue:35/255.0 alpha:0.4].CGColor;
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(320);
            make.center.equalTo(self);
        }];
        
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.spacing = 10;
        [self.bgView addSubview:stackView];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing / 2);
            make.right.mas_equalTo(- KLeftSpacing /2 );
            make.top.mas_equalTo(KLeftSpacing / 1.8);
        }];
        
        [stackView addArrangedSubviews:@[self.titleLable,self.contentLabel]];
        
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = KLineColor;
        [self.bgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
            make.top.equalTo(stackView.mas_bottom).mas_offset(15);
        }];
                
        if (count > 1) {
            [self.bgView addSubview:self.cancelBtn];
            [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lineView.mas_bottom);
                make.height.mas_equalTo(kButtonHeight);
                make.width.equalTo(self.bgView).multipliedBy(0.5);
                make.left.mas_equalTo(0);
            }];
            
            UIView *lineVView = [UIView new];
            lineVView.backgroundColor = KLineColor;
            [self.bgView addSubview:lineVView];
            [lineVView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lineView.mas_bottom);
                make.width.mas_equalTo(1);
                make.bottom.mas_equalTo(0);
                make.left.equalTo(self.cancelBtn.mas_right);
            }];
            
            [self.bgView addSubview:self.doneBtn];
            [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.width.top.equalTo(self.cancelBtn);
                make.right.mas_equalTo(0);
                make.bottom.mas_equalTo(-5);
            }];
        }else{
            [self.bgView addSubview:self.cancelBtn];
            [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lineView.mas_bottom);
                make.height.mas_equalTo(kButtonHeight);
                make.left.right.mas_equalTo(0);
                make.bottom.mas_equalTo(-5);
            }];
        }
        
        [self animationAlert:self.bgView];
    }
    return self;
}

- (void)disMiss{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        alertView = nil;
        alertViewBlock = nil;
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)animationAlert:(UIView *)view
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.3;
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

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]init];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.textColor = KTextColor;
        _titleLable.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _titleLable;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.textColor = KTextColor666666;
        _contentLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return _contentLabel;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        @WeakObj(self);
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
        [_doneBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [_doneBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (alertViewBlock) {
                alertViewBlock(1);
            }
            [self disMiss];
        }];
    }
    return _doneBtn;
}


- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        @WeakObj(self);
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:NSLocalizedString(@"call_cancel", nil) forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:KTextColor666666 forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [_cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (alertViewBlock) {
                alertViewBlock(0);
            }
            [self disMiss];
        }];
    }
    return _cancelBtn;
}


@end
