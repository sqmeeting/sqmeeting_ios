#import "FrtcChangeOneRecurrenceViewController.h"
#import "Masonry.h"
#import "FrtcOneRecurrenceView.h"
#import "FrtcScheduleDatePickerView.h"
#import "FrtcScheduleTimePickerView.h"
#import "UIImage+Extensions.h"
#import "FrtcManagement.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcUserModel.h"
#import "NSBundle+FLanguage.h"
#import "FrtcScheduleListPresenter.h"

//打工人深夜加班,双眼已成一条直线,怎么快怎么来了 ~

@interface FrtcChangeOneRecurrenceViewController ()

{
    NSString *_tempStartTimeStamp;
    NSString *_tempEndTimeStamp;
    NSInteger _tempHout;
    NSInteger _tempMinute;
    
    NSString *_minDate; //开始时间最早的时间,不能早于上一次周期会议的结束时间.第一次的会议不能早于当前时间
    NSString *_maxDate; //结束时间最晚的时间,不能晚于下一次周期会议的开始时间.最后一次的会议不能晚于周期会议的结束时间.

}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *stopLabel;
@property (nonatomic, strong) UIButton *reserveButton;
@property (nonatomic, strong) FrtcOneRecurrenceView *startView;
@property (nonatomic, strong) FrtcOneRecurrenceView *timerView;

@end

@implementation FrtcChangeOneRecurrenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"修改会议预约";
    self->_tempStartTimeStamp = self.detailInfo.schedule_start_time;
    self->_tempEndTimeStamp = self.detailInfo.schedule_end_time;
    
    NSDateComponents *components = [FrtcHelpers getDateDifferenceWithBeginTimestamp:_tempStartTimeStamp endTimestamp:_tempEndTimeStamp];
    if (components.hour != 0  && components.minute != 0) {
        _tempHout = components.hour;
        _tempMinute = components.minute;
    }else if (components.hour != 0 && components.minute == 0) {
        _tempHout = components.hour;
    }else {
        _tempMinute = components.minute;
    }
    
    _minDate = self.detailInfo.schedule_start_time;
    _maxDate = self.detailInfo.schedule_end_time;
    
    @WeakObj(self)
    f_requestDetailDataWithId(self.detailInfo.reservation_id, ^(FrtcScheduleDetailModel * _Nonnull detailInfo, NSString * _Nonnull errorMsg) {
        @StrongObj(self)
        self.detailInfo = detailInfo;
        self.stopLabel.attributedText = [self getMeetingTime:detailInfo];
    });
    
    [self changeMeetingInfo];
}

#pragma mark - action

- (NSMutableAttributedString *)getMeetingTime:(FrtcScheduleDetailModel *)info {
    NSString * showStr = @"";
    if ([NSBundle isLanguageEn] ) {
        showStr = [NSString stringWithFormat:@"%@  End %@",info.recurrenceInterval_result,info.stopTimeAndMeetingNumber];
    }else{
        showStr = [NSString stringWithFormat:@"%@  %@",info.recurrenceInterval_result,info.stopTimeAndMeetingNumber];
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:showStr];
    [str addAttribute:NSForegroundColorAttributeName value:KRecurrenceColor range:NSMakeRange(0,info.recurrenceInterval_result.length)];
    return str;
}

#pragma mark - pro Data

- (void)changeMeetingInfo {
    NSArray *groupList = _groupMeetingList;
    if (groupList.count < 2) { return; }
    
    [groupList enumerateObjectsUsingBlock:^(FrtcScheduleDetailModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reservation_id isEqualToString:self.detailInfo.reservation_id]) {
            if (idx == 0) {
                _minDate =  f_nextTimeNodeTimestampMilliseconds(@"");
                FrtcScheduleDetailModel *nextModel = groupList[idx + 1];
                _maxDate = nextModel.schedule_start_time;
                *stop = YES;
            }else if (idx == groupList.count - 1) {
                FrtcScheduleDetailModel *preModel = groupList[idx - 1];
                _minDate = preModel.schedule_end_time;
                _maxDate = self.detailInfo.recurrenceEndDay;
                *stop = YES;
            }else {
                FrtcScheduleDetailModel *preModel = groupList[idx - 1];
                FrtcScheduleDetailModel *nextModel = groupList[idx + 1];
                _minDate = preModel.schedule_end_time;
                _maxDate = nextModel.schedule_start_time;
            }
        }
    }];
}

