#import "SiteNameView.h"
#import "Masonry.h"
#import "UIView+Add.h"
#import "UIImage+Add.h"

@interface SiteNameView ()

@property (nonatomic, strong) UIView *backGroundView;

@property (nonatomic, strong) UILabel *siteName;

@property (nonatomic, strong) UIButton *pinStatusButton;

@property (nonatomic, strong) UIButton *muteBtn;

@end

@implementation SiteNameView

- (instancetype)init  {
    self = [super init];
    
    if(self) {
        self.pinStatusButton.hidden = YES;
        self.pinStatus = NO;
        self.userMuteStatus = NO;
        [self setSiteNameView];
    }
    
    return self;
}

- (void)setSiteNameView {
    [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_lessThanOrEqualTo(self.mas_width).mas_offset(-5);
    }];
    
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.spacing = 4;
    [self.backGroundView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.centerY.equalTo(self.backGroundView);
    }];
    
    [stackView addArrangedSubview:self.siteName];
    [stackView addArrangedSubview:self.pinStatusButton];
    [stackView addArrangedSubview:self.muteBtn];
    
    [self.siteName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
    }];
    
    [@[self.pinStatusButton,self.muteBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22);
    }];
}

- (void)setNameStr:(NSString *)nameStr {
    _nameStr = nameStr;
    self.siteName.text = _nameStr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.backGroundView setCornerRadius:6 addRectCorners:UIRectCornerTopRight];
}

- (void)setSiteNameWithUserPinStatus:(BOOL)pin {
    self.pinStatus = pin;
    [self finalLayout];
}

- (void)renewSiteNameViewByUserMuteStatus:(BOOL)userMute {
    self.userMuteStatus = userMute;
    [self finalLayout];
}

- (void)finalLayout {
    self.pinStatusButton.hidden = !self.isPinStatus;
    self.muteBtn.selected = !self.isUserMuteStatus;
}

- (UIView *)backGroundView {
    if(!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [self addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (UIButton *)pinStatusButton {
    if(!_pinStatusButton) {
        _pinStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pinStatusButton setImage:[UIImage imageBundlePath:@"frtc_meeting_incall_pin"] forState:UIControlStateNormal];
        [self.backGroundView addSubview:_pinStatusButton];
    }
    
    return _pinStatusButton;
}


- (UIButton *)muteBtn {
    if(!_muteBtn) {
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteBtn setImage:[UIImage imageBundlePath:@"frtc_icon-status-mute-white"] forState:UIControlStateNormal];
        [_muteBtn setImage:[UIImage imageBundlePath:@"frtc_icon-unstatus-mute-green"] forState:UIControlStateSelected];
        [self.backGroundView addSubview:_muteBtn];
    }
    
    return _muteBtn;
}

- (UILabel *)siteName {
    if(!_siteName) {
        _siteName = [[UILabel alloc] init];
        _siteName.textAlignment = NSTextAlignmentLeft;
        _siteName.numberOfLines = 1.0;
        _siteName.font = [UIFont systemFontOfSize:14.0];
        _siteName.textColor = [UIColor whiteColor];
        [self.backGroundView addSubview:_siteName];
    }
    
    return _siteName;
}

@end
