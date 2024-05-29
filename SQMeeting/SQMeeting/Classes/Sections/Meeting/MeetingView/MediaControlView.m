#import "MediaControlView.h"
#import "Masonry.h"

@implementation MediaControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame withAudioCall:(BOOL)audioCall {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.audioCall = audioCall;
        [self configTalkingView];
    }
    
    return self;
}

- (void)configTalkingView {
    [self.mediaControlBackView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(0);
       make.bottom.mas_equalTo(0);
       make.width.mas_equalTo(80);
    }];
   
    if(self.audioCall) {
        [self.btnMuteSpeakder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(10);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(60);
        }];
    } else {
        [self.btnChangeCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(10);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(60);
        }];
        
        [self.btnMuteSpeakder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.btnChangeCamera.mas_bottom).mas_offset(20);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(60);
        }];
    }
}

- (void)changeCameraPosition {
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeCameraPosition)]) {
        [self.delegate changeCameraPosition];
    }
}

- (void)changeSpeakerStatus:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeSpeakerStatus:)]) {
        [self.delegate changeSpeakerStatus:sender.selected];
    }
}

- (UIImageView *)mediaControlBackView {
    if(!_mediaControlBackView) {
        _mediaControlBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bottom_Bar_BG.png"]];
        _mediaControlBackView.contentMode = UIViewContentModeScaleToFill;
        _mediaControlBackView.userInteractionEnabled = YES;
        [self addSubview:_mediaControlBackView];
    }
    
    return _mediaControlBackView;
}

- (UIButton *)btnChangeCamera {
    if(!_btnChangeCamera) {
        _btnChangeCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnChangeCamera.hidden = self.audioCall;
        [_btnChangeCamera setImage:[UIImage imageNamed:@"sdk_call_camera_switch"]
                                     forState:UIControlStateNormal];
        [_btnChangeCamera setImage:[UIImage imageNamed:@"sdk_call_camera_switch"] forState:UIControlStateSelected];
        [_btnChangeCamera addTarget:self action:@selector(changeCameraPosition) forControlEvents:UIControlEventTouchUpInside];
        [self.mediaControlBackView addSubview:_btnChangeCamera];
    }
    
    return _btnChangeCamera;
}

- (UIButton *)btnMuteSpeakder {
    if(!_btnMuteSpeakder) {
        _btnMuteSpeakder = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnMuteSpeakder setImage:[UIImage imageNamed:@"sdk_call_speaker_on"]
                              forState:UIControlStateNormal];
        [_btnMuteSpeakder setImage:[UIImage imageNamed:@"sdk_call_speaker_off"] forState:UIControlStateSelected];
        [_btnMuteSpeakder addTarget:self action:@selector(changeSpeakerStatus:) forControlEvents:UIControlEventTouchUpInside];
        [self.mediaControlBackView addSubview:_btnMuteSpeakder];
    }
    
    return _btnMuteSpeakder;
}

@end
