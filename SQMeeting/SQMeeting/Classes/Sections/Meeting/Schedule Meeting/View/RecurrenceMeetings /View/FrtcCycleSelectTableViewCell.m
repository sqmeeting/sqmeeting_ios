#import "FrtcCycleSelectTableViewCell.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "FrtcScheduleDetailModel.h"
#import "UIImage+Extensions.h"

@interface FrtcCycleSelectTableViewCell ()


@end


@implementation FrtcCycleSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        
        UIStackView *topStack = [[UIStackView alloc]init];
        topStack.spacing = 10;
        topStack.distribution = UIStackViewDistributionEqualSpacing;
        [self.contentView addSubview:topStack];

        [topStack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
        }];
    
        [topStack addArrangedSubviews:@[self.titleLabel,self.detailLabel]];

        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(KLeftSpacing, 50 - 0.5, KScreenWidth, 0.5f);
        [self.contentView.layer addSublayer:lineLayer];
    }
    return self;
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
        _detailLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return _detailLabel;
}

@end
