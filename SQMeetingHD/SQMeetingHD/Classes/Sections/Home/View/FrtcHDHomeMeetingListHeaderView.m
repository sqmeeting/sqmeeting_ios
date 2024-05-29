#import "FrtcHDHomeMeetingListHeaderView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"

@implementation FrtcHDHomeMeetingListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        @WeakObj(self);
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setImage:[UIImage imageNamed:@"home_meeting_histry"] forState:UIControlStateNormal];
        [titleBtn setTitle: NSLocalizedString(@"history_meeting", nil) forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [titleBtn setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        [self addSubview:titleBtn];
        [titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KHomeMeetingLeftSpacing);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(200);
        }];
        
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setImage:[UIImage imageNamed:@"home_meeting_delegate"] forState:UIControlStateNormal];
        [_clearButton setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
        _clearButton.hidden = YES;
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_clearButton setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        _clearButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        _clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_clearButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.cancleBtnBlock) {
                self.cancleBtnBlock();
            }
        }];
        [self addSubview:_clearButton];
        [_clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KHomeMeetingLeftSpacing);
            make.centerY.width.equalTo(titleBtn);
        }];
      
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(0, KHomeMeetingListHeaderViewHeight - 0.5f , KScreenWidth, 0.5f);
        [self.layer addSublayer:lineLayer];
    }
    
    return self;
}

@end
