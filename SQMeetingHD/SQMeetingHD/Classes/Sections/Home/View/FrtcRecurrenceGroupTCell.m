#import "FrtcRecurrenceGroupTCell.h"
#import "UIImage+Extensions.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"

@interface FrtcRecurrenceGroupTCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *statusLabel;

@end


@implementation FrtcRecurrenceGroupTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        UIStackView *topStack = [[UIStackView alloc]init];
        topStack.spacing = 10;
        [self.contentView addSubview:topStack];
        [topStack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.centerY.equalTo(self.contentView);
        }];
        
        [topStack addArrangedSubviews:@[self.titleLabel,self.weekLabel,self.timeLabel,self.statusLabel]];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)setDetailInfo:(FrtcScheduleDetailModel *)detailInfo {
    _detailInfo = detailInfo;
    self.titleLabel.text = [FrtcHelpers getDateCustomStringWithTimeStr:_detailInfo.schedule_start_time];
    self.weekLabel.text = [NSString stringWithFormat:FLocalized(@"recurrence_meetingWeekly", nil),f_dayOfWeekForMilliseconds(_detailInfo.schedule_start_time)];
    self.timeLabel.text = _detailInfo.meeting_timeSlot;
    self.statusLabel.text = kStringIsEmpty(_detailInfo.meeting_statusStr) ? @"" : _detailInfo.meeting_statusStr;
    self.statusLabel.textColor = _detailInfo.isInMeeting ? KRecurrenceColor : UIColor.orangeColor;
    if (_detailInfo.isInMeeting) {
        self.titleLabel.textColor =
        self.weekLabel.textColor =
        self.timeLabel.textColor = kMainColor;
    }else{
        self.titleLabel.textColor = KTextColor;
        self.weekLabel.textColor = KTextColor666666;
        self.timeLabel.textColor = KTextColor666666;
    }
}

#pragma mark - lazy

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = KTextColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UILabel *)weekLabel {
    if (!_weekLabel) {
        _weekLabel = [[UILabel alloc]init];
        _weekLabel.textColor = KTextColor666666;
        _weekLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _weekLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = KTextColor666666;
        _timeLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _timeLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.textColor = KRecurrenceColor;
        _statusLabel.font = [UIFont systemFontOfSize:12.f];
    }
    return _statusLabel;
}

@end
