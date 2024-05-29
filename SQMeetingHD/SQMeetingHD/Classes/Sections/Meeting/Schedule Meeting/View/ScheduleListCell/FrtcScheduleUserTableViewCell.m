#import "FrtcScheduleUserTableViewCell.h"
#import "UIImage+Extensions.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"
#import "UIButton+Extensions.h"

@interface FrtcScheduleUserTableViewCell ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation FrtcScheduleUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        
        [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing/2);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectBtn.mas_right).mas_offset(15);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).mas_offset(15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.f];
        _titleLabel.textColor = KTextColor;
        _titleLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.image = [UIImage imageNamed:@"meeting_avatar"];
        _iconView.clipsToBounds = YES;
        [self.contentView addSubview:_iconView];
    }
    return _iconView;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.userInteractionEnabled = NO;
        [_selectBtn setImage:[UIImage imageNamed:@"meeting_schedulet_no"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"meeting_schedulet_select"] forState:UIControlStateSelected];
        [_selectBtn setImage:[UIImage imageNamed:@"meeting_schedule_cancle"] forState:UIControlStateDisabled];
        [_selectBtn setImage:[UIImage imageNamed:@"meeting_schedulet_finSelect"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:_selectBtn];
    }
    return _selectBtn;
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
