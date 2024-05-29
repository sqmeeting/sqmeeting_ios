#import "TopBarView.h"
#import "Masonry.h"


@interface TopBarView()

@end

@implementation TopBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame withMuteMic:(BOOL)muteMic withMuteCamera:(BOOL)muteCamera withEncrypt:(BOOL)encrypt withAudioCall:(BOOL)audioCall {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.muteMic = muteMic;
        self.muteCamera = muteCamera;
        self.encrypt = encrypt;
        self.audioCall = audioCall;
        
       [self configTopBarView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    
    if(self) {
        [self configTopBarView];
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(onMicMute:) name:@"MUTE_MICRO" object:nil];
        [nc addObserver:self selector:@selector(onCameraMute:) name:@"MUTE_CAE" object:nil];
    }
    
    return self;
}

- (void)reLayoutTopLayoutView:(BOOL)isMuteMic withCameraMute:(BOOL)isCameraMute {
    if(isMuteMic && isCameraMute) {
        
        if(_audioCall) {
            self.muteVideoImageView.hidden = YES;
            [self.muteAudioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
            
        }else {
            self.muteVideoImageView.hidden = NO;
            [self.muteVideoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
            
            [self.muteAudioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.muteVideoImageView.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        }
        
        
        self.muteAudioImageView.hidden = NO;
        
    
    }
    
    if(!isMuteMic && !isCameraMute) {
        self.muteVideoImageView.hidden = YES;
        self.muteAudioImageView.hidden = YES;
    }
    
    if(isMuteMic && !isCameraMute) {
        self.muteVideoImageView.hidden = YES;
        self.muteAudioImageView.hidden = NO;
        
        [self.muteAudioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(25);
        }];
    }
    
    if(!isMuteMic && isCameraMute) {
        
        if(_audioCall) {
            self.muteVideoImageView.hidden = YES;
        } else {
            self.muteVideoImageView.hidden = NO;
            [self.muteVideoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        }
        
        self.muteAudioImageView.hidden = YES;
        
    }
}

- (void)showStaticsViewOrNot {
    if(self.topBarViewDelegate && [self.topBarViewDelegate respondsToSelector:@selector(showStaticsView)]) {
        [self.topBarViewDelegate showStaticsView];
    }
}

- (void)onMicMute:(NSNotification *)notification {
    BOOL hidden = ![[notification.userInfo objectForKey:@"MUTE_MICROHONE"] boolValue];
    self.muteAudioImageView.hidden = hidden;
    
    if(!hidden) {
        if(self.muteVideoImageView.hidden) {
            [self.muteAudioImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        } else {
            [self.muteAudioImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.muteVideoImageView.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        }
    }
}

- (void)onCameraMute:(NSNotification *)notification {
    BOOL hidden = ![[notification.userInfo objectForKey:@"MUTE_CAMERA"] boolValue];
    self.muteVideoImageView.hidden = hidden;
    
    if(hidden) {
        if(!self.muteAudioImageView.hidden) {
            [self.muteAudioImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.muteVideoImageView.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        }
    }
}


- (void)configTopBarView {
    [self.signalButton mas_makeConstraints:^(MASConstraintMaker *make) {
       //make.top.mas_equalTo(0);
       make.centerY.mas_equalTo(self.mas_centerY);
       make.left.mas_equalTo(5);
       make.width.mas_equalTo(25);
       make.height.mas_equalTo(25);
   }];
    
    if(self.isMuteCamera && !self.audioCall) {
        [self.muteVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(25);
        }];
    }
    
    if(self.isMuteMic) {
        if(self.isMuteCamera && !self.audioCall) {
            [self.muteAudioImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.muteVideoImageView.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        } else {
            [self.muteAudioImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.signalButton.mas_right).offset(5);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.width.mas_equalTo(25);
                make.height.mas_equalTo(25);
            }];
        }
    }
}

- (UIButton *)signalButton {
    if(!_signalButton) {
        _signalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signalButton setBackgroundImage:[UIImage imageNamed:(self.isEncrypt ? @"icon-signal-lock.png" : @"signal_strong.png")]
                                                forState:UIControlStateNormal];
        [_signalButton addTarget:self action:@selector(showStaticsViewOrNot) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_signalButton];
    }
    return _signalButton;
}

- (UIImageView *)muteVideoImageView {
    if(!_muteVideoImageView) {
        _muteVideoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status-camera-off.png"]];
        _muteVideoImageView.contentMode = UIViewContentModeScaleToFill;
        _muteVideoImageView.userInteractionEnabled = YES;
        _muteVideoImageView.hidden = !self.isMuteCamera || self.audioCall;
        [self addSubview:_muteVideoImageView];
    }
    
    return _muteVideoImageView;
}

- (UIImageView *)muteAudioImageView {
    if(!_muteAudioImageView) {
        _muteAudioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status-mic-off.png"]];
        _muteAudioImageView.contentMode = UIViewContentModeScaleToFill;
        _muteAudioImageView.userInteractionEnabled = YES;
        _muteAudioImageView.hidden = !self.isMuteMic;
        [self addSubview:_muteAudioImageView];
    }
    
    return _muteAudioImageView;
}

@end
