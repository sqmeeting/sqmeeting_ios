#import "TalkingToolBarView.h"
#import "Masonry.h"
#import "FrtcCall.h"
#import "UIButton+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UIControl+Extensions.h"
#import "MBProgressHUD+Extensions.h"

@interface TalkingToolBarView ()

@property (nonatomic, getter=isTempTurnOffCamera) BOOL tempTurnOffCamera;

@end

@implementation TalkingToolBarView

- (instancetype)initWithFrame:(CGRect)frame withAudioCall:(BOOL)audioCall {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.audioCall = audioCall;
        [self configTalkingView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShareContentButtonState:) name:kShareContentDisconnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startShareContentButtonState:) name:kShareContentStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopContent:) name:FMeetingContentStopNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShareContentDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShareContentStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FMeetingContentStopNotification object:nil];
}

- (void)updateMicrophoneImageForValue:(int)microphoneValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (microphoneValue == 1) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_0"] forState:UIControlStateNormal];
        }else if (microphoneValue == 2) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_1"] forState:UIControlStateNormal];
        }else if (microphoneValue == 3) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_2"] forState:UIControlStateNormal];
        }else if (microphoneValue == 4) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_3"] forState:UIControlStateNormal];
        }else if (microphoneValue == 5) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_4"] forState:UIControlStateNormal];
        }else if (microphoneValue == 6) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_5"] forState:UIControlStateNormal];
        }else if (microphoneValue == 7) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_6"] forState:UIControlStateNormal];
        }else if (microphoneValue == 8) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_7"] forState:UIControlStateNormal];
        }else if (microphoneValue == 9) {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_8"] forState:UIControlStateNormal];
        }else {
            [self.btnMuteMicrophone setImage:[UIImage imageNamed:@"frtc_microphone_9"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark --Notification--
- (void)updateShareContentButtonState:(NSNotification *)notification {
    self.btnShareContent.selected = NO;
    self.btnTurnOffCamera.enabled = YES;
    if (!self.tempTurnOffCamera) {
        [self turnOffCamera:self.btnTurnOffCamera];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareContent:)]) {
        [self.delegate shareContent:self.btnShareContent.selected];
    }
}

- (void)stopContent:(NSNotification *)notification {
    self.btnTurnOffCamera.enabled = YES;
    if (!self.btnTurnOffCamera.selected) {
        [self turnOffCamera:self.btnTurnOffCamera];
    }
    [self shareContent:self.btnShareContent];
}

- (void)startShareContentButtonState:(NSNotification *)notification {
    self.btnShareContent.selected = YES;

    self.tempTurnOffCamera = self.btnTurnOffCamera.selected;
    self.btnTurnOffCamera.enabled  = NO;
    if (!self.btnTurnOffCamera.selected) {
        [self turnOffCamera:self.btnTurnOffCamera];
    }
    
    if(!self.isSharingContent) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shareContent:)]) {
            [self.delegate shareContent:self.btnShareContent.selected];
        }
        
        self.sharingContent = YES;
    }
}

#pragma mark --Button Sender--
- (void)hiddenLocalView:(UIButton *)sender {
    sender.selected = !sender.isSelected;
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenLocalView:)]) {
        [self.delegate hiddenLocalView:sender.selected];
    }
}

- (void)turnOffCamera:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteCamera:)]) {
        [self.delegate muteCamera:sender.selected];
    }
}

- (void)shareContent:(UIButton *)sender {
    //sender.selected = !sender.isSelected;
    if(self.btnShareContent.isSelected) {
        self.sharingContent = NO;
    } else {
        self.sharingContent = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareContent:)]) {
        [self.delegate shareContent:self.isSharingContent];
    }
}

- (void)participent:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(participent)]) {
        [self.delegate participent];
    }
}

- (void)configTalkingView {
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.axis     = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = 10;
    [self addSubview:stackView];
    
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
    }];
    
  
    [stackView addArrangedSubviews:@[self.btnMuteMicrophone,self.btnTurnOffCamera, self.btnShareContent, /*self.btnFloatingFrame,*/self.btnParticipent,self.btnMore]];
  
    [self.btnTurnOffCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kToolBarHeight);
    }];
    
    [self.btnShareContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kToolBarHeight);
    }];
    
    [self.btnMuteMicrophone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kToolBarHeight);
    }];
    
    [self.btnParticipent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.btnMuteMicrophone);
    }];
    
    [self.btnMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.btnMuteMicrophone);
    }];
    
    
}

- (UIButton *)btnMuteMicrophone {
    if(!_btnMuteMicrophone) {
        @WeakObj(self);
        _btnMuteMicrophone = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMuteMicrophone.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnMuteMicrophone setImage:[UIImage imageNamed:@"icon_mic_on"]
                            forState:UIControlStateNormal];
        [_btnMuteMicrophone setImage:[UIImage imageNamed:@"icon_mic_off"] forState:UIControlStateSelected];
        [_btnMuteMicrophone setTitle:NSLocalizedString(@"join_Mute", nil) forState:UIControlStateNormal];
        [_btnMuteMicrophone setTitle:NSLocalizedString(@"join_UNmute", nil) forState:UIControlStateSelected];
        [_btnMuteMicrophone addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            UIButton *btn = (UIButton *)sender;
            if(self.delegate && [self.delegate respondsToSelector:@selector(muteMicroPhone:)]) {
                if (!btn.selected) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"meeting_you_youselfmute", nil)];
                }
                [self.delegate muteMicroPhone:!btn.selected];
            }
        }];
        [_btnMuteMicrophone setImageLayout:UIButtonLayoutImageTop space:8];
        _btnMuteMicrophone.isSizeToFit = true;
    }
    
    return _btnMuteMicrophone;
}


