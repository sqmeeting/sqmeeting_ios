#import "FrtcRequestUnmuteItemView.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIStackView+Extensions.h"

@implementation FrtcRequestUnmuteItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.frame = frame;
        self.backgroundColor = UIColorHex(0xe1edff);
        
        UIImageView *imageview = [[UIImageView alloc]init];
        imageview.image = [UIImage imageNamed:@"meeting_roster_lock_blue"];
        [self addSubview:imageview];
        [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20).priority(750);
            make.centerY.equalTo(self);
        }];
        
        _nameLable = [[UILabel alloc]init];
        _nameLable.font = [UIFont systemFontOfSize:14];
        _nameLable.textColor = kMainColor;
        [self addSubview:_nameLable];
        
        UILabel *desLable = [[UILabel alloc]init];
        desLable.font = [UIFont systemFontOfSize:14];
        desLable.textColor = kMainColor;
        desLable.text = NSLocalizedString(@"MEETING_ASK_TO_UNMUTE_TITLE", nil);
        [self addSubview:desLable];
        
        UILabel *agreeButton = [[UILabel alloc]init];
        agreeButton.textAlignment = NSTextAlignmentCenter;
        agreeButton.font = [UIFont systemFontOfSize:15];
        agreeButton.textColor = kMainColor;
        agreeButton.text = NSLocalizedString(@"MEETING_ROSTER_UNMUTEREUQEST_LISTVIEW_View", nil);
        agreeButton.layer.cornerRadius = 4 ;
        agreeButton.layer.masksToBounds = YES ;
        agreeButton.backgroundColor = UIColor.whiteColor;
        agreeButton.layer.borderColor = kMainColor.CGColor;
        agreeButton.layer.borderWidth = 1;
        [self addSubview:agreeButton];
        
        _redDotView = [[UIView alloc]init];
        _redDotView.backgroundColor = UIColor.redColor;
        _redDotView.layer.cornerRadius = 4;
        _redDotView.layer.masksToBounds = YES;
        _redDotView.hidden = YES;
        [self addSubview:_redDotView];
        
        [agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20).priority(750);;
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(60, 26));
        }];
        
        [_nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageview.mas_right).offset(10);
            make.right.equalTo(desLable.mas_left).offset(-10);
            make.width.mas_lessThanOrEqualTo(LAND_SCAPE_HEIGHT/3);
            make.centerY.equalTo(self);
        }];
        
        [desLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(agreeButton.mas_left).offset(-10);
            make.centerY.equalTo(self);
        }];
        
        [_redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(agreeButton.mas_right).mas_offset(2);
            make.top.equalTo(agreeButton.mas_top).mas_offset(-2);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];

    }
    return self;
}

@end
