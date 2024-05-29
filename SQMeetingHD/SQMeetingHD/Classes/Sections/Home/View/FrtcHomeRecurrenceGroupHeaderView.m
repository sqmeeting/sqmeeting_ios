#import "FrtcHomeRecurrenceGroupHeaderView.h"
#import "Masonry.h"
#import "FrtcHelpers.h"
#import "FrtcMeetingRecurrenceDateManager.h"
#import "UILabel+LineSpacing.h"

@interface FrtcHomeRecurrenceGroupHeaderView ()

@property (nonatomic, strong) UILabel *meetingNameLabel;
@property (nonatomic, strong) UILabel *meetingDetailLabel;

@end

@implementation FrtcHomeRecurrenceGroupHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = KBGColor;
        
        [self addSubview:self.meetingNameLabel];
        [self.meetingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.mas_equalTo(60);
        }];
        
        [self addSubview:self.meetingDetailLabel];
        [self.meetingDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.meetingNameLabel.mas_bottom).mas_offset(15);
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.height.mas_equalTo(25);
        }];
        
        [self addSubview:self.meetingStopTimeLabel];
        [self.meetingStopTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.meetingDetailLabel.mas_bottom).mas_offset(0);
            make.bottom.mas_equalTo(-15);
            make.left.mas_equalTo(KLeftSpacing);
            //make.right.mas_equalTo(-KLeftSpacing);
            make.height.mas_equalTo(25);
        }];

        
        UIView *lineLayer = [[UIView alloc]init];
        lineLayer.backgroundColor = KLineColor;
        [self addSubview:lineLayer];
        [lineLayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
    }
    return self;
}

- (void)setDetailModel:(FrtcScheduleDetailModel *)detailModel {
    _detailModel = detailModel;
    self.meetingNameLabel.text = _detailModel.meeting_name;

    NSString *interval = [NSString stringWithFormat:@"%td",detailModel.recurrenceInterval];
    NSString *interval_result = detailModel.recurrenceInterval_result;
    NSString *recurrenceInfo = @"";

    if (detailModel.recurrenceType == FRecurrenceDay) {
        recurrenceInfo = f_daysDateResultWithInterval(interval);
    }else if (detailModel.recurrenceType == FRecurrenceWeek) {
        recurrenceInfo = f_weekDateResultWithInterval(interval, f_convertToChineseWeekday(detailModel.recurrenceDaysOfWeek));
    }else if (detailModel.recurrenceType == FRecurrenceMonth){
        recurrenceInfo = f_monthDateResultWithInterval(interval, detailModel.recurrenceDaysOfMonth);
    }
    
    NSString *recurrenecStr = [NSString stringWithFormat:@"%@ %@",interval_result,recurrenceInfo];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:recurrenecStr];
    [str addAttribute:NSForegroundColorAttributeName value:KRecurrenceColor range:NSMakeRange(0,interval_result.length)];

    self.meetingDetailLabel.attributedText = str;
    self.meetingStopTimeLabel.text = detailModel.recurrenceStopTime_str;
}

#pragma mark - lazy

- (UILabel *)meetingNameLabel {
    if (!_meetingNameLabel) {
        _meetingNameLabel = [[UILabel alloc]init];
        _meetingNameLabel.textColor = KTextColor;
        _meetingNameLabel.text = @"";
        _meetingNameLabel.textAlignment = NSTextAlignmentCenter;
        _meetingNameLabel.backgroundColor = UIColor.whiteColor;
        _meetingNameLabel.font = [UIFont boldSystemFontOfSize:26];
    }
    return _meetingNameLabel;
}

- (UILabel *)meetingDetailLabel {
    if (!_meetingDetailLabel) {
        _meetingDetailLabel = [[UILabel alloc]init];
        _meetingDetailLabel.textColor = KTextColor;
        _meetingDetailLabel.numberOfLines = 3;
        _meetingDetailLabel.text = @"";
        _meetingDetailLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _meetingDetailLabel;
}

- (UILabel *)meetingStopTimeLabel {
    if (!_meetingStopTimeLabel) {
        _meetingStopTimeLabel = [[UILabel alloc]init];
        _meetingStopTimeLabel.textColor = KTextColor;
        _meetingStopTimeLabel.text = @"";
        _meetingStopTimeLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _meetingStopTimeLabel;
}

@end
