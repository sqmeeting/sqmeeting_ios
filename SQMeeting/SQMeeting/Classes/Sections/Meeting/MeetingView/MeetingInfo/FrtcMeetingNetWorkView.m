#import "FrtcMeetingNetWorkView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcMediaStaticsModel.h"

@interface FrtcMeetingNetWorkView ()

@property (nonatomic, strong) UILabel *latencyLabel;
@property (nonatomic, strong) UILabel *latencyContent;

@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIButton *rateBtn;
@property (nonatomic, strong) UIButton *rateDownBtn;

@property (nonatomic, strong) UILabel *audioLabel;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) UIButton *audioDownBtn;

@property (nonatomic, strong) UILabel *videoLabel;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UIButton *videoDownBtn;

@property (nonatomic, strong) UILabel *shareLabel;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *shareDownBtn;

@property (nonatomic, strong) UIButton  *staticsInfoBtn;

@end

@implementation FrtcMeetingNetWorkView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self meetingNotWorkStaticsViewLayout];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self meetingNotWorkStaticsViewLayout];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self meetingNotWorkStaticsViewLayout];
    }
    return self;
}

- (void)meetingNotWorkStaticsViewLayout {
    
    [self.latencyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(16);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.latencyContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.latencyLabel.mas_centerY);
        make.left.equalTo(self.latencyLabel.mas_right).mas_offset(30);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.staticsInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.latencyLabel.mas_centerY);
        make.left.mas_equalTo(self.latencyContent.mas_right).offset(10);
    }];
    
    [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.latencyLabel.mas_bottom).offset(12);
        make.left.width.height.equalTo(self.latencyLabel);
    }];
    
    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.rateLabel.mas_centerY);
        make.left.width.height.equalTo(self.latencyContent);
    }];
    
    [self.rateDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.rateLabel.mas_centerY);
        make.left.mas_equalTo(self.latencyContent.mas_right).offset(30);
    }];
    
    [self.audioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rateLabel.mas_bottom).offset(12);
        make.left.width.height.equalTo(self.latencyLabel);
    }];
    
    [self.audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.audioLabel.mas_centerY);
        make.left.width.height.equalTo(self.latencyContent);
    }];
    
    [self.audioDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.audioLabel.mas_centerY);
        make.left.width.height.equalTo(self.rateDownBtn);
    }];
    
    [self.videoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.audioLabel.mas_bottom).offset(12);
        make.left.width.height.equalTo(self.latencyLabel);
    }];
    
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.videoLabel.mas_centerY);
        make.left.width.height.equalTo(self.latencyContent);
    }];
    
    [self.videoDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.videoLabel.mas_centerY);
        make.left.width.height.equalTo(self.rateDownBtn);
    }];
    
    [self.shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoLabel.mas_bottom).offset(12);
        make.left.width.height.equalTo(self.latencyLabel);
    }];
    
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shareLabel.mas_centerY);
        make.left.width.height.equalTo(self.latencyContent);
    }];
    
    [self.shareDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shareLabel.mas_centerY);
        make.left.width.height.equalTo(self.rateDownBtn);
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - set

- (void)setStaticsMediaModel:(FrtcMediaStaticsModel *)staticsMediaModel {
    _staticsMediaModel = staticsMediaModel;
    
    self.latencyContent.text = [NSString stringWithFormat:@"%d ms", _staticsMediaModel.rttTime];
    
    [self.rateBtn setTitle:[self convertIntToString:_staticsMediaModel.upRate] forState:UIControlStateNormal];    
    [self.rateDownBtn setTitle:[self convertIntToString:_staticsMediaModel.downRate] forState:UIControlStateNormal];
    
    [self.audioBtn setTitle:[NSString stringWithFormat:@" %d (%d%%)", _staticsMediaModel.audioUpRate, _staticsMediaModel.audioUpPackLost] forState:UIControlStateNormal];
    [self.audioDownBtn setTitle:[NSString stringWithFormat:@" %d (%d%%)", _staticsMediaModel.audioDownRate, _staticsMediaModel.audioDownPackLost] forState:UIControlStateNormal];
    
    [self.videoBtn setTitle:[NSString stringWithFormat:@" %d (%d%%)", _staticsMediaModel.videoUpRate, _staticsMediaModel.videoUpPackLost] forState:UIControlStateNormal];
    [self.videoDownBtn setTitle:[NSString stringWithFormat:@" %d (%d%%)", _staticsMediaModel.videoDownRate, _staticsMediaModel.videoDownPackLost] forState:UIControlStateNormal];
        
    [self.shareBtn setTitle:[NSString stringWithFormat:@" %d (%d%%)", _staticsMediaModel.contentUpRate, _staticsMediaModel.contentUpPackLost] forState:UIControlStateNormal];
    
    [self.shareDownBtn setTitle:[NSString stringWithFormat:@" %d (%d%%)", _staticsMediaModel.contentdownRate, _staticsMediaModel.contentdownPackLost] forState:UIControlStateNormal];
}

- (NSString *)convertIntToString:(int)temp {
    return [NSString stringWithFormat:@" %d", temp];
}

#pragma mark - lazy

