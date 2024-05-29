#import "FrtcScheduleDetaileCell.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIImage+Extensions.h"
#import "FrtcScheduleMeetingModel.h"
#import "FrtcScheduleCustomModel.h"

@interface FrtcScheduleDetaileCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, assign) BOOL isShowRightView;
@property (nonatomic, strong) UISwitch *noiseSwitch;
@property (nonatomic, strong) UIImageView *accessoryImgView;
@property (nonatomic, getter=isShowAccessView) BOOL showAccessView;

@end

@implementation FrtcScheduleDetaileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        [self configView];
        CALayer *layer = [CALayer new];
        layer.backgroundColor = KLineColor.CGColor;
        layer.frame = CGRectMake(KLeftSpacing, Detail_Cell_Height - 1, KScreenWidth - KLeftSpacing*2 , 0.5);
        [self.contentView.layer addSublayer:layer];
    }
    return self;
}

- (void)dealloc {
    
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
}

- (void)setModel:(FrtcScheduleMeetingModel *)model {
    _model = model;
    self.nameLabel.text    = _model.title;
    self.detailLabel.text = _model.detailTitle;
    self.isShowRightView  = _model.isShowSwitch;
    self.noiseSwitch.on    = _model.switchStatus;
    self.showAccessView    = !_model.hideAccessView;
}

- (void)setCustomModel:(FrtcScheduleCustomModel *)customModel  {
    _customModel = customModel;
    self.nameLabel.text = _customModel.title;
    self.detailLabel.text = @"";
    self.isShowRightView = YES;
    self.noiseSwitch.on = _customModel.isSelect;
}

- (void)setIsShowRightView:(BOOL)isShowRightView {
    _isShowRightView = isShowRightView;
    self.accessoryImgView.hidden = _isShowRightView;
    self.noiseSwitch.hidden = !_isShowRightView;
    if (!_isShowRightView) {
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.accessoryImgView.mas_left).mas_offset(-10);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(KScaleWidth(200));
        }];
    }else{
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(KScaleWidth(200));
        }];
    }
}

- (void)setShowAccessView:(BOOL)showAccessView {
    _showAccessView = showAccessView;
    if (_model.isHideAccessView && !_model.isShowSwitch) {
        self.accessoryImgView.hidden = YES;
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(KScaleWidth(200));
        }];
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
        @WeakObj(self);
        [_noiseSwitch addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
            UISwitch *noiseSwitch = (UISwitch *)sender;
            @StrongObj(self)
            if (self.switchCallBack) {
                self.switchCallBack(noiseSwitch.isOn);
            }
        }];
        _noiseSwitch.onTintColor = kMainColor;
        [self.contentView addSubview:_noiseSwitch];
    }
    return _noiseSwitch;
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
