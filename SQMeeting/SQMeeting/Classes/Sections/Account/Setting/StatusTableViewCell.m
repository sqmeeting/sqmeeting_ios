#import "StatusTableViewCell.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIImage+Extensions.h"
#import <FrtcCall.h>

@interface StatusTableViewCell ()

@property (nonatomic, strong) UIImageView *accessoryImgView;

@end

@implementation StatusTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        [self configView];
        CALayer *layer = [CALayer new];
        layer.backgroundColor = KLineColor.CGColor;
        layer.frame = CGRectMake(KLeftSpacing, Status_Cell_Height - 1, KScreenWidth - KLeftSpacing*2 , 0.5);
        [self.contentView.layer addSublayer:layer];
    }
    return self;
}

- (void)configView {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.centerY.equalTo(self);
    }];
    
    [self.accessoryImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.equalTo(self);
    }];
    
    [self.noiseSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.equalTo(self);
    }];
    
    [self.signOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
    }];
}

- (void)setIsShowRightView:(BOOL)isShowRightView {
    _isShowRightView = isShowRightView;
    self.accessoryImgView.hidden = !_isShowRightView;
    if (_isShowRightView) {
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.accessoryImgView.mas_left).mas_offset(-10);
            make.centerY.equalTo(self);
            make.left.greaterThanOrEqualTo(self.nameLabel.mas_right).offset(10);
        }];
    }else{
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self);
            make.left.greaterThanOrEqualTo(self.nameLabel.mas_right).offset(10);
        }];
    }
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)didClickSignOutButton:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(signOut)]) {
        [self.delegate signOut];
    }
}

#pragma mark - lazy

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16.f];
        _nameLabel.textColor = KTextColor;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)detailLabel {
    if(!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14.f];
        _detailLabel.textColor = KDetailTextColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIImageView *)accessoryImgView {
    if (!_accessoryImgView) {
        _accessoryImgView = [[UIImageView alloc]init];
        _accessoryImgView.image = [UIImage imageNamed:@"setting_accessory"];
        _accessoryImgView.clipsToBounds = YES;
        [self.contentView addSubview:_accessoryImgView];
    }
    return _accessoryImgView;
}

- (UISwitch *)noiseSwitch {
    if (!_noiseSwitch) {
        _noiseSwitch = [UISwitch new];
        _noiseSwitch.hidden = YES;
        @WeakObj(self)
        [_noiseSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            @StrongObj(self)
            UISwitch *noiseSwitch = (UISwitch *)sender;
            if (self.valueChangeBlock){
                self.valueChangeBlock(noiseSwitch.on);
            }
        }];
        _noiseSwitch.onTintColor = kMainColor;
        [self.contentView addSubview:_noiseSwitch];
    }
    return _noiseSwitch;
}


- (UIButton *)signOutButton {
    if(!_signOutButton) {
        _signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signOutButton.hidden = YES;
        [_signOutButton setTitle:NSLocalizedString(@"sign_out", nil) forState:UIControlStateNormal];
        [_signOutButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        _signOutButton.backgroundColor = UIColor.whiteColor;
        _signOutButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_signOutButton setBackgroundImage:[UIImage imageFromColor:UIColorHex(0xd3d3d3)] forState:UIControlStateHighlighted];
        [_signOutButton addTarget:self action:@selector(didClickSignOutButton:) forControlEvents:UIControlEventTouchUpInside];
        _signOutButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _signOutButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.contentView addSubview:_signOutButton];
    }
    return _signOutButton;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
