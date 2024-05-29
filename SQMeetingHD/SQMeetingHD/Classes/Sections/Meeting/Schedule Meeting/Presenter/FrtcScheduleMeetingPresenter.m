#import "FrtcScheduleMeetingPresenter.h"
#import "FrtcUserModel.h"
#import "FrtcManagement.h"
#import "YYModel.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcScheduleDetailModel.h"
#import "FrtcScheduleMeetingModel.h"

#define kSection0 0
#define kSection1 1
#define kSection2 2
#define kSection3 3
#define kSection4 4
#define kSection5 5

@interface FrtcScheduleMeetingPresenter ()
{
    BOOL openPassword;
    BOOL isPersonalMeetingNumber;
}

@property(nonatomic, weak) id scheduleMeetingView;

@property (nonatomic, strong) NSMutableArray<NSArray<FrtcScheduleMeetingModel *> *> *scheduleListData;

@end

@implementation FrtcScheduleMeetingPresenter

- (void)bindView:(id<FrtcScheduleMeetingProtocol>)view {
    _scheduleMeetingView = view;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)loadLocalScheduleMeetingListDataWithDetailModel:(FrtcScheduleDetailModel * _Nullable)model {
    
    isPersonalMeetingNumber = NO;
    
    NSString *displayName = [FrtcUserModel fetchUserInfo].real_name;
    NSString *meetingName = [NSString stringWithFormat:@"%@%@",displayName,NSLocalizedString(@"nor_meeting", nil)];
    NSString *meetingStartTime = [FrtcHelpers timeStampConversionNSString:f_nextTimeNodeTimestampMilliseconds(@"")];
    NSString *meetingEndTime = [NSString stringWithFormat:@"30 %@",NSLocalizedString(@"minute", nil)];
    
    NSString *inviteUsers = [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"people", nil)];
    NSString *rate = @"2048K";
    NSString *recurrenceDetail = FLocalized(@"recurrence_no", nil);
    
    BOOL muteStatuc = NO;
    BOOL guestIn = YES;
    BOOL watermark = NO;
    NSString *joiningTime = [NSString stringWithFormat:@"30 %@",FLocalized(@"minute", nil)];
    
    if (model) {
        meetingName = model.meeting_name;
        meetingStartTime = model.start_time;
        meetingEndTime = model.meeting_duration;
        recurrenceDetail = model.isRecurrence ? model.recurrenceInterval_result : recurrenceDetail;
        inviteUsers = [NSString stringWithFormat:@"%td %@",model.invited_users_details.count,NSLocalizedString(@"people", nil)];
        rate = model.call_rate_type;
        muteStatuc = model.isMuteEnty ;
        guestIn = model.guest_dial_in;
        watermark = model.watermark;
        isPersonalMeetingNumber = !kStringIsEmpty(model.meeting_room_id);
        joiningTime = (model.time_to_join == -1) ? FLocalized(@"meeting_joining_time", nil) : [NSString stringWithFormat:@"30 %@",FLocalized(@"minute", nil)];
    }
    
    FrtcScheduleMeetingModel *info1 = [self getScheduleListInfoWithTitle:meetingName
                                                            detailStr:@""
                                                             cellType:FScheduleCellTextfiled
                                                           showSwitch:NO
                                                         switchStatus:NO];
    NSArray *list1 = @[info1];
    [self.scheduleListData addObject:list1];
    
    FrtcScheduleMeetingModel *info3 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_start_time", nil)
                                                            detailStr:meetingStartTime
                                                             cellType:FScheduleCellDefault
                                                           showSwitch:NO
                                                         switchStatus:NO];
    
    FrtcScheduleMeetingModel *info4 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_duration", nil)
                                                            detailStr:meetingEndTime
                                                             cellType:FScheduleCellDefault
                                                           showSwitch:NO
                                                         switchStatus:NO];
    
    if (model) {
        info3.timeStamp = model.schedule_start_time;
        info4.timeStamp = model.schedule_end_time;
        NSDateComponents *components = [FrtcHelpers getDateDifferenceWithBeginTimestamp:model.schedule_start_time endTimestamp:model.schedule_end_time];
        info4.times = @[[NSString stringWithFormat:@"%td",components.hour],[NSString stringWithFormat:@"%td",components.minute]];
    }else{
        NSString *dafaultDate = f_nextTimeNodeTimestampMilliseconds(@"");
        info3.timeStamp = dafaultDate;
        info4.times = @[@"0",@"30"];
        info4.timeStamp = [FrtcHelpers getResultDateWith:dafaultDate timeInterval:30];
    }
    
    FrtcScheduleMeetingModel *info5 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_time_zone", nil)
                                                            detailStr:NSLocalizedString(@"meeting_china_time", nil)
                                                             cellType:FScheduleCellDefault
                                                           showSwitch:NO
                                                         switchStatus:NO];
    info5.hideAccessView = YES;
    
    FrtcScheduleMeetingModel *info6 = [self getScheduleListInfoWithTitle:FLocalized(@"recurrence_frequency", nil)
                                                            detailStr:recurrenceDetail
                                                             cellType:FScheduleCellDefault
                                                           showSwitch:NO
                                                         switchStatus:NO];
    
    if (model) {
        info6.edit = YES;
    }else{
        info6.edit = NO;
    }
    
    if (model && model.isRecurrence) {
        
        FRecurrentMeetingResutModel *resultModel = [[FRecurrentMeetingResutModel alloc]init];
        resultModel.recurrent = YES;
        resultModel.recurrentInterval    = [NSString stringWithFormat:@"%td",model.recurrenceInterval];
        resultModel.recurrentDaysOfWeek  = model.recurrenceDaysOfWeek;
        resultModel.recurrentDaysOfMonth = model.recurrenceDaysOfMonth;
        resultModel.recurrentType        = model.recurrence_type;
        resultModel.recurrent_Enum_Type  = model.recurrenceType;
        if (model.meetingTotal_size != 0) {
            NSString *meetingNumberStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingTotalNumber", nil),model.meetingTotal_size];
            resultModel.stopTimeAndMeetingNumber = [NSString stringWithFormat:@"%@ %@",model.recurrenceStopTime_str,meetingNumberStr];
        }else{
            resultModel.stopTimeAndMeetingNumber = model.stopTimeAndMeetingNumber;
        }
        resultModel.recurrentStopTime        = model.recurrenceEndDay;
        resultModel.recurrentTitle           = model.recurrenceInterval_result;
        
        info6.recurrentMeetingResultModel  = resultModel;
        
        FrtcScheduleMeetingModel *info7 = [self getScheduleListInfoWithTitle:FLocalized(@"recurrence_endSeries", nil)
                                                                detailStr:resultModel.stopTimeAndMeetingNumber
                                                                 cellType:FScheduleCellDefault
                                                               showSwitch:NO
                                                             switchStatus:NO];
        NSArray *list2 = @[info3,info4,info5,info6,info7];
        [self.scheduleListData addObject:list2];
    }else{
        NSArray *list2 = @[info3,info4,info5,info6];
        [self.scheduleListData addObject:list2];
    }
    
    FrtcScheduleMeetingModel *info8 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_user_people_number", nil)
                                                            detailStr:@""
                                                             cellType:FScheduleCellNumber
                                                           showSwitch:YES
                                                         switchStatus:NO];
    if (model) {
        info8.edit = YES;
        if (!kStringIsEmpty(model.meeting_room_id)) {
            info8.personalMeetingNumber = model.meeting_number;
            info8.personalMeetingRoomId = model.meeting_room_id;
            info8.switchStatus = YES;
        }
    }else{
        info8.edit = NO;
    }
    
    [self.scheduleListData addObject: @[info8]];
    
    if ((model && kStringIsEmpty(model.meeting_room_id)) || !model) {
        BOOL isPassword = NO;
        if (model && !kStringIsEmpty(model.meeting_password)) {
            isPassword = YES;
        }
        FrtcScheduleMeetingModel *info14 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_password", nil)
                                                                 detailStr:@""
                                                                  cellType:FScheduleCellSwitch
                                                                showSwitch:YES
                                                              switchStatus:isPassword];
        [self.scheduleListData addObject:@[info14]];
    }
    
    FrtcScheduleMeetingModel *info9 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_Invited_users", nil)
                                                            detailStr:inviteUsers
                                                             cellType:FScheduleCellDefault
                                                           showSwitch:NO
                                                         switchStatus:NO];
    if (model) {
        info9.inviteUsers = model.invited_users_details;
    }
    
    FrtcScheduleMeetingModel *info10 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"statistic_rate", nil)
                                                             detailStr:rate
                                                              cellType:FScheduleCellDefault
                                                            showSwitch:NO
                                                          switchStatus:NO];
    
    FrtcScheduleMeetingModel *infoTime = [self getScheduleListInfoWithTitle:FLocalized(@"meeting_early_joining_time", nil)
                                                               detailStr:joiningTime
                                                                cellType:FScheduleCellDefault
                                                              showSwitch:NO
                                                            switchStatus:NO];

    FrtcScheduleMeetingModel *info11 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_join_mute", nil)
                                                             detailStr:@""
                                                              cellType:FScheduleCellSwitch
                                                            showSwitch:YES
                                                          switchStatus:muteStatuc];
    if (model && !kStringIsEmpty(model.meeting_room_id)) {
        NSArray *list4 = @[info9,info11];
        [self.scheduleListData addObject:list4];
    }else {
        FrtcScheduleMeetingModel *info12 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_allow_guest_in", nil)
                                                                 detailStr:@""
                                                                  cellType:FScheduleCellSwitch
                                                                showSwitch:YES
                                                              switchStatus:guestIn];
        
        FrtcScheduleMeetingModel *info13 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_shared_watermark", nil)
                                                                 detailStr:@""
                                                                  cellType:FScheduleCellSwitch
                                                                showSwitch:YES
                                                              switchStatus:watermark];
        
        NSArray *list4 = @[info9,info10,infoTime,info11,info12,info13];
        [self.scheduleListData addObject:list4];
    }
    
    [_scheduleMeetingView responseScheduleMeetingListSuccess:self.scheduleListData errMsg:nil];
}

