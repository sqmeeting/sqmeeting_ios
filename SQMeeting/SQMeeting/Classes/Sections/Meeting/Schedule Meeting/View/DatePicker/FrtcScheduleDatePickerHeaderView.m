#import "FrtcScheduleDatePickerHeaderView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"

@implementation FrtcScheduleDatePickerHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self datePickerHeaderLayout];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self datePickerHeaderLayout];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self datePickerHeaderLayout];
    }
    return self;
}

- (void)datePickerHeaderLayout {
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"call_cancel", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KDetailTextColor forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    @WeakObj(self);
    [cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (self.dateHeaderViewBlock) {
            self.dateHeaderViewBlock(NO);
        }
    }];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(KLeftSpacing);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.textColor = KTextColor;
    _titleLabel.font = [UIFont systemFontOfSize:15.f];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    
    UIButton * confirmBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:NSLocalizedString(@"string_ok", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [confirmBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        if (self.dateHeaderViewBlock) {
            self.dateHeaderViewBlock(YES);
        }
    }];
    [self addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(-KLeftSpacing);
    }];
}


@end
