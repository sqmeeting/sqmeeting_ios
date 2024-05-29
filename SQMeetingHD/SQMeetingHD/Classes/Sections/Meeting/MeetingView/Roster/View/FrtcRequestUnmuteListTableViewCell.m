#import "FrtcRequestUnmuteListTableViewCell.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIStackView+Extensions.h"

@implementation FrtcRequestUnmuteListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = KBGColor;
        
        UIImageView *imageview = [[UIImageView alloc]init];
        imageview.image = [UIImage imageNamed:@"meeting_avatar"];
        [self.contentView addSubview:imageview];
        [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _nameLable = [[UILabel alloc]init];
        _nameLable.font = [UIFont boldSystemFontOfSize:15];
        _nameLable.textColor = KTextColor;
        [self.contentView addSubview:_nameLable];
        
        UILabel *desLable = [[UILabel alloc]init];
        desLable.font = [UIFont systemFontOfSize:14];
        desLable.textColor = KTextColor666666;
        desLable.text = NSLocalizedString(@"MEETING_ROSTER_CELLVIEW_DES", nil);
        [self.contentView addSubview:desLable];
        
        UILabel *agreeButton = [[UILabel alloc]init];
        agreeButton.font = [UIFont systemFontOfSize:16];
        agreeButton.textColor = kMainColor;
        agreeButton.text = NSLocalizedString(@"MEETING_ROSTER_CELLVIEW_OK", nil);
        agreeButton.layer.cornerRadius = 4 ;
        agreeButton.layer.masksToBounds = YES ;
        [self.contentView addSubview:agreeButton];
    
        [agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing);
            make.size.mas_equalTo(CGSizeMake(50, 25));
            make.centerY.equalTo(self.contentView);
        }];
        
        [desLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(agreeButton.mas_left).offset(-5);
            make.centerY.equalTo(self.contentView);
        }];
        
        [_nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageview.mas_right).offset(5);
            make.right.equalTo(desLable.mas_left).offset(-5);
            make.centerY.equalTo(self.contentView);
        }];
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