- (void)changeScheduleMeetingListDataWith:(NSIndexPath *)indexPath content:(NSString *)content {
    FrtcScheduleMeetingModel *model = self.scheduleListData[indexPath.section][indexPath.row];
    if (indexPath.section == kSection0 && indexPath.row == 0) {
        model.title = content;
    } else if (indexPath.section == kSection2 && indexPath.row == 0) {
        model.personalMeetingRoomId = content;
    } else if (indexPath.section == kSection1 && indexPath.row == 0) {
        model.detailTitle = [FrtcHelpers timeStampConversionNSString:content];
        model.timeStamp   = content;
        FrtcScheduleMeetingModel *dateModel = self.scheduleListData[kSection1][1];
        NSString *hh = dateModel.times[0];  NSString *mm = dateModel.times[1];
        NSString *times = [FrtcHelpers getResultDateWith:model.timeStamp timeInterval:([hh intValue]*60 + ([mm intValue]))];
        dateModel.timeStamp = times;
        
        NSArray <FrtcScheduleMeetingModel *> *section1List = (NSArray *)self.scheduleListData[kSection1];
        if (section1List.count == 5) {
            FrtcScheduleMeetingModel *recurrenceModel = self.scheduleListData[kSection1][3];
            FrtcScheduleMeetingModel *stopModel = self.scheduleListData[kSection1][4];
            
            FRecurrenceType recurrentType = recurrenceModel.recurrentMeetingResultModel.recurrent_Enum_Type;
            NSDate *startDate = f_dateFromMilliseconds(content);
            NSString *interval = recurrenceModel.recurrentMeetingResultModel.recurrentInterval;
            NSDate *resultDateForCycle;
            
            if (recurrentType == FRecurrenceDay) {
                resultDateForCycle = f_calculateEndDate(startDate, NSCalendarUnitDay, [interval integerValue], kDafaultRecurrenceNumber);
            }else if (recurrentType == FRecurrenceWeek) {
                resultDateForCycle = f_calculateEndDate(startDate, NSCalendarUnitWeekOfYear, [interval integerValue], kDafaultRecurrenceNumber);
            }else if (recurrentType == FRecurrenceMonth) {
                resultDateForCycle = f_calculateEndDate(startDate, NSCalendarUnitMonth, [interval integerValue], kDafaultRecurrenceNumber);
            }
            
            NSString *stopDateMill = f_millisecondsFromDate(resultDateForCycle);
            recurrenceModel.recurrentMeetingResultModel.recurrentStopTime = stopDateMill;
            
            NSInteger meetingNumber = 0 ;
            if (recurrentType == FRecurrenceDay) {
                meetingNumber = f_calculateMeetingCountWithStartDate(content, stopDateMill, [interval integerValue], NSCalendarUnitDay);
            }else if (recurrentType == FRecurrenceWeek) {
                meetingNumber = f_calculateMeetingCountWithStartDate(content, stopDateMill, [interval integerValue], NSCalendarUnitWeekOfYear);
                NSMutableArray *oldRecurrenceWeekList = recurrenceModel.recurrentMeetingResultModel.recurrentDaysOfWeek.mutableCopy;
                NSString *startWeek = f_dayOfWeekForMilliseconds(content);
                NSArray *serviceWeeks = f_convertToNumber(@[startWeek]);
                if (oldRecurrenceWeekList.count == 1) {
                    [oldRecurrenceWeekList removeAllObjects];
                    [oldRecurrenceWeekList addObjectsFromArray:serviceWeeks];
                }
                if (oldRecurrenceWeekList.count > 1) {
                    meetingNumber = meetingNumber * oldRecurrenceWeekList.count;
                }
                recurrenceModel.recurrentMeetingResultModel.recurrentDaysOfWeek = oldRecurrenceWeekList;
            }else if (recurrentType == FRecurrenceMonth) {
                meetingNumber = f_calculateMeetingCountWithStartDate(content, stopDateMill, [interval integerValue], NSCalendarUnitMonth);
                NSMutableArray *oldRecurrenceMonthList = recurrenceModel.recurrentMeetingResultModel.recurrentDaysOfMonth.mutableCopy;
                NSString *starDay = f_dayOfDayForMilliseconds(content);
                if (oldRecurrenceMonthList.count == 1) {
                    [oldRecurrenceMonthList removeAllObjects];
                    [oldRecurrenceMonthList addObject:starDay];
                }
                if (oldRecurrenceMonthList.count > 1) {
                    meetingNumber = meetingNumber * oldRecurrenceMonthList.count;
                }
                recurrenceModel.recurrentMeetingResultModel.recurrentDaysOfMonth = oldRecurrenceMonthList;
            }
            
            NSString *stopDateStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingStopTime", nil),[FrtcHelpers getDateCustomStringWithTimeStr:stopDateMill]];
            NSString *meetingNumberStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingTotalNumber", nil),meetingNumber];
            stopModel.detailTitle = [NSString stringWithFormat:@"%@ %@",stopDateStr,meetingNumberStr];
            
        }
        
    } else if (indexPath.section == kSection1 && indexPath.row == 1) {
        FrtcScheduleMeetingModel *dateModel = self.scheduleListData[kSection1][0];
        NSArray *times = [content componentsSeparatedByString:@","];
        model.times = times;
        NSString *hh = times[0];  NSString *mm = times[1];
        if (!kStringIsEmpty(hh) && !kStringIsEmpty(mm)) {
            model.detailTitle = [NSString stringWithFormat:@"%@ %@ %@ %@",hh,NSLocalizedString(@"hour", nil),mm,NSLocalizedString(@"minute", nil)];
        }else if (!kStringIsEmpty(hh) && kStringIsEmpty(mm)) {
            model.detailTitle = [NSString stringWithFormat:@"%@ %@",hh,NSLocalizedString(@"hour", nil)];
        }else {
            model.detailTitle = [NSString stringWithFormat:@"%@ %@",mm,NSLocalizedString(@"minute", nil)];
        }
        model.timeStamp = [FrtcHelpers getResultDateWith:dateModel.timeStamp timeInterval:([hh intValue]*60 + ([mm intValue]))];
    }
    else{
        model.detailTitle = content;
    }
    [_scheduleMeetingView responseScheduleMeetingListSuccess:self.scheduleListData errMsg:nil];
}

