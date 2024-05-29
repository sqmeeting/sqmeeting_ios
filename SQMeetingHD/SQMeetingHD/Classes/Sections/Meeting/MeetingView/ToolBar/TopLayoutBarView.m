#import "TopLayoutBarView.h"
#import "Masonry.h"
#import "NSTimer+Enhancement.h"
#import "UIStackView+Extensions.h"
#import "UIControl+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcAudioVideoAuthManager.h"
#import "UIGestureRecognizer+Extensions.h"

@interface TopLayoutBarView() 

@property (strong, nonatomic) UIButton *btnDropdown;

@property (strong, nonatomic) NSTimer  *getCurrentTimer;

@property (strong, nonatomic) NSTimer *meetingTimer;

@property (nonatomic) NSInteger i;

@end

@implementation TopLayoutBarView

- (instancetype)initWithFrame:(CGRect)frame withMuteMic:(BOOL)muteMic withMuteCamera:(BOOL)muteCamera withAudioCall:(BOOL)audioCall {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.muteMic = muteMic;
        self.muteCamera = muteCamera;
        self.audioCall = audioCall;
        
        self.i = 0;
        self.backgroundColor = UIColorHex(0x0263e);
        [self configTopLayoutView];
        [self startTimer:20];
        [self startMeetingTimer:1];
    }
    
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    
    if(self) {
        
    }
    
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
    [self cancelTimer];
}

- (void)startTimer:(NSTimeInterval)timeInterval {
    __weak __typeof(self)weakSelf = self;
    self.getCurrentTimer = [NSTimer plua_scheduledTimerWithTimeInterval:timeInterval block:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleCurrentTime];
    } repeats:YES];
}

- (void)startMeetingTimer:(NSTimeInterval)timeInterval {
    __weak __typeof(self)weakSelf = self;
    self.meetingTimer = [NSTimer plua_scheduledTimerWithTimeInterval:timeInterval block:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleTimeInterval];
    } repeats:YES];
}

- (void)handleTimeInterval {
    _i ++;
    NSTimeInterval timeInterval = (double)(self.i);
    int hour = (int)(timeInterval/3600);
    NSString *_hour;
    if(hour < 10) {
        _hour = [NSString stringWithFormat:@"0%d", hour];
    } else {
        _hour = [NSString stringWithFormat:@"%d", hour];
    }
    
    int minute = (int)(timeInterval - hour*3600)/60;
    NSString *_minute;
    if(minute < 10) {
        _minute = [NSString stringWithFormat:@"0%d", minute];
    } else {
        _minute = [NSString stringWithFormat:@"%d", minute];
    }
    
    int second = timeInterval - hour*3600 - minute*60;
    NSString *_second;
    if(second < 10) {
        _second = [NSString stringWithFormat:@"0%d", second];
    } else {
        _second = [NSString stringWithFormat:@"%d", second];
    }
    
    NSString *dural;
    if(hour == 0) {
        dural = [NSString stringWithFormat:@"%@:%@", _minute,_second];
    } else {
        dural = [NSString stringWithFormat:@"%@:%@:%@",_hour, _minute,_second];
    }
    
    self.meetingTimeLable.text = dural;
}

- (void)cancelTimer {
    if(_getCurrentTimer != nil) {
        [_getCurrentTimer invalidate];
        _getCurrentTimer = nil;
    }
    
    if(_meetingTimer != nil) {
        [_meetingTimer invalidate];
        _meetingTimer = nil;
    }
}

- (void)handleCurrentTime {
    self.timeLabel.text = [self getCurrentTime];
}

- (void)configTopLayoutView {
 
    UIStackView *leftStackView = [UIStackView new];
    leftStackView.spacing = 14;
    [self addSubview:leftStackView];
    
    UIStackView *centerStackView = [UIStackView new];
    centerStackView.spacing = 8;
    [self addSubview:centerStackView];

    UIStackView *rightStackView = [UIStackView new];
    rightStackView.spacing = 14;
    [self addSubview:rightStackView];
    
    [centerStackView addArrangedSubviews:@[self.meetingNameLable,self.meetingTimeLable,self.btnDropdown]];
    [leftStackView addArrangedSubviews:@[self.btnMuteSpeakder,self.btnChangeCamera]];
    [rightStackView addArrangedSubviews:@[self.timeLabel,self.btnHangup]];
    
    [centerStackView setCustomSpacing:2 afterView:self.meetingTimeLable];
    [leftStackView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerY.equalTo(self);
       make.left.mas_equalTo(20);
    }];
    
    [centerStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [rightStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(-20);
    }];
    
    [self.btnHangup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    [self.btnDropdown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"a hh:mm"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *currentDate = [formatter stringFromDate:datenow];
    return currentDate;
}


- (UIButton *)btnChangeCamera {
    if(!_btnChangeCamera) {
        @WeakObj(self);
        _btnChangeCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        //_btnChangeCamera.hidden = self.audioCall;
        [_btnChangeCamera setImage:[UIImage imageNamed:@"sdk_call_camera_switch"]
                          forState:UIControlStateNormal];
        [_btnChangeCamera setImage:[UIImage imageNamed:@"sdk_call_camera_switch"] forState:UIControlStateSelected];
        [_btnChangeCamera addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if(self.delegate && [self.delegate respondsToSelector:@selector(changeCameraPosition)]) {
                [self.delegate changeCameraPosition];
            }
        }];
    }
    
    return _btnChangeCamera;
}