- (UIButton *)btnTurnOffCamera {
    if(!_btnTurnOffCamera) {
        _btnTurnOffCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnTurnOffCamera.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnTurnOffCamera setImage:[UIImage imageNamed:@"icon_camera_on"]
                           forState:UIControlStateNormal];
        [_btnTurnOffCamera setImage:[UIImage imageNamed:@"icon_camera_off"]
                           forState:UIControlStateSelected];
        [_btnTurnOffCamera setImage:[UIImage imageNamed:@"icon_camera_off"]
                           forState:UIControlStateDisabled];
        [_btnTurnOffCamera setTitle:NSLocalizedString(@"join_stop_video", nil) forState:UIControlStateNormal];
        [_btnTurnOffCamera setTitle:NSLocalizedString(@"join_open_video", nil) forState:UIControlStateSelected];
        [_btnTurnOffCamera setTitle:NSLocalizedString(@"join_stop_video", nil) forState:UIControlStateDisabled];
        [_btnTurnOffCamera addTarget:self action:@selector(turnOffCamera:) forControlEvents:UIControlEventTouchUpInside];
        [_btnTurnOffCamera setImageLayout:UIButtonLayoutImageTop space:8];
        _btnTurnOffCamera.isSizeToFit = true;
    }
    
    return _btnTurnOffCamera;
}

- (UIButton *)btnShareContent {
    if(!_btnShareContent) {
        _btnShareContent = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnShareContent.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnShareContent setImage:[UIImage imageNamed:@"icon_content_on"]
                          forState:UIControlStateNormal];
        [_btnShareContent setImage:[UIImage imageNamed:@"icon_content_off"]
                          forState:UIControlStateSelected];
        
        [_btnShareContent setTitle:NSLocalizedString(@"share_close_content", nil) forState:UIControlStateSelected];
        [_btnShareContent setTitle:NSLocalizedString(@"share_open_content", nil) forState:UIControlStateNormal];
        [_btnShareContent addTarget:self action:@selector(shareContent:) forControlEvents:UIControlEventTouchUpInside];
        [_btnShareContent setImageLayout:UIButtonLayoutImageTop space:8];
        _btnShareContent.isSizeToFit = true;
    }
    
    return _btnShareContent;
}

- (UIButton *)btnFloatingFrame {
    if(!_btnFloatingFrame) {
        _btnFloatingFrame = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnFloatingFrame.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnFloatingFrame setImage:[UIImage imageNamed:@"icon_floating_on"]
                           forState:UIControlStateNormal];
        [_btnFloatingFrame setImage:[UIImage imageNamed:@"icon_floating_off"]
                           forState:UIControlStateSelected];
        [_btnFloatingFrame setTitle:NSLocalizedString(@"join_close_frame", nil) forState:UIControlStateNormal];
        [_btnFloatingFrame setTitle:NSLocalizedString(@"join_open_frame", nil) forState:UIControlStateSelected];
        [_btnFloatingFrame addTarget:self action:@selector(hiddenLocalView:) forControlEvents:UIControlEventTouchUpInside];
        [_btnFloatingFrame setImageLayout:UIButtonLayoutImageTop space:8];
        _btnFloatingFrame.isSizeToFit = true;
    }
    
    return _btnFloatingFrame;
}


- (UIButton *)btnParticipent {
    if(!_btnParticipent) {
        _btnParticipent = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnParticipent.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnParticipent setImage:[UIImage imageNamed:@"icon_participant_2.png"]
                         forState:UIControlStateNormal];
        [_btnParticipent setImage:[UIImage imageNamed:@"icon_participant_2.png"] forState:UIControlStateSelected];
        [_btnParticipent setTitle: NSLocalizedString(@"participants", nil) forState:UIControlStateNormal];
        [_btnParticipent addTarget:self action:@selector(participent:) forControlEvents:UIControlEventTouchUpInside];
        [_btnParticipent setImageLayout:UIButtonLayoutImageTop space:8];
        _btnParticipent.isSizeToFit = true;
        
        [_btnParticipent addSubview:self.redDotView];
        [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.btnParticipent).mas_offset(15);
            make.centerY.equalTo(self.btnParticipent).mas_offset(-22);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
    }
    return _btnParticipent;
}

- (UIView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[UIView alloc]init];
        _redDotView.backgroundColor = UIColor.redColor;
        _redDotView.layer.cornerRadius = 4;
        _redDotView.layer.masksToBounds = YES;
        _redDotView.hidden = YES;
    }
    return _redDotView;
}

- (UIButton *)btnMore {
    if(!_btnMore) {
        @WeakObj(self);
        _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMore.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnMore setImage:[UIImage imageNamed:@"icon_more"]
                  forState:UIControlStateNormal];
        [_btnMore setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateSelected];
        [_btnMore setTitle:NSLocalizedString(@"join_more", nil) forState:UIControlStateNormal];
        [_btnMore setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_btnMore addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if(self.delegate && [self.delegate respondsToSelector:@selector(clickMoreBtn:)]) {
                [self.delegate clickMoreBtn:self->_btnMore];
            }
        }];
        [_btnMore setImageLayout:UIButtonLayoutImageTop space:8];
        _btnMore.isSizeToFit = true;
    }
    
    return _btnMore;
}

- (void)refreshToolBarView:(BOOL)isOnlyLocal {
    
}

@end