- (void)changeScheduleMeetingListCustomInfo:(NSIndexPath *)indexPath customInfo:(id)customInfo {
    FrtcScheduleMeetingModel *model = self.scheduleListData[indexPath.section][indexPath.row];
    NSInteger section = self->isPersonalMeetingNumber ? kSection3 : kSection4;
    if (indexPath.section == kSection1 && indexPath.row == 3) {
        if ([customInfo isKindOfClass:[FRecurrentMeetingResutModel class]]) {
            
            FRecurrentMeetingResutModel *recultModel = (FRecurrentMeetingResutModel *)customInfo;
            FrtcScheduleMeetingModel *recurrentModel = self.scheduleListData[kSection1][3];
            recurrentModel.recurrentMeetingResultModel = recultModel;
            recurrentModel.detailTitle = recultModel.recurrentTitle;
            recurrentModel.recurrence_type = recultModel.recurrentType;
            
            if (recurrentModel.recurrentMeetingResultModel.isRecurrent) {
                NSMutableArray *list = [self.scheduleListData[kSection1] mutableCopy];
                
                if (list.count == 5) {
                    FrtcScheduleMeetingModel *stopModel = self.scheduleListData[kSection1][4];
                    stopModel.detailTitle = recultModel.stopTimeAndMeetingNumber;
                }
                
                if (list.count == 4) {
                    ISMLog(@"recultModel.stopTimeAndMeetingNumber = %@",recultModel.stopTimeAndMeetingNumber);
                    FrtcScheduleMeetingModel *info7 = [self getScheduleListInfoWithTitle:FLocalized(@"recurrence_endSeries", nil)
                                                                            detailStr:recultModel.stopTimeAndMeetingNumber
                                                                             cellType:FScheduleCellDefault
                                                                           showSwitch:NO
                                                                         switchStatus:NO];
                    [list addObject:info7];
                    [self.scheduleListData replaceObjectAtIndex:kSection1 withObject:list];
                }
            }else{
                FrtcScheduleMeetingModel *dateModel = self.scheduleListData[kSection1][3];
                dateModel.detailTitle = FLocalized(@"recurrence_no", nil);;
                NSMutableArray *list = [self.scheduleListData[kSection1] mutableCopy];
                if (list.count == 5) {
                    [list removeLastObject];
                    [self.scheduleListData replaceObjectAtIndex:kSection1 withObject:list];
                }
            }
        }
    } else if (indexPath.section == kSection2 && indexPath.row == 0) {
        if ([customInfo isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)customInfo;
            model.personalMeetingRoomId = dict[@"roomid"];
            model.personalMeetingNumber = dict[@"number"];
        }
    } else if (indexPath.section == section && indexPath.row == 0) {
        if ([customInfo isKindOfClass:[NSArray class]]) {
            NSArray *users = (NSArray *)customInfo;
            if (users.count > 0) {
                model.inviteUsers = users;
                model.detailTitle = [NSString stringWithFormat:@"%td %@",model.inviteUsers.count,NSLocalizedString(@"people", nil)];
            }else{
                model.inviteUsers = @[];
                model.detailTitle = [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"people", nil)];
            }
        }
    }
    [_scheduleMeetingView responseScheduleMeetingListSuccess:self.scheduleListData errMsg:nil];
}