- (UIButton *)btnMuteSpeakder {
    if(!_btnMuteSpeakder) {
        //@WeakObj(self);
        _btnMuteSpeakder = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnMuteSpeakder setImage:[UIImage imageNamed:@"sdk_call_speaker_off"]
                          forState:UIControlStateNormal];
        [_btnMuteSpeakder setImage:[UIImage imageNamed:@"sdk_call_speaker_on"] forState:UIControlStateSelected];
        [_btnMuteSpeakder addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            if ([FrtcAudioVideoAuthManager isHeadsetPluggedIn]) {
                
            }else {
                [MBProgressHUD showMessage:@"iPad 暂不支持听筒模式"];
            }
        }];
    }
    
    return _btnMuteSpeakder;
}


- (UIImageView *)middleImageView {
    if(!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
        _middleImageView.backgroundColor = [UIColor whiteColor];
    }
    
    return _middleImageView;
}

- (UILabel *)meetingNameLable {
    if(!_meetingNameLable) {
        _meetingNameLable = [[UILabel alloc] init];
        _meetingNameLable.textAlignment = NSTextAlignmentLeft;
        _meetingNameLable.numberOfLines = 1.0;
        _meetingNameLable.font = [UIFont boldSystemFontOfSize:16.0];
        _meetingNameLable.textColor = [UIColor whiteColor];
        _meetingNameLable.text = @"";
        _meetingNameLable.userInteractionEnabled = YES;
        @WeakObj(self);
        [_meetingNameLable addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(showDropdownView)]) {
                [self.delegate showDropdownView];
            }
        }]];
    }
    
    return _meetingNameLable;
}

- (UILabel *)meetingTimeLable {
    if(!_meetingTimeLable) {
        _meetingTimeLable = [[UILabel alloc] init];
        _meetingTimeLable.textAlignment = NSTextAlignmentLeft;
        _meetingTimeLable.numberOfLines = 1.0;
        _meetingTimeLable.font = [UIFont systemFontOfSize:14.0];
        _meetingTimeLable.textColor = [UIColor whiteColor];
        _meetingTimeLable.text = @"00:00";
        _meetingTimeLable.userInteractionEnabled = YES;
        @WeakObj(self);
        [_meetingTimeLable addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(showDropdownView)]) {
                [self.delegate showDropdownView];
            }
        }]];
    }
    
    return _meetingTimeLable;
}

- (UILabel *)timeLabel {
    if(!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.numberOfLines = 1.0;
        _timeLabel.font = [UIFont systemFontOfSize:14.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.text = [self getCurrentTime];
    }
    
    return _timeLabel;
}


- (UIButton *)btnHangup {
    if(!_btnHangup) {
        @WeakObj(self);
        _btnHangup = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnHangup setTitle:NSLocalizedString(@"join_finish", nil) forState:UIControlStateNormal];
        _btnHangup.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _btnHangup.backgroundColor = UIColor.redColor;
        _btnHangup.layer.cornerRadius = 4;
        _btnHangup.layer.masksToBounds = YES;
        [_btnHangup addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(dropCall)]) {
                [self.delegate dropCall];
            }
        }];
    }
    
    return _btnHangup;
}

- (UIButton *)btnDropdown {
    if(!_btnDropdown) {
        @WeakObj(self);
        _btnDropdown = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnDropdown setImage:[UIImage imageNamed:@"icon_dropdown"] forState:UIControlStateNormal];
        [_btnDropdown addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(showDropdownView)]) {
                [self.delegate showDropdownView];
            }
        }];
    }
    return _btnDropdown;
}

@end
