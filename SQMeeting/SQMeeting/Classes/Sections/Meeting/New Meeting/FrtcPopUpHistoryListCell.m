#import "FrtcPopUpHistoryListCell.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"

@interface FrtcPopUpHistoryListCell ()

@end

@implementation FrtcPopUpHistoryListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        self.contentView.backgroundColor = KBGColor;
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        [self.contentView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self.contentView);
        }];
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.font  = [UIFont systemFontOfSize:15.f];
        
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = KTextColor;
        _detailLabel.font  = [UIFont systemFontOfSize:15.f];
        //_detailLabel.text = @"meeting number";
        
        [stackView addArrangedSubviews:@[_titleLabel,_detailLabel]];
    }
    return self;
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