- (void)changeScheduleMeetingListSwitchStatusWith:(NSIndexPath *)indexPath status:(BOOL)status {
    FrtcScheduleMeetingModel *model = self.scheduleListData[indexPath.section][indexPath.row];
    if (indexPath.section == kSection4 && indexPath.row == 4) {
        FrtcScheduleMeetingModel *dateModel = self.scheduleListData[kSection4][5];
        if (dateModel.isSwitchStatus && status) {
            dateModel.switchStatus = !status;
        }
    }else if (indexPath.section == kSection4 && indexPath.row == 5) {
        FrtcScheduleMeetingModel *dateModel = self.scheduleListData[kSection4][4];
        if (dateModel.isSwitchStatus && status) {
            dateModel.switchStatus = !status;
        }
    }else if (indexPath.section == kSection2 && indexPath.row == 0) {
        if (status) {
            NSMutableArray *list = [self.scheduleListData[kSection4] mutableCopy];
            [list removeObjectAtIndex:1];
            [list removeObjectAtIndex:1];
            [list removeLastObject];
            [list removeLastObject];
            [self.scheduleListData replaceObjectAtIndex:kSection4 withObject:list];
            FrtcScheduleMeetingModel *meetingModel = self.scheduleListData[3][0];
            self->openPassword = meetingModel.switchStatus;
            [self.scheduleListData removeObjectAtIndex:kSection3];
            self->isPersonalMeetingNumber = YES;
        }else {
            if (self.scheduleListData.count == 4 && self.scheduleListData[kSection3].count > 3) {
                return;
            }
            if (self.scheduleListData.count == 5) {
                if (self.scheduleListData[kSection4].count > 3) {
                    return;
                }
            }
            self->isPersonalMeetingNumber = NO;
            FrtcScheduleMeetingModel *info14 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_password", nil)
                                                                     detailStr:@""
                                                                      cellType:FScheduleCellSwitch
                                                                    showSwitch:YES
                                                                  switchStatus:self->openPassword];
            [self.scheduleListData insertObject:@[info14] atIndex:kSection3];
            
            NSString *rate = @"2048K";
            FrtcScheduleMeetingModel *info10 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"statistic_rate", nil)
                                                                     detailStr:rate cellType:FScheduleCellDefault
                                                                    showSwitch:NO
                                                                  switchStatus:NO];
            FrtcScheduleMeetingModel *infoTime = [self getScheduleListInfoWithTitle:FLocalized(@"meeting_early_joining_time", nil)
                                                                       detailStr:[NSString stringWithFormat:@"30 %@",FLocalized(@"minute", nil)]
                                                                        cellType:FScheduleCellDefault
                                                                      showSwitch:NO
                                                                    switchStatus:NO];

            FrtcScheduleMeetingModel *info12 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_allow_guest_in", nil)
                                                                     detailStr:@""
                                                                      cellType:FScheduleCellSwitch
                                                                    showSwitch:YES
                                                                  switchStatus:YES];
            FrtcScheduleMeetingModel *info13 = [self getScheduleListInfoWithTitle:NSLocalizedString(@"meeting_shared_watermark", nil)
                                                                     detailStr:@""
                                                                      cellType:FScheduleCellSwitch
                                                                    showSwitch:YES
                                                                  switchStatus:NO];
            NSMutableArray *list = [self.scheduleListData[kSection4] mutableCopy];
            [list insertObject:info10 atIndex:1];
            [list insertObject:infoTime atIndex:2];
            [list addObject:info12];
            [list addObject:info13];
            [self.scheduleListData replaceObjectAtIndex:kSection4 withObject:list];
        }
    }
    model.switchStatus = status;
    [_scheduleMeetingView responseScheduleMeetingListSuccess:self.scheduleListData errMsg:nil];
}

