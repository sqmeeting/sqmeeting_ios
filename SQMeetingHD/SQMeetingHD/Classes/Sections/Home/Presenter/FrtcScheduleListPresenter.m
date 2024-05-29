#import "FrtcScheduleListPresenter.h"
#import <FrtcManagement.h>
#import "YYModel.h"
#import "FrtcUserModel.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcMeetingReminderDataManager.h"
#import "FrtcAuthorizationTool.h"
#import "UIViewController+Extensions.h"
#import "MBProgressHUD+Extensions.h"

@interface FrtcScheduleListPresenter ()

@property (nonatomic, weak) id scheduledView;

@end

@implementation FrtcScheduleListPresenter

- (void)bindView:(id<FrtcScheduleListResultProtocol>)view {
    _scheduledView = view;
}

- (void)dealloc {
    
}

- (void)requestScheduledListDataWithPageNum:(NSInteger)pageNum {
    [[FrtcManagement sharedManagement] getScheduledMeeting:[FrtcUserModel fetchUserInfo].user_token withPage:pageNum getScheduledHandler:^(NSDictionary * _Nonnull scheduledMeetingInfo) {
        FScheduleListDataModel *model = [FScheduleListDataModel yy_modelWithDictionary:scheduledMeetingInfo];
        
        if (FrtcMeetingReminderDataManager.acceptMeetingReminders) {
            [FrtcAuthorizationTool checkNotificationAuthorizationWithCompletion:^(BOOL granted) {
                if (granted){
                    [[FrtcMeetingReminderDataManager sharedInstance] addMeetingInfoToLocalNotifications:model.meeting_schedules];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"MEETING_REMINDER_ALERTTITLE", nil) message:NSLocalizedString(@"MEETING_REMINDER_ALERTCONTENT", nil) buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"MEETING_REMINDER_ALERTGO", nil)] alerAction:^(NSInteger index) {
                            if (index == 1) {
                                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                if([[UIApplication sharedApplication] canOpenURL:url]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                    });
                                }
                            }
                        }];
                    });
                }
            }];
        }
        [self.scheduledView responseScheduledMeetingListData:model errMsg:nil];
    } getScheduledFailure:^(NSError * _Nonnull error) {
        [self.scheduledView responseScheduledMeetingListData:nil errMsg:error.localizedDescription];
    }];
}

- (NSArray *)handleTimeSectionWithData:(NSArray<FrtcScheduleDetailModel *> *)scheduleList {
    __block NSMutableArray<NSDictionary *> *resultList  = [NSMutableArray array];
    __block NSMutableArray * keys = [NSMutableArray arrayWithCapacity:10];
    for (FrtcScheduleDetailModel *info in scheduleList) {
        if ([keys containsObject:info.timeKey]) {
            for (int i = 0 ; i < resultList.count; i ++) {
                NSMutableDictionary *dict = [resultList[i] mutableCopy];
                if ([dict.allKeys[0] isEqualToString:info.timeKey]) {
                    NSMutableArray *list = [[dict objectForKey:info.timeKey] mutableCopy];
                    [list addObject:info];
                    [dict setObject:list forKey:info.timeKey];
                    [resultList replaceObjectAtIndex:i withObject:dict];
                }
            }
        }else {
            [keys addObject:info.timeKey];
            __block NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            __block NSMutableArray *list = [NSMutableArray array];
            [list addObject:info];
            [dict setObject:list forKey:info.timeKey];
            [resultList addObject:dict];
        }
    }
    return resultList;
}

- (void)requestScheduledDetailDataWithId:(NSString *)reservationId {
    
}

- (void)handelDetailDataWithInfo:(FrtcScheduleDetailModel *)info {
    FHomeDetailMeetingInfo * info0 = [self getDetailInfoWithTitle:NSLocalizedString(@"meeting_name", nil) content:info.meeting_name];
    FHomeDetailMeetingInfo * info2 = [self getDetailInfoWithTitle:NSLocalizedString(@"meeting_time", nil) content:info.start_time];
    FHomeDetailMeetingInfo * info3 = [self getDetailInfoWithTitle:NSLocalizedString(@"call_number", nil) content:info.meeting_number];
    FHomeDetailMeetingInfo * info1 = [self getDetailInfoWithTitle:NSLocalizedString(@"MEETING_REMINDER_MEETINGOWNER", nil) content:info.owner_name];
    FHomeDetailMeetingInfo * info4 = [self getDetailInfoWithTitle:NSLocalizedString(@"meeting_duration", nil) content:info.meeting_duration];
    if (!kStringIsEmpty(info.meeting_password)) {
        FHomeDetailMeetingInfo * info5 = [self getDetailInfoWithTitle:NSLocalizedString(@"string_pwd", nil) content:info.meeting_password];
        NSArray *list = @[info0,info2,info3,info1,info4,info5];
        [_scheduledView responseScheduledMeetingDetail:list detailInfo:info errMsg:nil];
    }else{
        NSArray *list = @[info0,info2,info3,info1,info4];
        [_scheduledView responseScheduledMeetingDetail:list detailInfo:info errMsg:nil];
    }
}

