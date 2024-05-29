#import "AskToUnmuteView.h"
#import "Masonry.h"

#define KColorRGB(r,g,b,a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]

@interface AskToUnmuteView ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIButton *unMuteButton;

@property (nonatomic, strong) UIButton *stayMuteButton;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger timerCount;

@end

@implementation AskToUnmuteView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor whiteColor];
        self.timerCount = 30;
        [self configUI];
        [self startTimer:1.0];
    }
    
    return self;
}

#pragma mark --lify cycle
- (void)dealloc {
    [self cancelTimer];
}

#pragma mark --config UI layout
- (void)configUI {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.unMuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.label.mas_bottom).mas_offset(31);
        make.left.mas_equalTo(23.5);
        make.width.mas_equalTo(192);
        make.height.mas_equalTo(40);
    }];
    
    [self.stayMuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.label.mas_bottom).mas_offset(31);
        make.right.mas_equalTo(-23.5);
        make.width.mas_equalTo(192);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --timer--
- (void)startTimer:(NSTimeInterval)timeInterval {
    self.timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(handleTimerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)handleTimerEvent {
    self.timerCount--;
    [self.stayMuteButton setTitle:[NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(@"stay_muted", nil), self.timerCount] forState:UIControlStateNormal];
    if(self.timerCount == 0) {
        [self cancelTimer];
        [self removeFromSuperview];
    }
}

- (void)cancelTimer {
    if(_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)updateAskUnMuteView {
    [self cancelTimer];
    self.timerCount = 30;
    [_stayMuteButton setTitle:[NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(@"stay_muted", nil), self.timerCount] forState:UIControlStateNormal];
    [self startTimer:1.0];
}

#pragma mark --button fucntion--
- (void)unMuteClick:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(unMute)]) {
        [self.delegate unMute];
    }
}

- (void)stayMuteClick:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(stayMute)]) {
        [self.delegate stayMute];
    }
}

- (UILabel *)label {
    if(!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = NSLocalizedString(@"mute_reminder", nil);
        _label.numberOfLines = 1.0;
        _label.font = [UIFont systemFontOfSize:16.0];
        _label.textColor = KColorRGB(66, 66, 66, 1.0);
        [self addSubview:_label];
    }
    
    return _label;
}

- (UIButton *)unMuteButton {
    if(!_unMuteButton) {
        _unMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unMuteButton setTitle:NSLocalizedString(@"unmute_now", nil) forState:UIControlStateNormal];
        [_unMuteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _unMuteButton.backgroundColor = KColorRGB(239,241,245,1.0);
        //_callButton.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        _unMuteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];;
        [_unMuteButton addTarget:self action:@selector(unMuteClick:) forControlEvents:UIControlEventTouchUpInside];
        // _callButton.titleLabel.numberOfLines = 1;
        _unMuteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _unMuteButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self addSubview:_unMuteButton];
    }
    
    return _unMuteButton;
}

- (UIButton *)stayMuteButton {
    if(!_stayMuteButton) {
        _stayMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stayMuteButton setTitle:[NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(@"stay_muted", nil), self.timerCount] forState:UIControlStateNormal];
        [_stayMuteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _stayMuteButton.layer.borderColor = KColorRGB(18, 95, 123, 1.0).CGColor;
        _stayMuteButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        
 
        [_stayMuteButton setTitleColor:KColorRGB(18, 95, 123, 1.0) forState:UIControlStateNormal];
        _stayMuteButton.layer.cornerRadius = 4;
        _stayMuteButton.layer.borderWidth = 2;
        _stayMuteButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        
        [_stayMuteButton addTarget:self action:@selector(stayMuteClick:) forControlEvents:UIControlEventTouchUpInside];
        _stayMuteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _stayMuteButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self addSubview:_stayMuteButton];
    }
    
    return _stayMuteButton;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
