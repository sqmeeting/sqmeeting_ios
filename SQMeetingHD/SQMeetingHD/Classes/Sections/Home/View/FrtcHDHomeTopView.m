#import "FrtcHDHomeTopView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIButton+Extensions.h"

@interface FrtcHDHomeTopView ()

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation FrtcHDHomeTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.whiteColor;
    
        UIStackView *stackView = [UIStackView new];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        [self addSubview:stackView];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KHomeMeetingLeftSpacing-28);
            make.right.mas_equalTo(-(KHomeMeetingLeftSpacing-28));
            make.centerY.mas_equalTo(0);
        }];
        
        @WeakObj(self);
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_leftBtn setImage:[UIImage imageNamed:@"home_newMeeting"]
                  forState:UIControlStateNormal];
        [_leftBtn setTitle:NSLocalizedString(@"new_meeting", nil) forState:UIControlStateNormal];
        [_leftBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        [_leftBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.clickBtnBlock) {
                self.clickBtnBlock(0);
            }
        }];
        [_leftBtn setImageLayout:UIButtonLayoutImageTop space:8];
        _leftBtn.isSizeToFit = true;
        
        
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_centerBtn setImage:[UIImage imageNamed:@"home_addMeeting"]
                    forState:UIControlStateNormal];
        [_centerBtn setTitle:NSLocalizedString(@"join_meeting", nil) forState:UIControlStateNormal];
        [_centerBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        [_centerBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.clickBtnBlock) {
                self.clickBtnBlock(1);
            }
        }];
        [_centerBtn setImageLayout:UIButtonLayoutImageTop space:8];
        _centerBtn.isSizeToFit = true;
        
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_rightBtn setImage:[UIImage imageNamed:@"home_arrangeMeeting"]
                   forState:UIControlStateNormal];
        [_rightBtn setTitle:NSLocalizedString(@"schedule_meeting", nil) forState:UIControlStateNormal];
        [_rightBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        [_rightBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.clickBtnBlock) {
                self.clickBtnBlock(2);
            }
        }];
        [_rightBtn setImageLayout:UIButtonLayoutImageTop space:8];
        _rightBtn.isSizeToFit = true;
        
        
        [stackView addArrangedSubviews:@[_leftBtn,_centerBtn,_rightBtn]];
        
        [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(120);
        }];
        
        [_centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_leftBtn);
        }];
        
        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_leftBtn);
        }];
        
        UIView *bottomView = [UIView new];
        bottomView.backgroundColor = UIColorHex(0xf8f9fa);
        [self addSubview:bottomView];
        
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(8);
        }];
        
    }
    return self;
}


@end
