#import "FrtcHDStaticsCallTypeView.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"

@interface FrtcHDStaticsCallTypeView ()

@property (nonatomic, strong) UILabel *number;
@property (nonatomic, strong) UILabel *rateCall;

@end

@implementation FrtcHDStaticsCallTypeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configStaticCallTypeCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configStaticCallTypeCell];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configStaticCallTypeCell];
    }
    return self;
}


- (void)configStaticCallTypeCell {
    
    CALayer *lineLayer = [[CALayer alloc]init];
    lineLayer.borderColor = UIColorHex(0xd7dadd).CGColor;
    lineLayer.borderWidth = 0.5f;
    lineLayer.frame = CGRectMake(0, 0, KScreenWidth, 0.5f);
    [self.layer addSublayer:lineLayer];
    
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.spacing = 10;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.center.equalTo(self);
    }];
    [stackView addArrangedSubviews:@[self.number, self.meetingNumberLabel, self.rateCall, self.callRateLabel]];
    [stackView setCustomSpacing:25 afterView:self.meetingNumberLabel];
    
    CALayer *lineLayer2 = [[CALayer alloc]init];
    lineLayer2.borderColor = UIColorHex(0xd7dadd).CGColor;
    lineLayer2.borderWidth = 0.5f;
    lineLayer2.frame = CGRectMake(0, 39.5, KScreenWidth, 0.5f);
    [self.layer addSublayer:lineLayer2];
}

- (UILabel *)meetingNumberLabel {
    if(!_meetingNumberLabel) {
        _meetingNumberLabel = [[UILabel alloc] init];
        _meetingNumberLabel.font = [UIFont systemFontOfSize:14];
        _meetingNumberLabel.textColor = kMainColor;
        _meetingNumberLabel.text = @"";
    }
    return _meetingNumberLabel;
}

- (UILabel *)callRateLabel {
    if(!_callRateLabel) {
        _callRateLabel = [[UILabel alloc] init];
        _callRateLabel.font = [UIFont systemFontOfSize:14];
        _callRateLabel.textColor = kMainColor;
        _callRateLabel.text = @"";
    }
    return _callRateLabel;
}

- (UILabel *)number {
    if (!_number) {
        _number = [UILabel new];
        _number.text = [NSString stringWithFormat:@"%@: ",NSLocalizedString(@"call_number", nil)];
        _number.textColor = KTextColor;
        _number.font = [UIFont systemFontOfSize:14];
    }
    return _number;
}

- (UILabel *)rateCall {
    if (!_rateCall) {
        _rateCall = [UILabel new];
        _rateCall.text = [NSString stringWithFormat:@"%@: ",NSLocalizedString(@"call_rate", nil)];
        _rateCall.textColor = KTextColor;
        _rateCall.font = [UIFont systemFontOfSize:14];
    }
    return _rateCall;
}

@end
