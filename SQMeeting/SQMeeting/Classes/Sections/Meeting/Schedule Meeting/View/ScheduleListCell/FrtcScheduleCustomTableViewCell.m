#import "FrtcScheduleCustomTableViewCell.h"
#import "UIImage+Extensions.h"
#import "Masonry.h"
#import "FrtcScheduleCustomModel.h"

@interface FrtcScheduleCustomTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton  *selectBtn;

@end

@implementation FrtcScheduleCustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = KTextColor;
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        
        self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectBtn setImage:[UIImage imageNamed:@"schedule_yes"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.selectBtn];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self.contentView);
        }];
        
        CALayer *layer = [CALayer new];
        layer.backgroundColor = KLineColor.CGColor;
        layer.frame = CGRectMake(KLeftSpacing, 50 - 1, KScreenWidth - KLeftSpacing*2 , 0.5);
        [self.contentView.layer addSublayer:layer];
    }
    return self;
}

- (void)setModel:(FrtcScheduleCustomModel *)model {
    _model = model;
    self.titleLabel.text = _model.title;
    self.selectBtn.selected = _model.isSelect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
