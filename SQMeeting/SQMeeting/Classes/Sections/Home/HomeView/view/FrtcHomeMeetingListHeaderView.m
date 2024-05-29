#import "FrtcHomeMeetingListHeaderView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"

@implementation FrtcHomeMeetingListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        @WeakObj(self);
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.text = NSLocalizedString(@"history_meeting", nil);
        titleLabel.textColor = KTextColor;
        titleLabel.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.centerY.equalTo(self);
        }];
        
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
        _clearButton.hidden = YES;
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_clearButton setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        [_clearButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.cancleBtnBlock) {
                self.cancleBtnBlock();
            }
        }];
        [self addSubview:_clearButton];
        [_clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(self);
        }];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.borderColor = KLineColor.CGColor;
        lineLayer.borderWidth = 0.5f;
        lineLayer.frame = CGRectMake(0, KHomeMeetingListHeaderViewHeight - 0.5f , KScreenWidth, 0.5f);
        [self.layer addSublayer:lineLayer];
    }
    
    return self;
}

- (void)dealloc {
    
}

@end