#pragma mark - UIButton action

- (void)didClickReserveButton:(UIButton *)button {
    [self.view endEditing:YES];
    [self updateScheduledMeeting];
}

- (void)showSelectedStartTimeView {
    @WeakObj(self)
    [FrtcScheduleDatePickerView showDatePickerViewWithMinimumDate:_minDate
                                                       maxDate:_maxDate
                                                   DefaultDate:self->_tempStartTimeStamp
                                                     dateBlock:^(NSString * _Nonnull timeStamp) {
        @StrongObj(self)
        self->_tempStartTimeStamp = timeStamp;
        self->_tempEndTimeStamp = [FrtcHelpers getResultDateWith:timeStamp timeInterval:(self->_tempHout * 60 + (self->_tempMinute))];
        self.startView.detailLabel.text = [FrtcHelpers timeStampConversionNSString:timeStamp];
    }];
}

- (void)showSelectedEndTimeView {
    @WeakObj(self)
    [FrtcScheduleTimePickerView showTimePickerViewWithTimeStr:^(NSString * _Nonnull hh, NSString * _Nonnull mm) {
        @StrongObj(self)
        if (!kStringIsEmpty(hh) && !kStringIsEmpty(mm)) {
            self.timerView.detailLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",hh,NSLocalizedString(@"hour", nil),mm,NSLocalizedString(@"minute", nil)];
        }else if (!kStringIsEmpty(hh) && kStringIsEmpty(mm)) {
            self.timerView.detailLabel.text = [NSString stringWithFormat:@"%@ %@",hh,NSLocalizedString(@"hour", nil)];
        }else {
            self.timerView.detailLabel.text = [NSString stringWithFormat:@"%@ %@",mm,NSLocalizedString(@"minute", nil)];
        }
        self->_tempEndTimeStamp = [FrtcHelpers getResultDateWith:self->_tempStartTimeStamp timeInterval:([hh intValue]*60 + ([mm intValue]))];
    }];
}

#pragma mark - Request

- (void)updateScheduledMeeting {
    
    NSArray<FInviteUserListInfo *> *users = self.detailInfo.invited_users_details;
    NSMutableArray *userids = [NSMutableArray array];
    for (FInviteUserListInfo *info in users) {
        [userids addObject:info.user_id];
    }
    
    NSMutableDictionary *meetingParams = [NSMutableDictionary dictionaryWithCapacity:15];

    NSDate *startDate = f_dateFromMilliseconds(_tempStartTimeStamp);
    NSDate *minDate   = f_dateFromMilliseconds(_minDate);
    NSDate *endDate   = f_dateFromMilliseconds(_tempEndTimeStamp);
    NSDate *maxDate   = f_dateFromMilliseconds(_maxDate);
    NSComparisonResult startResult = [startDate compare:minDate];
    if (startResult == NSOrderedSame || startResult == NSOrderedAscending) {
        [MBProgressHUD showMessage:FLocalized(@"meeting_start_time_message", nil)];
        return;
    }
    
    NSComparisonResult endResult = [endDate compare:maxDate];
    if (endResult == NSOrderedSame || endResult == NSOrderedDescending) {
        [MBProgressHUD showMessage:FLocalized(@"meeting_end_time_message", nil)];
        return;
    }
        
    [meetingParams setObject:self->_tempStartTimeStamp forKey:@"schedule_start_time"];
    [meetingParams setObject:self->_tempEndTimeStamp forKey:@"schedule_end_time"];

    [meetingParams setObject:self.detailInfo.meeting_type forKey:@"meeting_type"];
    [meetingParams setObject:self.detailInfo.meeting_name forKey:@"meeting_name"];
    [meetingParams setObject:[NSNumber numberWithBool:self.detailInfo.guest_dial_in] forKey:@"guest_dial_in"];
    [meetingParams setObject:[NSNumber numberWithBool:self.detailInfo.watermark] forKey:@"watermark"];
    NSString *rate_type = self.detailInfo.call_rate_type;
    if (kStringIsEmpty(rate_type)) {
        rate_type = @"2048K";
    }
    [meetingParams setObject:rate_type forKey:@"call_rate_type"];
    [meetingParams setObject:self.detailInfo.watermark_type forKey:@"watermark_type"];
    [meetingParams setObject:self.detailInfo.mute_upon_entry forKey:@"mute_upon_entry"];
    [meetingParams setObject:userids forKey:@"invited_users"];
    if (!kStringIsEmpty(self.detailInfo.meeting_room_id)) {
        [meetingParams setObject:self.detailInfo.meeting_room_id forKey:@"meeting_room_id"];
    }
    NSString *password = self.detailInfo.meeting_password;
    if (kStringIsEmpty(self.detailInfo.meeting_password)) {
        password = @"";
    }
    [meetingParams setObject:password forKey:@"meeting_password"];
   
    [MBProgressHUD showActivityMessage:@""];
    @WeakObj(self)
    [[FrtcManagement sharedManagement] updateScheduleMeeting:[FrtcUserModel fetchUserInfo].user_token
                                           withReservationID:self.detailInfo.reservation_id
                                           withMeetingParams:meetingParams
                                           completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        @StrongObj(self)
        [MBProgressHUD hideHUD];
        if (self.UpdateDetailMeetingView) {
            self.UpdateDetailMeetingView(@"");
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        NSDictionary *erroInfo = error.userInfo;
        NSData *data = [erroInfo valueForKey:kRequestErrorDataKey];
        NSString *errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [MBProgressHUD showMessage:errorString];
    }];
}