- (FHomeDetailMeetingInfo *)getDetailInfoWithTitle:(NSString *)title content:(NSString *)content {
    FHomeDetailMeetingInfo * info = [FHomeDetailMeetingInfo new];
    info.title = title;
    info.content = content;
    return info;
}

- (void)deleteScheduledMeetingWithId:(NSString *)reservationId {
    
    [[FrtcManagement sharedManagement] deleteNonCurrentMeeting:[FrtcUserModel fetchUserInfo].user_token 
                                             withReservationId:reservationId
                                                   deleteGroup:NO
                                       deleteCompletionHandler:^{
        [self.scheduledView responseDeleteMeetingResult:YES errMsg:nil];
    } deleteFailure:^(NSError * _Nonnull error) {
        [self.scheduledView responseDeleteMeetingResult:NO errMsg:error.localizedDescription];
    }];
}

- (void)deleteRecurrenceMeetingWithId:(NSString *)reservationId {
    [[FrtcManagement sharedManagement] deleteNonCurrentMeeting:[FrtcUserModel fetchUserInfo].user_token
                                             withReservationId:reservationId
                                                   deleteGroup:YES
                                       deleteCompletionHandler:^{
        [self.scheduledView responseDeleteMeetingResult:YES errMsg:nil];
    } deleteFailure:^(NSError * _Nonnull error) {
        [self.scheduledView responseDeleteMeetingResult:NO errMsg:error.localizedDescription];
    }] ;
}

void f_deleteScheduledMeetingWithId(NSString *reservationId, void (^resposeResult)(bool result, NSError * _Nonnull error))  {
    [[FrtcManagement sharedManagement] deleteNonCurrentMeeting:[FrtcUserModel fetchUserInfo].user_token
                                             withReservationId:reservationId
                                                   deleteGroup:NO
                                       deleteCompletionHandler:^{
        resposeResult(YES,[NSError new]);
    } deleteFailure:^(NSError * _Nonnull error) {
        resposeResult(NO,error);
    }];
}

- (void)requestDetailDataWithId:(NSString *)reservationId {
    [[FrtcManagement sharedManagement] getScheduleMeetingDetailInformation:[FrtcUserModel fetchUserInfo].user_token withReservationID:reservationId completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        FrtcScheduleDetailModel *info = [FrtcScheduleDetailModel yy_modelWithDictionary:meetingInfo];
        [self handelDetailDataWithInfo:info];
    } failure:^(NSError * _Nonnull error) {
        [self.scheduledView responseScheduledMeetingDetail:nil detailInfo:nil errMsg:error.localizedDescription];
    }];
}

- (void)requestGroupListDataWithGroupId:(NSString *)groupId {
    [[FrtcManagement sharedManagement] getRecurrenceMeetingInGroupByPage:[FrtcUserModel fetchUserInfo].user_token
                                                                 groupId:groupId
                                                       withMeetingParams:@{@"page_num":@"1",@"page_size":@"10"}
                                                       completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        FScheduleListDataModel *model = [FScheduleListDataModel yy_modelWithDictionary:meetingInfo];
        [self.scheduledView responseGroupListDetail:model errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [self.scheduledView responseGroupListDetail:nil errMsg:error.localizedDescription];
    }];
}

void f_requestDetailDataWithId(NSString *reservationId, void (^ResponseResult)(FrtcScheduleDetailModel *detailInfo, NSString *errorMsg)) {
    [[FrtcManagement sharedManagement] getScheduleMeetingDetailInformation:[FrtcUserModel fetchUserInfo].user_token
                                                         withReservationID:reservationId
                                                         completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        FrtcScheduleDetailModel *info = [FrtcScheduleDetailModel yy_modelWithDictionary:meetingInfo];
        ResponseResult(info,@"");
    } failure:^(NSError * _Nonnull error) {
        ResponseResult(nil,error.localizedDescription);
    }];
}

- (void)removeMeetingFromHomeList:(NSString *)identifier {
    [[FrtcManagement sharedManagement] removeMeetingFromMyMeetingList:[FrtcUserModel fetchUserInfo].user_token
                                                           identifier:identifier
                                                    completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [self.scheduledView responseDeleteMeetingResult:YES errMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [self.scheduledView responseDeleteMeetingResult:NO errMsg:error.localizedDescription];
    }];
}

void f_addMeetingIntoHomeMeetingList(NSString *identifier) {
    [[FrtcManagement sharedManagement] addMeetingIntoMyMeetingList:[FrtcUserModel fetchUserInfo].user_token
                                                        identifier:identifier
                                                 completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [MBProgressHUD showMessage:FLocalized(@"meeting_add_RecurrenceSuccess", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshHomeMeetingListNotification object:nil];
    } failure:^(NSError * _Nonnull error) {
    }];
}

void f_removeMeetingFromHomeList(NSString *identifier , void (^resposeResult)(bool result, NSError * _Nonnull error)) {
    
    [[FrtcManagement sharedManagement] removeMeetingFromMyMeetingList:[FrtcUserModel fetchUserInfo].user_token
                                                           identifier:identifier
                                                    completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        resposeResult(YES , [NSError new]);
    } failure:^(NSError * _Nonnull error) {
        resposeResult(NO , error);
    }];
    
}


@end

