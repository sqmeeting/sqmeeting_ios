#import "MediaControlView.h"
#import "Masonry.h"

@implementation MediaControlView

- (instancetype)initWithFrame:(CGRect)frame withAudioCall:(BOOL)audioCall {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.audioCall = audioCall;
        [self configTalkingView];
    }
    
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
}

- (void)configTalkingView {
    [self.mediaControlBackView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(0);
       make.bottom.mas_equalTo(0);
       make.width.mas_equalTo(100);
    }];
   
    if(self.audioCall) {
     
    } else {
        [self.btnChangeCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(10);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
    }
}

- (void)changeCameraPosition {
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeCameraPosition)]) {
        [self.delegate changeCameraPosition];
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
        [_btnChangeCamera setBackgroundImage:[UIImage imageNamed:@"sdk_call_camera_switch.png"]
                                     forState:UIControlStateNormal];
        [_btnChangeCamera setBackgroundImage:[UIImage imageNamed:@"sdk_call_camera_switch.png"] forState:UIControlStateSelected];
        [_btnChangeCamera addTarget:self action:@selector(changeCameraPosition) forControlEvents:UIControlEventTouchUpInside];
        [self.mediaControlBackView addSubview:_btnChangeCamera];
    }
    
    return _btnChangeCamera;
}

@end
