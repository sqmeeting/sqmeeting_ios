#import "FrtcLiveItemMaskView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIView+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIButton+Extensions.h"

@interface FrtcLiveItemMaskView ()

@property (nonatomic, weak) UIView   *bgView;
@property (nonatomic, weak) UIButton *statusButton;
@property (nonatomic, weak) UIButton *shareButton;
@property (nonatomic, weak) UIButton *stopButton;
@property (nonatomic, weak) UIButton *downImageView;

@end

@implementation FrtcLiveItemMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addView];
    }
    return self;
}

- (void)addView {
    
    self.layer.backgroundColor = [UIColor colorWithRed:0/255.0
                                                 green:0/255.0
                                                  blue:0/255.0
                                                 alpha:0.8].CGColor;
    
    UIStackView *bgStackView = [[UIStackView alloc]init];
    bgStackView.axis = UILayoutConstraintAxisVertical;
    bgStackView.spacing = 10;
    [self addSubview:bgStackView];
    [bgStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIStackView *topStackView = [[UIStackView alloc]init];
    
    UIStackView *bottomStackView = [[UIStackView alloc]init];
    bottomStackView.hidden = YES;
    bottomStackView.spacing = 5;
    
    [bgStackView addArrangedSubviews:@[topStackView,bottomStackView]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14.f];
    button.clipsToBounds   = YES;
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    [button setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    _statusButton = button;
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downBtn setImage:[UIImage imageNamed:@"meeting_live_down"] forState:UIControlStateNormal];
    [self addSubview:downBtn];
    _downImageView = downBtn;
    
    [topStackView addArrangedSubviews:@[_statusButton,_downImageView]];
    [_downImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.clipsToBounds = YES;
    [shareBtn setImage:[UIImage imageNamed:@"meeting_live_share"] forState:UIControlStateNormal];
    [shareBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [shareBtn setTitle:NSLocalizedString(@"MEETING_STOP_LIVE_SHARE", nil) forState:UIControlStateNormal];
    @WeakObj(self)
    [shareBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (self.shareBlock) {
            self.shareBlock();
        }
    }];
    [shareBtn setImageLayout:UIButtonLayoutImageTop space:5];
    shareBtn.isSizeToFit = YES;
    _shareButton = shareBtn;
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBtn.clipsToBounds = YES;
    [stopBtn setImage:[UIImage imageNamed:@"meeting_live_stop"] forState:UIControlStateNormal];
    [stopBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    stopBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [stopBtn setTitle:NSLocalizedString(@"MEETING_STOP_LIVE_BUTTON", nil) forState:UIControlStateNormal];
    [stopBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (self.stopBlock) {
            self.stopBlock();
        }
    }];
    [stopBtn setImageLayout:UIButtonLayoutImageTop space:5];
    stopBtn.isSizeToFit = YES;
    _stopButton = stopBtn;
    
    [bottomStackView addArrangedSubviews:@[shareBtn,stopBtn]];
    
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [UIView animateWithDuration:0.25 animations:^{
            bottomStackView.hidden = !bottomStackView.hidden;
        }];
    }];
    
    [downBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [UIView animateWithDuration:0.25 animations:^{
            bottomStackView.hidden = !bottomStackView.hidden;
         }];
    }];
    
    [@[shareBtn,stopBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(60);
    }];
}

- (void)setTipsStatus:(FLiveTipsStatus)tipsStatus {
    
    if (tipsStatus == FLiveTipsStatusLive) {
        [UIView animateWithDuration:0.25 animations:^{
            self->_shareButton.hidden = NO;
        }];
        [_statusButton setImage:[UIImage imageNamed:@"meeting_live_status"]
                       forState:UIControlStateNormal];
        [_statusButton setTitle:NSLocalizedString(@"meeting_living", nil) forState:UIControlStateNormal];
    }else if (tipsStatus == FLiveTipsStatusRecording) {
        [UIView animateWithDuration:0.25 animations:^{
            self->_shareButton.hidden = YES;
        }];
        [_statusButton setImage:[UIImage imageNamed:@"meeting_recordingstatus"]
                       forState:UIControlStateNormal];
        [_statusButton setTitle:NSLocalizedString(@"meeting_recording", nil) forState:UIControlStateNormal];
    }
    
}

- (void)dealloc {
    //ISMLog(@"%s",__func__);
}

@end
