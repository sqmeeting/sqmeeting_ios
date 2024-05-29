#import "SendContentBackGroundView.h"
#import "Masonry.h"
#import "FrtcCall.h"
#import "NSNotificationCenter+NotificationCenterAdditions.h"

@interface SendContentBackGroundView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *btnStopShareContent;

@property (nonatomic, strong) UIButton *btnDisableCotentAudio;

@property (nonatomic, strong) UILabel *disableAudioLabel;

@property (nonatomic, strong) UILabel *stopContentLabel;

@end

@implementation SendContentBackGroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
        [self configView];
    }
    
    return self;
}

- (void)configView {
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]) {
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(222);
        }];
        
        [self.btnStopShareContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(96);
            make.height.mas_equalTo(96);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(64);
            make.left.mas_equalTo(self.mas_centerX).offset(48);
        }];
        
        [self.stopContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.btnStopShareContent.mas_bottom).offset(20);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
            make.centerX.mas_equalTo(self.btnStopShareContent.mas_centerX);
        }];
        
        [self.btnDisableCotentAudio mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(96);
            make.height.mas_equalTo(96);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(64);
            make.right.mas_equalTo(self.mas_centerX).offset(-48);
        }];
        
        [self.disableAudioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.btnDisableCotentAudio.mas_bottom).offset(20);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
            make.centerX.mas_equalTo(self.btnDisableCotentAudio.mas_centerX);
        }];
    }else {
        
        [self.btnStopShareContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(64);
            make.height.mas_equalTo(64);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.left.mas_equalTo(self.mas_centerX).offset(48);
        }];
        
        [self.stopContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.btnStopShareContent.mas_bottom).offset(20);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
            make.centerX.mas_equalTo(self.btnStopShareContent.mas_centerX);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.equalTo(self.btnStopShareContent.mas_top).offset(-50);
        }];
        
        [self.btnDisableCotentAudio mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(64);
            make.height.mas_equalTo(64);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.right.mas_equalTo(self.mas_centerX).offset(-48);
        }];
        
        [self.disableAudioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.btnDisableCotentAudio.mas_bottom).offset(20);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
            make.centerX.mas_equalTo(self.btnDisableCotentAudio.mas_centerX);
        }];
    }
}

#pragma mark --Button Sender--
- (void)stopShareContent:(UIButton *)sender {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationNameOnMainThread:FMeetingContentStopNotification object:nil userInfo:nil];
}

- (void)disableShareContentAudio:(UIButton *)sender {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1.0;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"您正在共享屏幕", nil) attributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
        _titleLabel.font = [UIFont systemFontOfSize:28.0];
        _titleLabel.attributedText = string;
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel.alpha = 1.0;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIButton *)btnStopShareContent {
    if(!_btnStopShareContent) {
        _btnStopShareContent = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnStopShareContent.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnStopShareContent setImage:[UIImage imageNamed:@"icon_stop_send_content"]
                              forState:UIControlStateNormal];
        [_btnStopShareContent setImage:[UIImage imageNamed:@"icon_stop_send_content"]
                              forState:UIControlStateSelected];
        
        [_btnStopShareContent setTitle:NSLocalizedString(@"share_close_content", nil) forState:UIControlStateSelected];
        [_btnStopShareContent setTitle:NSLocalizedString(@"share_open_content", nil) forState:UIControlStateNormal];
        [_btnStopShareContent addTarget:self action:@selector(stopShareContent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnStopShareContent];
    }
    
    return _btnStopShareContent;
}

- (UIButton *)btnDisableCotentAudio {
    if(!_btnDisableCotentAudio) {
        _btnDisableCotentAudio = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnDisableCotentAudio.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [_btnDisableCotentAudio setImage:[UIImage imageNamed:@"icon_disable_content_audio"]
                                forState:UIControlStateNormal];
        [_btnDisableCotentAudio setImage:[UIImage imageNamed:@"icon_disable_content_audio"]
                                forState:UIControlStateSelected];
        
        [_btnDisableCotentAudio setTitle:NSLocalizedString(@"share_close_content", nil) forState:UIControlStateSelected];
        [_btnDisableCotentAudio setTitle:NSLocalizedString(@"share_open_content", nil) forState:UIControlStateNormal];
        [_btnDisableCotentAudio addTarget:self action:@selector(disableShareContentAudio:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnDisableCotentAudio];
    }
    
    return _btnDisableCotentAudio;
}

- (UILabel *)disableAudioLabel {
    if(!_disableAudioLabel) {
        _disableAudioLabel = [[UILabel alloc] init];
        _disableAudioLabel.numberOfLines = 0;
        [self addSubview:_disableAudioLabel];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"共享设备音频：关", nil) attributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
        
        _disableAudioLabel.attributedText = string;
        _disableAudioLabel.textAlignment = NSTextAlignmentRight;
        _disableAudioLabel.alpha = 1.0;
    }
    
    return _disableAudioLabel;
}

- (UILabel *)stopContentLabel {
    if(!_stopContentLabel) {
        _stopContentLabel = [[UILabel alloc] init];
        _stopContentLabel.numberOfLines = 0;
        [self addSubview:_stopContentLabel];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"停止共享", nil) attributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
        
        _stopContentLabel.attributedText = string;
        _stopContentLabel.textAlignment = NSTextAlignmentRight;
        _stopContentLabel.alpha = 1.0;
    }
    
    return _stopContentLabel;
}



@end
