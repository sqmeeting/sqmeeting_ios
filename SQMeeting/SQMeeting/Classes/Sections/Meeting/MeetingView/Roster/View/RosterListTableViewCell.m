#import "RosterListTableViewCell.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "UIControl+Extensions.h"

@implementation RosterListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:KBGColor]];
        self.backgroundColor =KBGColor;
        self.contentView.backgroundColor = KBGColor;
        [self configRosterCell];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = UIColorHex(0xd7dadd).CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(0, kRosterCellHeight - 0.5, KScreenWidth, 0.5f);
        [self.contentView.layer addSublayer:lineLayer];
    }
    
    return self;
}

- (void)configRosterCell {
    [self.avatrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
    }];
    
    [self.videoImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    [self.audioImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoImageBtn.mas_left).mas_offset(0);
        make.centerY.equalTo(self.mas_centerY);
        make.size.equalTo(self.videoImageBtn);
    }];
    
    [self.pinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.audioImageBtn.mas_left).mas_offset(-8);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatrImageView.mas_right).mas_offset(20);
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.pinImageView.mas_left).offset(-5);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
}

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 2;
        [_nameLabel sizeToFit];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIImageView *)avatrImageView {
    if(!_avatrImageView) {
        _avatrImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meeting_avatar"]];
        [self.contentView addSubview:_avatrImageView];
    }
    
    return _avatrImageView;
}

- (UIImageView *)pinImageView {
    if(!_pinImageView) {
        _pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meeting_rosterlist_pin"]];
        [self.contentView addSubview:_pinImageView];
    }
    return _pinImageView;
}

- (UIButton *)audioImageBtn {
    if(!_audioImageBtn) {
        @WeakObj(self);
        _audioImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioImageBtn setImage:[UIImage imageNamed:@"meeting_audio_mute"] forState:UIControlStateNormal];
        [_audioImageBtn setImage:[UIImage imageNamed:@"meeting_audio_unmute"] forState:UIControlStateSelected];
        [_audioImageBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.didSelectedCell) {
                self.didSelectedCell();
            }
        }];
        [self.contentView addSubview:_audioImageBtn];
    }
    return _audioImageBtn;
}

- (UIButton *)videoImageBtn {
    if (!_videoImageBtn) {
        _videoImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoImageBtn setImage:[UIImage imageNamed:@"meeting_video_mute"] forState:UIControlStateNormal];
        [_videoImageBtn setImage:[UIImage imageNamed:@"meeting_video_unmute"] forState:UIControlStateSelected];
        [self.contentView addSubview:_videoImageBtn];
    }
    return _videoImageBtn;
}

@end