- (void)configUI {
    
    UIView *topView = [[UIView alloc]init];
    topView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(80);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.text = _detailInfo.meeting_name;
    self.titleLabel.textColor = KTextColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.top.mas_equalTo(10);
    }];

    self.stopLabel = [[UILabel alloc]init];
    self.stopLabel.attributedText = [self getMeetingTime:_detailInfo];
    self.stopLabel.numberOfLines = 2;
    self.stopLabel.font = [UIFont systemFontOfSize:13];
    [topView addSubview:self.stopLabel];
    [self.stopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing12);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
    self.startView = [[FrtcOneRecurrenceView alloc]initWithFrame:CGRectZero isRight:YES];
    self.startView.titleLabel.text = FLocalized(@"meeting_start_time", nil);
    self.startView.detailLabel.text = self.detailInfo.start_time;
    @WeakObj(self)
    self.startView.didOneRecurrenceViewBlock = ^{
        @StrongObj(self)
        [self showSelectedStartTimeView];
    };
    
    self.timerView = [[FrtcOneRecurrenceView alloc]initWithFrame:CGRectZero isRight:YES];
    self.timerView.titleLabel.text = FLocalized(@"meeting_duration", nil);
    self.timerView.detailLabel.text = self.detailInfo.meeting_duration;
    self.timerView.didOneRecurrenceViewBlock = ^{
        @StrongObj(self)
        [self showSelectedEndTimeView];
    };
    
    FrtcOneRecurrenceView *timerZoneView = [[FrtcOneRecurrenceView alloc]initWithFrame:CGRectZero isRight:NO];
    timerZoneView.titleLabel.text = FLocalized(@"meeting_time_zone", nil);
    timerZoneView.detailLabel.text = NSLocalizedString(@"meeting_china_time", nil);
    
    [self.contentView addSubview:self.startView];
    [self.contentView addSubview:self.timerView];
    [self.contentView addSubview:timerZoneView];
    
    [self.startView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(topView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(50);
    }];
    
    [self.timerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(self.startView.mas_bottom);
        make.height.equalTo(self.startView);
    }];
    
    [timerZoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(self.timerView.mas_bottom);
        make.height.equalTo(self.startView);
    }];
    
    [self.reserveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(kButtonHeight);
        make.bottom.mas_equalTo(-KSafeAreaBottomHeight-10);
    }];
}

- (UIButton *)reserveButton {
    if(!_reserveButton) {
        _reserveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reserveButton setTitle:FLocalized(@"recurrence_done", nil) forState:UIControlStateNormal];
        [_reserveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reserveButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_reserveButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        _reserveButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_reserveButton addTarget:self action:@selector(didClickReserveButton:) forControlEvents:UIControlEventTouchUpInside];
        _reserveButton.layer.masksToBounds = YES;
        _reserveButton.layer.cornerRadius = KCornerRadius;
        [self.contentView addSubview:_reserveButton];
    }
    
    return _reserveButton;
}

@end
