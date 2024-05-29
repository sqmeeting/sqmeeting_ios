#import "FrtcRequestUnmuteListMaskView.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIStackView+Extensions.h"

@interface FrtcRequestUnmuteListMaskView ()

@property (nonatomic, weak) UILabel*nameLabel;

@end

@implementation FrtcRequestUnmuteListMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _loadView];
    }
    return self;
}

- (void)_loadView {
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = kMainColor;
    bgView.layer.borderColor = UIColorHex(0x61a6ff).CGColor;
    bgView.layer.borderWidth = 1;
    bgView.layer.cornerRadius = 20;
    bgView.layer.masksToBounds = YES;
    [self addSubview:bgView];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIImageView *imageview = [[UIImageView alloc]init];
    imageview.image = [UIImage imageNamed:@"meeting_roster_lock"];
    [bgView addSubview:imageview];
    [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.centerY.equalTo(bgView);
    }];
    
    UILabel *nameLable = [[UILabel alloc]init];
    nameLable.font = [UIFont systemFontOfSize:14];
    nameLable.textColor = UIColor.whiteColor;
    [bgView addSubview:nameLable];
    _nameLabel = nameLable;
    
    UILabel *desLable = [[UILabel alloc]init];
    desLable.font = [UIFont systemFontOfSize:14];
    desLable.textColor = UIColor.whiteColor;
    desLable.text = NSLocalizedString(@"MEETING_ASK_TO_UNMUTE_TITLE", nil);
    [bgView addSubview:desLable];
    
    UIImageView *rightView = [[UIImageView alloc]init];
    rightView.image = [UIImage imageNamed:@"meeting_roster_right_line"];
    [bgView addSubview:rightView];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing12);
        make.centerY.equalTo(bgView);
    }];
    
    [nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageview.mas_right).offset(10);
        make.right.equalTo(desLable.mas_left).offset(-10);
        make.width.mas_lessThanOrEqualTo(LAND_SCAPE_HEIGHT/3);
        make.centerY.equalTo(bgView);
    }];
    
    [desLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rightView.mas_left).offset(-10);
        make.centerY.equalTo(bgView);
    }];
    
    @WeakObj(self)
    UITapGestureRecognizer *topGesture = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (self.selectedBlock) {
            self.selectedBlock();
        }
    }];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:topGesture];
}

- (void)setUnmuteName:(NSString *)unmuteName {
    _unmuteName = unmuteName;
    self.nameLabel.text = _unmuteName;
}

@end
