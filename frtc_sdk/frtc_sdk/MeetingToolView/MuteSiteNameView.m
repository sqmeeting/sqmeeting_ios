#import "MuteSiteNameView.h"
#import "Masonry.h"
#import "SiteNameView.h"
#import "UIImage+Add.h"
#import "FrtcUIMacro.h"

@interface MuteSiteNameView ()

@property (nonatomic, strong) UIImageView *video_off_small_view;

@end


@implementation MuteSiteNameView

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = UIColor.blackColor;
        [self congfigView];
    }
    
    return self;
}

- (void)congfigView {
    [self.backGroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    [self.backGroudImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backGroudView);
        make.size.mas_equalTo(CGSizeMake(97, 96));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backGroudView.mas_centerX);
        make.centerY.mas_equalTo(self.backGroudView.mas_centerY);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.siteNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [self.localImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backGroudView);
    }];
    
    [self.video_off_small_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.localImageView).multipliedBy(0.25);
        make.height.equalTo(self.video_off_small_view.mas_width);
        make.center.equalTo(self.localImageView);
    }];
}

- (void)setLocalView:(BOOL)localView{
    _localView = localView;
    if (_localView) {
        self.localImageView.hidden = NO;
        self.backGroudImageView.hidden =
        self.nameLabel.hidden =
        self.siteNameView.hidden = YES;
    }else{
        self.localImageView.hidden = YES;
        self.backGroudImageView.hidden =
        self.nameLabel.hidden =
        self.siteNameView.hidden = NO;
    }
}

- (void)updateRemoteView {
    
}

- (UIView *)backGroudView {
    if(!_backGroudView) {
        _backGroudView =  [[UIView alloc] init];
        _backGroudView.backgroundColor = UIColorHex(0x000000);
        _backGroudView.userInteractionEnabled = YES;
        [self addSubview:_backGroudView];
    }
    
    return _backGroudView;
}

- (UIImageView *)backGroudImageView {
    if(!_backGroudImageView) {
        _backGroudImageView =  [[UIImageView alloc] initWithImage:[UIImage imageBundlePath:@"frtc_meeting_mute_head"]];
        _backGroudImageView.userInteractionEnabled = YES;
        [self.backGroudView addSubview:_backGroudImageView];
    }
    
    return _backGroudImageView;
}

- (UIView *)localImageView {
    if(!_localImageView) {
        _localImageView =  [[UIView alloc] init];
        _localImageView.userInteractionEnabled = YES;
        _localImageView.hidden = YES;
        _localImageView.backgroundColor = UIColorHex(0x111111);
        [self.backGroudView addSubview:_localImageView];
    }
    return _localImageView;
}

- (UIImageView *)video_off_small_view {
    if (!_video_off_small_view) {
        _video_off_small_view = [[UIImageView alloc]initWithImage:[UIImage imageBundlePath:@"frtc_meeting_video_off_small"]];
        _video_off_small_view.userInteractionEnabled = YES;
        [self.localImageView addSubview:_video_off_small_view];
    }
    return _video_off_small_view;
}

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 1.0;
        _nameLabel.font = [UIFont systemFontOfSize:30.0];
        _nameLabel.textColor = [UIColor whiteColor];
        [self.backGroudView addSubview:_nameLabel];
    }
    
    return _nameLabel;
}

- (SiteNameView *)siteNameView {
    if(!_siteNameView) {
        _siteNameView = [[SiteNameView alloc] init];
        [self.backGroudView addSubview:_siteNameView];
    }
    
    return _siteNameView;
}


@end
