#import "StaticsTableViewCell.h"
#import "Masonry.h"
#import "UIButton+Extensions.h"

#define ItemHeight 29

@implementation StaticsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configStaticTagTypeCell];
    }
    return self;
}

- (void)updateCellInfomation:(MediaDetailModel *)model {
    _participantLabel.text = model.participantName;
    _channelLabel.text = [self getChannelLabelText:model];
    _formatLabel.text = model.resolution;
    _rateUsedLabel.text = [NSString stringWithFormat:@"%ld",(long)[model.rtpActualBitRate integerValue]];
    _packetLostLable.text = [NSString stringWithFormat:@"%ld",(long)[model.frameRate integerValue]];
    
    if([model.mediaType containsString:@"apr"]) {
        _jitterLabel.text =[NSString stringWithFormat:@"%ld(%ld%%)/%ld(%ld%%)",(long)[model.packageLoss integerValue], (long)[model.packageLossRate integerValue], (long)[model.logicPacketLoss integerValue], (long)[model.logicPacketLossRate integerValue]];
    } else {
        _jitterLabel.text =[NSString stringWithFormat:@"%ld(%ld%%)",(long)[model.packageLoss integerValue], (long)[model.packageLossRate integerValue]];
    }
    _errorConcealmentLable.text = [NSString stringWithFormat:@"%ld",(long)[model.jitter integerValue]];
}

- (NSString *)getChannelLabelText:(MediaDetailModel *)model {
    NSString * channelStr = @"";
    if([model.mediaType isEqualToString:@"apr"]) {
        channelStr = @"Audio";
    } else if([model.mediaType isEqualToString:@"aps"]) {
        channelStr = @"Audio↑";
    } else if([model.mediaType isEqualToString:@"vps"]) {
        channelStr = @"Video↑";
    } else if([model.mediaType isEqualToString:@"vpr"]) {
        channelStr = @"Video";
    } else if([model.mediaType isEqualToString:@"vcs"]) {
        channelStr = @"Content↑";
    } else if([model.mediaType isEqualToString:@"vcr"]) {
        channelStr = @"Content";
    }
    return channelStr;
}


- (void)configStaticTagTypeCell {
    [self.participantLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(8);
        make.width.equalTo(self.mas_width).dividedBy(7);//
        make.height.mas_equalTo(ItemHeight);
    }];
    
    [self.channelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.participantLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(7);//
        make.height.mas_equalTo(ItemHeight);
    }];

    [self.formatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.channelLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(7);//
        make.height.mas_equalTo(ItemHeight);
    }];
    
    [self.rateUsedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.formatLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(7);//
        make.height.mas_equalTo(ItemHeight);
    }];
    
    [self.packetLostLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.rateUsedLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(7);//
        make.height.mas_equalTo(ItemHeight);
    }];
    
    [self.jitterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.packetLostLable.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(7);//
        make.height.mas_equalTo(ItemHeight);
    }];
    
    [self.errorConcealmentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.jitterLabel.mas_right);
        make.width.equalTo(self.mas_width).dividedBy(8);//
        make.height.mas_equalTo(ItemHeight);
    }];
    
}

- (UILabel *)participantLabel {
    if(!_participantLabel) {
        _participantLabel = [[UILabel alloc] init];
        _participantLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _participantLabel.textColor = KTextColor666666;
        _participantLabel.text = @"remote";
        _participantLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_participantLabel];
    }
    return _participantLabel;
}

- (UILabel *)channelLabel {
    if(!_channelLabel) {
        _channelLabel = [[UILabel alloc] init];
        _channelLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _channelLabel.textColor = KTextColor666666;
        _channelLabel.text = @"ARX";
        _channelLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_channelLabel];
        
    }
    return _channelLabel;
}

- (UILabel *)formatLabel {
    if(!_formatLabel) {
        _formatLabel = [[UILabel alloc] init];
        _formatLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _formatLabel.textColor = KTextColor666666;
        _formatLabel.text = @"—";
        _formatLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_formatLabel];
    }
    return _formatLabel;
}

- (UILabel *)rateUsedLabel {
    if(!_rateUsedLabel) {
        _rateUsedLabel = [[UILabel alloc] init];
        _rateUsedLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _rateUsedLabel.textColor = KTextColor666666;
        _rateUsedLabel.text = @"60";
        _rateUsedLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_rateUsedLabel];
    }
    return _rateUsedLabel;
}

- (UILabel *)packetLostLable {
    if(!_packetLostLable) {
        _packetLostLable = [[UILabel alloc] init];
        _packetLostLable.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _packetLostLable.textColor = KTextColor666666;
        _packetLostLable.text = @"0(0%)";
        _packetLostLable.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_packetLostLable];
    }
    return _packetLostLable;
}

- (UILabel *)jitterLabel {
    if(!_jitterLabel) {
        _jitterLabel = [[UILabel alloc] init];
        _jitterLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _jitterLabel.textColor = KTextColor666666;
        _jitterLabel.text = @"0";
        _jitterLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_jitterLabel];
    }
    return _jitterLabel;
}

- (UILabel *)errorConcealmentLable {
    if(!_errorConcealmentLable) {
        _errorConcealmentLable = [[UILabel alloc] init];
        _errorConcealmentLable.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        _errorConcealmentLable.textColor = KTextColor666666;
        _errorConcealmentLable.text = @"-";
        _errorConcealmentLable.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_errorConcealmentLable];
    }
    return _errorConcealmentLable;
}


@end