- (void)addLocalScheduleListDataWith:(NSIndexPath *)indexPath {
    NSMutableArray *mList = [self.scheduleListData[indexPath.section] mutableCopy];
    FrtcScheduleMeetingModel *info = [self getScheduleListInfoWithTitle:@"哈哈哈" detailStr:@"嘿嘿嘿" cellType:FScheduleCellDefault  showSwitch:NO switchStatus:NO];
    [mList addObject:info];
    [self.scheduleListData replaceObjectAtIndex:indexPath.section withObject:mList];
    [_scheduleMeetingView responseScheduleMeetingListSuccess:self.scheduleListData errMsg:nil];
}

- (FrtcScheduleMeetingModel *)getScheduleListInfoWithTitle:(NSString *)title detailStr:(NSString *)detailStr cellType:(FScheduleCellType)cellType showSwitch:(BOOL)showSwitch switchStatus:(BOOL)status{
    FrtcScheduleMeetingModel *info = [FrtcScheduleMeetingModel new];
    info.title = title;
    info.detailTitle = detailStr;
    info.cellType = cellType;
    info.showSwitch = showSwitch;
    info.switchStatus = status;
    return info;
}

- (void)requestCreateNonRecurrenceMeeting {
    [self createScheduledMeetingWithEdit:NO info:nil];
}

