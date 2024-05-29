#import "FrtcOneRecurrenceView.h"
#import "Masonry.h"
#import "UIGestureRecognizer+Extensions.h"


@implementation FrtcOneRecurrenceView

- (instancetype)initWithFrame:(CGRect)frame isRight:(BOOL)isRight
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.textColor = KTextColor;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing12);
            make.centerY.equalTo(self);
        }];
        
        self.detailLabel = [[UILabel alloc]init];
        self.detailLabel.textColor = KDetailTextColor;
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.detailLabel];
        
        UIImageView *righLabel = [[UIImageView alloc]init];
        righLabel.image = [[UIImage imageNamed:@"frtc_meetingDetail_right"]
                           imageWithTintColor:KDetailTextColor];
        [self addSubview:righLabel];
        
        if (isRight) {
            righLabel.hidden = NO;
            [righLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-KLeftSpacing12);
                make.centerY.equalTo(self);
            }];
            [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(righLabel.mas_left).mas_offset(-10);
                make.centerY.equalTo(self);
            }];
        }else{
            righLabel.hidden = YES;
            [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-KLeftSpacing12);
                make.centerY.equalTo(self);
            }];
        }
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = KLineColor;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_offset(0);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        self.userInteractionEnabled = YES;
        @WeakObj(self)
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.didOneRecurrenceViewBlock) {
                self.didOneRecurrenceViewBlock();
            }
        }];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

@end