- (UILabel *)latencyLabel {
    if(!_latencyLabel) {
        _latencyLabel = [self lableInit];
        _latencyLabel.text = NSLocalizedString(@"app_delay", nil);
        [self addSubview:_latencyLabel];
    }
    
    return _latencyLabel;
}

- (UILabel *)latencyContent {
    if(!_latencyContent) {
        _latencyContent = [self lableInit];
        _latencyContent.text = @"0 ms";
        [self addSubview:_latencyContent];
    }
    
    return _latencyContent;
}

- (UILabel *)rateLabel {
    if(!_rateLabel) {
        _rateLabel = [self lableInit];
        _rateLabel.text = NSLocalizedString(@"statistic_rate", nil);
        [self addSubview:_rateLabel];
    }
    
    return _rateLabel;
}

- (UIButton *)rateBtn {
    if(!_rateBtn) {
        _rateBtn = [self buttonInt];
        [_rateBtn setTitle:@"0" forState:UIControlStateNormal];
        [self addSubview:_rateBtn];
    }
    
    return _rateBtn;;
}

- (UIButton *)rateDownBtn {
    if(!_rateDownBtn) {
        _rateDownBtn = [self buttonInt];
        _rateDownBtn.selected = YES;
        [_rateDownBtn setTitle:@"0" forState:UIControlStateNormal];
        [self addSubview:_rateDownBtn];
    }
    
    return _rateDownBtn;;
}



- (UILabel *)audioLabel {
    if(!_audioLabel) {
        _audioLabel = [self lableInit];
        _audioLabel.text = NSLocalizedString(@"app_audio", nil);
        [self addSubview:_audioLabel];
    }
    
    return _audioLabel;
}

- (UIButton *)audioBtn {
    if(!_audioBtn) {
        _audioBtn = [self buttonInt];
        [_audioBtn setTitle:@"0 (0%)" forState:UIControlStateNormal];
        [self addSubview:_audioBtn];
    }
    
    return _audioBtn;;
}

- (UIButton *)audioDownBtn {
    if(!_audioDownBtn) {
        _audioDownBtn = [self buttonInt];
        _audioDownBtn.selected = YES;
        [_audioDownBtn setTitle:@"0 (0%)" forState:UIControlStateNormal];
        [self addSubview:_audioDownBtn];
    }
    
    return _audioDownBtn;;
}

- (UILabel *)videoLabel {
    if(!_videoLabel) {
        _videoLabel = [self lableInit];
        _videoLabel.text = NSLocalizedString(@"app_video", nil);
        [self addSubview:_videoLabel];
    }
    
    return _videoLabel;
}

- (UIButton *)videoBtn {
    if(!_videoBtn) {
        _videoBtn = [self buttonInt];
        [_videoBtn setTitle:@"0 (0%)" forState:UIControlStateNormal];
        [self addSubview:_videoBtn];
    }
    
    return _videoBtn;;
}

- (UIButton *)videoDownBtn {
    if(!_videoDownBtn) {
        _videoDownBtn = [self buttonInt];
        _videoDownBtn.selected = YES;
        [_videoDownBtn setTitle:@"0 (0%)" forState:UIControlStateNormal];
        [self addSubview:_videoDownBtn];
    }
    
    return _videoDownBtn;;
}

- (UILabel *)shareLabel {
    if(!_shareLabel) {
        _shareLabel = [self lableInit];
        _shareLabel.text = NSLocalizedString(@"app_content", nil);
        [self addSubview:_shareLabel];
    }
    
    return _shareLabel;
}

- (UIButton *)shareBtn {
    if(!_shareBtn) {
        _shareBtn = [self buttonInt];
        [_shareBtn setTitle:@"0 (0%)" forState:UIControlStateNormal];
        [self addSubview:_shareBtn];
    }
    
    return _shareBtn;;
}

- (UIButton *)shareDownBtn {
    if(!_shareDownBtn) {
        _shareDownBtn = [self buttonInt];
        _shareDownBtn.selected = YES;
        [_shareDownBtn setTitle:@" 0 (0%)" forState:UIControlStateNormal];
        [self addSubview:_shareDownBtn];
    }
    
    return _shareDownBtn;;
}

- (UIButton *)staticsInfoBtn {
    if(!_staticsInfoBtn) {
        _staticsInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_staticsInfoBtn setTitle:NSLocalizedString(@"meeting_info_test", nil) forState:UIControlStateNormal];
        [_staticsInfoBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _staticsInfoBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_staticsInfoBtn setImage:[UIImage imageNamed:@"meeting_statistics"] forState:UIControlStateNormal];
        @WeakObj(self);
        [_staticsInfoBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.staticsInfoCallBack) {
                self.staticsInfoCallBack();
            }
        }];
        [self addSubview:_staticsInfoBtn];
    }
    return _staticsInfoBtn;;
}

- (UILabel *)lableInit {
    UILabel *titleLable = [[UILabel alloc]init];
    titleLable.textColor = UIColor.whiteColor;
    titleLable.font = [UIFont systemFontOfSize:14.f];
    titleLable.textAlignment = NSTextAlignmentLeft;
    return  titleLable;
}

- (UIButton *)buttonInt {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"meeting_info_up"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"meeting_info_down"] forState:UIControlStateSelected];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    return btn;
}

@end