- (void)requestUpdateNonRecurrenceMeetingWithModel:(FrtcScheduleDetailModel *)model {
    [self createScheduledMeetingWithEdit:YES info:model];
}

- (void)createScheduledMeetingWithEdit:(BOOL)isEdit info:(FrtcScheduleDetailModel *)info {
    
    NSString *meetingName = self.scheduleListData[kSection0][0].title;
    
    if (kStringIsEmpty(meetingName)) {
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_title_noEmpty", nil)];
        return;
    }
    NSString *startTime = self.scheduleListData[kSection1][0].timeStamp;
    
    if (!isEdit) {
        NSString *currentTime = [FrtcHelpers currentTimeStr];
        NSDateComponents *components = [FrtcHelpers getDateDifferenceWithBeginTimestamp:startTime endTimestamp:currentTime];
        if (components.minute > 1) {
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_start_end_time", nil)];
            return;
        }
    }
    
    NSString *endTime   = self.scheduleListData[kSection1][1].timeStamp;
    
    BOOL isPersonalNumber = self.scheduleListData[kSection2][0].isSwitchStatus;
    NSInteger currentSection = isPersonalNumber ? kSection3 : kSection4;
    
    NSArray<FInviteUserListInfo *> *users = self.scheduleListData[currentSection][0].inviteUsers;
    NSMutableArray *userids = [NSMutableArray array];
    for (FInviteUserListInfo *info in users) {
        [userids addObject:info.user_id];
    }
    
    NSString *mute = @"DISABLE";
    NSNumber *joiningTime = [NSNumber numberWithInt:30];
    BOOL guestIn = YES;
    BOOL watermark = NO;
    
    if (!isPersonalNumber) {
        NSString *str = self.scheduleListData[currentSection][2].detailTitle;
        if (![str containsString:@"30"]) {
            joiningTime = [NSNumber numberWithInt:-1];
        }
        guestIn = self.scheduleListData[currentSection][4].isSwitchStatus;
        watermark = self.scheduleListData[currentSection][5].isSwitchStatus;
        //joiningTime = self.scheduleListData[currentSection][2].detailTitle;
        mute = self.scheduleListData[currentSection][3].isSwitchStatus ? @"ENABLE" : @"DISABLE";
    }else {
        mute = self.scheduleListData[currentSection][1].isSwitchStatus ? @"ENABLE" : @"DISABLE";
    }
    
    NSDictionary *params = @{
        @"meeting_type":@"reservation",
        @"meeting_name":meetingName,
        @"schedule_start_time":startTime,
        @"schedule_end_time":endTime,
        @"guest_dial_in":[NSNumber numberWithBool:guestIn],
        @"watermark":[NSNumber numberWithBool:watermark],
        @"watermark_type":@"single",
        @"time_to_join":joiningTime
    };
    NSMutableDictionary *meetingParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [meetingParams setObject:mute forKey:@"mute_upon_entry"];
    
    [meetingParams setObject:userids forKey:@"invited_users"];
    
    if (isPersonalNumber) {
        NSString *personalNumber = self.scheduleListData[kSection2][0].personalMeetingRoomId;
        [meetingParams setObject:personalNumber forKey:@"meeting_room_id"];
    }else {
        
        NSString *rate = self.scheduleListData[currentSection][1].detailTitle;
        [meetingParams setObject:rate forKey:@"call_rate_type"];
        BOOL isPassword = self.scheduleListData[kSection3][0].isSwitchStatus;
        [meetingParams setObject:isPassword ? [NSNull null] : @"" forKey:@"meeting_password"];
    }
    
    if (isEdit) {
        
        if (!isPersonalNumber) {
            BOOL isPassword = self.scheduleListData[kSection3][0].isSwitchStatus;
            if (!kStringIsEmpty(info.meeting_password) && isPassword) {
                [meetingParams setObject:info.meeting_password forKey:@"meeting_password"];
            }
            
            if (kStringIsEmpty(info.meeting_password) && isPassword){
                int arcNumber= arc4random() % 100000;
                NSString *arcpassword = [NSString stringWithFormat:@"%06d", arcNumber];
                [meetingParams setObject:arcpassword forKey:@"meeting_password"];
            }
        }
        
        FrtcScheduleMeetingModel *recurrentModel = self.scheduleListData[kSection1][3];
        BOOL isRecurrent = recurrentModel.recurrentMeetingResultModel.isRecurrent;
        if (isRecurrent) {
            [self configRecurrenceMeetingData:meetingParams info:info isEdit:YES];
        }else{
            [self updateScheduledMeetingWithParams:meetingParams info:info];
        }
    }else {
        FrtcScheduleMeetingModel *recurrentModel = self.scheduleListData[kSection1][3];
        BOOL isRecurrent = recurrentModel.recurrentMeetingResultModel.isRecurrent;
        if (isRecurrent) {
            [self configRecurrenceMeetingData:meetingParams info:nil isEdit:NO];
        }else{
            [self createScheduledMeetingWithParams:meetingParams];
        }
    }
    
}

