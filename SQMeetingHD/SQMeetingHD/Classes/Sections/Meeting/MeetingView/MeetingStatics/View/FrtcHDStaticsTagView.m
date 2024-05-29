#import "FrtcHDStaticsTagView.h"
#import "Masonry.h"

@interface FrtcHDStaticsTagView ()

@property (nonatomic, strong) UILabel *participantLabel;

@property (nonatomic, strong) UILabel *channelLabel;

@property (nonatomic, strong) UILabel *formatLabel;

@property (nonatomic, strong) UILabel *rateUsedLabel;

@property (nonatomic, strong) UILabel *packetLostLable;

@property (nonatomic, strong) UILabel *jitterLabel;

@property (nonatomic, strong) UILabel *errorConcealmentLable;

@end

@implementation FrtcHDStaticsTagView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configStaticTagView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configStaticTagView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configStaticTagView];
    }
    return self;
}


- (void)configStaticTagView {
    
    [self.participantLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(20);
        make.width.equalTo(self.mas_width).dividedBy(4);
        make.height.mas_equalTo(29);
    }];
    
    [self.channelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.participantLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(10);
        make.height.mas_equalTo(29);
    }];
    
    [self.formatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.channelLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(6);
        make.height.mas_equalTo(29);
    }];
    
    [self.rateUsedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.formatLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(9);
        make.height.mas_equalTo(29);
    }];
    
    [self.packetLostLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.rateUsedLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(9);
        make.height.mas_equalTo(29);
    }];
    
    [self.jitterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.packetLostLable.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(9);
        make.height.mas_equalTo(29);
    }];
    
    [self.errorConcealmentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.jitterLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(10);
        make.height.mas_equalTo(29);
    }];
    
}

- (UILabel *)participantLabel {
    if(!_participantLabel) {
        _participantLabel = [[UILabel alloc] init];
        _participantLabel.font = [UIFont boldSystemFontOfSize:14];
        _participantLabel.textColor = KTextColor;
        _participantLabel.text = NSLocalizedString(@"statistic_participant", nil);
        _participantLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_participantLabel];
    }
    return _participantLabel;
}

- (UILabel *)channelLabel {
    if(!_channelLabel) {
        _channelLabel = [[UILabel alloc] init];
        _channelLabel.font = [UIFont boldSystemFontOfSize:14];
        _channelLabel.textColor = KTextColor;
        _channelLabel.text = NSLocalizedString(@"statistic_channel", nil);
        _channelLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_channelLabel];
    }
    return _channelLabel;
}

- (UILabel *)formatLabel {
    if(!_formatLabel) {
        _formatLabel = [[UILabel alloc] init];
        _formatLabel.font = [UIFont boldSystemFontOfSize:14];
        _formatLabel.textColor = KTextColor;
        _formatLabel.text = NSLocalizedString(@"statistic_format", nil);
        _formatLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_formatLabel];
    }
    return _formatLabel;
}

- (UILabel *)rateUsedLabel {
    if(!_rateUsedLabel) {
        _rateUsedLabel = [[UILabel alloc] init];
        _rateUsedLabel.font = [UIFont boldSystemFontOfSize:14];
        _rateUsedLabel.textColor = KTextColor;
        _rateUsedLabel.text = NSLocalizedString(@"statistic_rateused", nil);
        _rateUsedLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_rateUsedLabel];
    }
    return _rateUsedLabel;
}

- (UILabel *)packetLostLable {
    if(!_packetLostLable) {
        _packetLostLable = [[UILabel alloc] init];
        _packetLostLable.font = [UIFont boldSystemFontOfSize:14];
        _packetLostLable.textColor = KTextColor;
        _packetLostLable.text = NSLocalizedString(@"statistic_frame_rate", nil);
        _packetLostLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_packetLostLable];
    }
    return _packetLostLable;
}

- (UILabel *)jitterLabel {
    if(!_jitterLabel) {
        _jitterLabel = [[UILabel alloc] init];
        _jitterLabel.font = [UIFont boldSystemFontOfSize:14];
        _jitterLabel.textColor = KTextColor;
        _jitterLabel.text = NSLocalizedString(@"statistic_lost", nil);
        _jitterLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_jitterLabel];
    }
    return _jitterLabel;
}

- (UILabel *)errorConcealmentLable {
    if(!_errorConcealmentLable) {
        _errorConcealmentLable = [[UILabel alloc] init];
        _errorConcealmentLable.font = [UIFont boldSystemFontOfSize:14];
        _errorConcealmentLable.textColor = KTextColor;
        _errorConcealmentLable.text = NSLocalizedString(@"statistic_jitter", nil);
        _errorConcealmentLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_errorConcealmentLable];
    }
    return _errorConcealmentLable;
}

@end
