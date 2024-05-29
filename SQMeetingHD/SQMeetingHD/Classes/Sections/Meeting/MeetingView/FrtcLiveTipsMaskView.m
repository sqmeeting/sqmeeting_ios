#import "FrtcLiveTipsMaskView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIView+Extensions.h"

@interface FrtcLiveTipsMaskView ()

@property (nonatomic, weak) UIView   *bgView;
@property (nonatomic, weak) UIButton *statusButton;

@end


@implementation FrtcLiveTipsMaskView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addView];
    }
    return self;
}

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

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    [button setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [self addSubview:button];
    
    _statusButton = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self layoutIfNeeded];
}

- (void)setTipsStatus:(FLiveTipsStatus)tipsStatus {
    
    if (tipsStatus == FLiveTipsStatusLive) {
        [_statusButton setImage:[UIImage imageNamed:@"meeting_live_status"]
                       forState:UIControlStateNormal];
        [_statusButton setTitle:NSLocalizedString(@"meeting_living", nil) forState:UIControlStateNormal];
    }else if (tipsStatus == FLiveTipsStatusRecording) {
        [_statusButton setImage:[UIImage imageNamed:@"meeting_recordingstatus"]
                       forState:UIControlStateNormal];
        [_statusButton setTitle:NSLocalizedString(@"meeting_recording", nil) forState:UIControlStateNormal];
    }
    
}

@end