- (void)configRecurrenceMeetingData:(NSDictionary *)params info:(FrtcScheduleDetailModel *)info isEdit:(BOOL)isEdit {
    FrtcScheduleMeetingModel *recurrentModel = self.scheduleListData[kSection1][3];
    FRecurrentMeetingResutModel *resultModel = recurrentModel.recurrentMeetingResultModel;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict setObject:@"recurrence" forKey:@"meeting_type"];
    [dict setObject:resultModel.recurrentType forKey:@"recurrence_type"];
    [dict setObject:resultModel.recurrentInterval forKey:@"recurrenceInterval"];
    
    if (resultModel.recurrent_Enum_Type == FRecurrenceWeek) {
        [dict setObject:resultModel.recurrentDaysOfWeek forKey:@"recurrenceDaysOfWeek"];
    }else if (resultModel.recurrent_Enum_Type == FRecurrenceMonth) {
        [dict setObject:resultModel.recurrentDaysOfMonth forKey:@"recurrenceDaysOfMonth"];
    }
    
    [dict setObject:params[@"schedule_start_time"] forKey:@"recurrenceStartTime"];
    [dict setObject:params[@"schedule_end_time"]   forKey:@"recurrenceEndTime"];
    [dict setObject:params[@"schedule_start_time"] forKey:@"recurrenceStartDay"];
    [dict setObject:resultModel.recurrentStopTime forKey:@"recurrenceEndDay"];
    
    if (isEdit) {
        [self updateRecurrenceMeetngWithParams:dict info:info];
    }else{
        [self createRecurrentMetting:dict];
    }
}

- (void)createScheduledMeetingWithParams:(NSDictionary *)params {
    //[MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] createMeeting:[FrtcUserModel fetchUserInfo].user_token
                                   withMeetingParams:params
                                   completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [MBProgressHUD hideHUD];
        FrtcScheduleDetailModel *model = [FrtcScheduleDetailModel yy_modelWithDictionary:meetingInfo];
        [self.scheduleMeetingView responseScheduleMeetingSuccess:model errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [self.scheduleMeetingView responseScheduleMeetingSuccess:nil errMsg:NSLocalizedString(@"meeting_orderError", nil)];
    }];
}

