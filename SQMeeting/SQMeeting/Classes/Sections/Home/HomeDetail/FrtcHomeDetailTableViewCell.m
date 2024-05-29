#import "FrtcHomeDetailTableViewCell.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"

@interface FrtcHomeDetailTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation FrtcHomeDetailTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        
        UIStackView *horizontalStackView = [[UIStackView alloc]init];
        horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
        horizontalStackView.distribution = UIStackViewDistributionEqualSpacing;
        horizontalStackView.alignment = UIStackViewAlignmentCenter;
        [self.contentView addSubview:horizontalStackView];
        [horizontalStackView addArrangedSubviews:@[self.titleLabel, self.detailLabel]];
        
        [horizontalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self.contentView);
        }];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(KLeftSpacing, KHomeDtailCellHeight - 0.5, KScreenWidth, 0.5f);
        [self.contentView.layer addSublayer:lineLayer];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)setInfo:(FHomeDetailMeetingInfo *)info {
    _info = info;
    self.titleLabel.text =  info.title;
    self.detailLabel.text = info.content;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark - lazy

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = KDetailTextColor;
        _detailLabel.font = [UIFont systemFontOfSize:15.f];
    }
    return _detailLabel;
}


@end