- (void)createRecurrentMetting:(NSDictionary *)params {
    //[MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] createRecurrentMeeting:[FrtcUserModel fetchUserInfo].user_token
                                            withMeetingParams:params
                                            completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [MBProgressHUD hideHUD];
        FrtcScheduleDetailModel *model = [FrtcScheduleDetailModel yy_modelWithDictionary:meetingInfo];
        [self.scheduleMeetingView responseScheduleMeetingSuccess:model errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        NSDictionary *erroInfo = error.userInfo;
        NSData *data = [erroInfo valueForKey:kRequestErrorDataKey];
        NSString *errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [MBProgressHUD hideHUD];
        [self.scheduleMeetingView responseScheduleMeetingSuccess:nil errMsg:NSLocalizedString(@"meeting_orderError", nil)];
    }];
}

- (void)updateScheduledMeetingWithParams:(NSDictionary *)params info:(FrtcScheduleDetailModel *)info {
    //[MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] updateScheduleMeeting:[FrtcUserModel fetchUserInfo].user_token
                                           withReservationID:info.reservation_id
                                           withMeetingParams:params
                                           completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [MBProgressHUD hideHUD];
        FrtcScheduleDetailModel *model = [FrtcScheduleDetailModel yy_modelWithDictionary:meetingInfo];
        [self.scheduleMeetingView responseupdateNonRecurrenceMeeting:model errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [self.scheduleMeetingView responseupdateNonRecurrenceMeeting:nil errMsg:NSLocalizedString(@"meeting_updateError", nil)];
    }];
}

- (void)updateRecurrenceMeetngWithParams:(NSDictionary *)params info:(FrtcScheduleDetailModel *)info {
    //[MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] updateRecurrenceMeeting:[FrtcUserModel fetchUserInfo].user_token
                                             withMeetingParams:params
                                                 reservationId:info.reservation_id
                                             completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [MBProgressHUD hideHUD];
        FrtcScheduleDetailModel *model = [FrtcScheduleDetailModel yy_modelWithDictionary:meetingInfo];
        [self.scheduleMeetingView responseupdateNonRecurrenceMeeting:model errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [self.scheduleMeetingView responseupdateNonRecurrenceMeeting:nil errMsg:NSLocalizedString(@"meeting_updateError", nil)];
    }];
}

- (void)requestUserListDataWithPage:(NSInteger)pageNum filter:(NSString *)filter {
    [[FrtcManagement sharedManagement] getUserList:[FrtcUserModel fetchUserInfo].user_token
                                          withPage:pageNum withFilter:filter
                                 completionHandler:^(NSDictionary * _Nonnull allUserListInfo) {
        FrtcInviteUserModel *model = [FrtcInviteUserModel yy_modelWithDictionary:allUserListInfo];
        [self.scheduleMeetingView responseInviteUserListData:model errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [self.scheduleMeetingView responseInviteUserListData:nil errMsg:error.localizedDescription];
    }];
}

- (void)getRateListDataWithRate:(NSString *)rate {
    NSArray *rateList = @[@"128K",@"512K",@"1024K",@"2048K",@"2560K",@"3072K",@"4096K"];
    if ([FrtcUserModel fetchUserInfo].isSystemAdmin || [FrtcUserModel fetchUserInfo].isMeetingOperator) {
        rateList = @[@"128K",@"512K",@"1024K",@"2048K",@"2560K",@"3072K",@"4096K",@"6144K",@"8192K"];
    }
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:10];
    for (NSString *rateStr in rateList) {
        FrtcScheduleCustomModel * model = [FrtcScheduleCustomModel new];
        model.title = rateStr;
        if ([rateStr isEqualToString:rate]) {
            model.isSelect = YES;
        }
        [resultList addObject:model];
    }
    [_scheduleMeetingView responseRateListData:resultList];
}

- (void)getJoiningTimeDataWithTime:(NSString *)selectTime {
    NSArray *timeList = @[[NSString stringWithFormat:@"30 %@",FLocalized(@"minute", nil)] , FLocalized(@"meeting_joining_time", nil)];
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:2];
    for (NSString *timeStr in timeList) {
        FrtcScheduleCustomModel * model = [FrtcScheduleCustomModel new];
        model.title = timeStr;
        if ([timeStr containsString:selectTime]) {
            model.isSelect = YES;
        }
        [resultList addObject:model];
    }
    [_scheduleMeetingView responseJoiningTimeListData:resultList];
}

#pragma mark - lazy

- (NSMutableArray *) scheduleListData {
    if (!_scheduleListData) {
        _scheduleListData = [NSMutableArray arrayWithCapacity:8];
    }
    return _scheduleListData;
}


@end

