
#import "FrtcScheduleMeetingDetailViewController.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIViewController+Extensions.h"
#import "FrtcScheduleListPresenter.h"
#import "FrtcHDHomeDetailTableViewCell.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcMakeCallClient.h"
#import "FrtcUserModel.h"
#import "UINavigationItem+Extensions.h"
#import "FrtcScheduleMeetingViewController.h"
#import "UIView+Toast.h"
#import "FrtcInvitationInfoManage.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "FrtcMeetingReminderDataManager.h"
#import "FrtcHomeDetailHeaderView.h"
#import "FrtcRecurrenceGroupListViewController.h"
#import "FrtcChangeOneRecurrenceViewController.h"

@interface FrtcScheduleMeetingDetailViewController ()<FrtcScheduleListResultProtocol,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger meetingListCount;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FrtcScheduleListPresenter *presenter;
@property (nonatomic, strong) NSArray<FHomeDetailMeetingInfo *> *dataSore;
@property (nonatomic, copy) NSMutableString *meetingInfoCopy;
@property (nonatomic, weak) UIButton *temporaryButton;
@property (nonatomic, strong) FrtcHomeDetailHeaderView *headerView;
@property (nonatomic, strong) FScheduleListDataModel *groupListData;

@end

@implementation FrtcScheduleMeetingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"meeting_details", nil);
    if (_isPush) {
        [self.presenter requestDetailDataWithId:_meetingId];
    }else{
        [self.presenter handelDetailDataWithInfo:_detailInfo];
        [self.presenter requestDetailDataWithId:_detailInfo.reservation_id];
    }
    
    [self requestRecurrenceMeetingList];
}

- (void)dealloc {
    KUpdateHomeView
}

- (void)configUI {
    [self configNavigationItem];
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
}

- (void)requestRecurrenceMeetingList {
    if (self.detailInfo.isRecurrence) {
        meetingListCount = _detailInfo.recurrenceReservationList.count;
        _detailInfo.meetingTotal_size = meetingListCount;
        NSString *interval_str = _detailInfo.recurrenceInterval_result;
        NSString *totalSize = [NSString stringWithFormat:@"%td",_detailInfo.recurrenceReservationList.count];
        NSString *remainingMeeting = [NSString stringWithFormat:FLocalized(@"recurrence_remainingmeetings", nil),totalSize];
        self.headerView.heaer_duplicateLabel.text = [NSString stringWithFormat:@"%@ %@",interval_str,remainingMeeting];
        
        [self.presenter requestGroupListDataWithGroupId:self.detailInfo.recurrence_gid];
    }
}

- (void)configNavigationItem {
    if (_detailInfo.isYourSelf && ![_detailInfo.meeting_type isEqualToString:@"instant"]) {
        @WeakObj(self);
        [self.navigationItem initWithRightButtonTitle:FLocalized(@"recurrence_change", nil) back:^{
            @StrongObj(self)
            if (self.detailInfo.isRecurrence) {
                @WeakObj(self);
                [self showSheetWithTitle:@"" message:@"" buttonTitles:@[FLocalized(@"recurrence_editCurrent", nil),FLocalized(@"recurrence_editRecurring", nil)] alerAction:^(NSInteger index) {
                    @StrongObj(self)
                    if (index == 1) {
                        [self pushCreateScheduleMeetingPage];
                    }
                    if (index == 0) {
                        [self pushChangeOneMeeting];
                    }
                }];
            }else{
                [self pushCreateScheduleMeetingPage];
            }
        }];
    }
}

#pragma mark - action

- (void)pushCreateScheduleMeetingPage {
    FrtcScheduleMeetingViewController *vc = [[FrtcScheduleMeetingViewController alloc]init];
    vc.edit = YES;
    vc.detailInfo = self.detailInfo;
    @WeakObj(self);
    vc.updateRecurrenceMeetingSuccess = ^(NSString * _Nonnull reservation_id) {
        @StrongObj(self)
        [self.presenter requestDetailDataWithId:reservation_id];
        [self requestRecurrenceMeetingList];
        [self refreshScheduelist];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushChangeOneMeeting {
    FrtcChangeOneRecurrenceViewController *vc = [[FrtcChangeOneRecurrenceViewController alloc]init];
    vc.detailInfo = _detailInfo;
    vc.groupMeetingList = _groupListData.meeting_schedules;
    @WeakObj(self);
    vc.UpdateDetailMeetingView = ^(NSString * _Nonnull reId) {
        @StrongObj(self)
        [self.presenter requestDetailDataWithId:self.detailInfo.reservation_id];
        [self requestRecurrenceMeetingList];
        [self refreshScheduelist];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshScheduelist {
    if (self.updateScheduledMeetingList) {
        self.updateScheduledMeetingList();
    }
}

#pragma mark - FrtcScheduleListResultProtocol

- (void)responseScheduledMeetingDetail:(NSArray<FHomeDetailMeetingInfo *> *)detailList detailInfo:(FrtcScheduleDetailModel *)detailInfo errMsg:(NSString *)errMsg {
    if (!errMsg) {
        _dataSore = detailList;
        _detailInfo = detailInfo;
        if (_detailInfo.isRecurrence) {
            _detailInfo.meetingTotal_size = meetingListCount;
        }
        [self.tableView reloadData];
        if (_isPush) {
            [self configNavigationItem];
        }
        self.headerView.detailModel = detailInfo;
        if (!_detailInfo.isRecurrence) {
            [self.tableView beginUpdates];
            CGRect rect = self.headerView.frame;
            rect.size.height = 60;
            self.headerView.frame = rect;
            [self.tableView endUpdates];
        }
    }else{
        [MBProgressHUD showMessage:errMsg];
    }
}

- (void)responseDeleteMeetingResult:(BOOL)result errMsg:(NSString *)errMsg {
    [MBProgressHUD hideHUD];
    if (result) {
        [self refreshScheduelist];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [MBProgressHUD showMessage:errMsg];
    }
}

- (void)responseGroupListDetail:(FScheduleListDataModel *)model errMsg:(NSString *)errMsg {
    if (!errMsg) {
        _groupListData = model;
        NSString *interval_str = _detailInfo.recurrenceInterval_result;
        NSString *totalSize = [NSString stringWithFormat:@"%ld",model.total_size];
        _detailInfo.meetingTotal_size = [totalSize integerValue];
        NSString *remainingMeeting = [NSString stringWithFormat:FLocalized(@"recurrence_remainingmeetings", nil),totalSize];
        self.headerView.heaer_duplicateLabel.text = [NSString stringWithFormat:@"%@ %@",interval_str,remainingMeeting];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        if (_detailInfo.isYourSelf || self.isYourSelfJoin) {
            return 3 + 1;
        }
        return 3;
    }
    return _dataSore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FrtcHDHomeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrtcHDHomeDetailTableViewCell" forIndexPath:indexPath];
        FHomeDetailMeetingInfo *info = _dataSore[indexPath.row];
        cell.info = info;
        return cell;
    }else{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellMeeting"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = UIColor.clearColor;
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
            UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelBtn.frame = CGRectMake(KLeftSpacing, 10, self.tableView.bounds.size.width - KLeftSpacing * 2, 50);
            [cancelBtn setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateNormal];
            [cancelBtn setBackgroundImage:[UIImage imageFromColor:KBGColor] forState:UIControlStateHighlighted];
            cancelBtn.tag = 1026;
            cancelBtn.layer.masksToBounds = YES;
            cancelBtn.layer.cornerRadius = KCornerRadius * 2;
            cancelBtn.layer.borderColor  = KLineColor.CGColor;
            cancelBtn.layer.borderWidth  = 1;
            @WeakObj(self);
            [cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                @StrongObj(self)
                [self didClickCellBtnAction:indexPath];
            }];
            [cell.contentView addSubview:cancelBtn];
        }
        UIButton *customBtn = (UIButton *)[cell viewWithTag:1026];
        if (indexPath.row == 0) {
            self.temporaryButton = customBtn;
            [customBtn setTitle:NSLocalizedString(@"meeting_join", nil) forState:UIControlStateNormal];
            [customBtn setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
            [customBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        }else if (indexPath.row == 1 ) {
            [customBtn setTitle:NSLocalizedString(@"meeting_copy_info", nil) forState:UIControlStateNormal];
            [customBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        }else if (indexPath.row == 2 ) {
            if (_detailInfo.isYourSelf || self.isYourSelfJoin) {
                [customBtn setTitle:self.isYourSelfJoin ? FLocalized(@"meeting_add_removeRecurrence", nil) : NSLocalizedString(@"meeting_cancel", nil) forState:UIControlStateNormal];
                [customBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            }else{
                [self setUpCustomBottonAppearance:customBtn];
            }
        }else {
            [self setUpCustomBottonAppearance:customBtn];
        }
        return cell;
    }
}

- (void)setUpCustomBottonAppearance:(UIButton *)customBtn{
    [customBtn setImage:[UIImage imageNamed:@"meeting_calendar"] forState:UIControlStateNormal];
    [customBtn setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"MEETING_REMINDER_CALENDAR", nil)] forState:UIControlStateNormal];
    [customBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    customBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [customBtn setBackgroundImage:[UIImage imageFromColor:UIColor.clearColor] forState:UIControlStateNormal];
    customBtn.layer.borderWidth = 0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Btn action

- (void)didClickCellBtnAction:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        self.temporaryButton.enabled = NO;
        [self configCallParameter];
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        [FrtcInvitationInfoManage shareInvitationMeetingInfo:_detailInfo];
    }
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        if (_detailInfo.isYourSelf || self.isYourSelfJoin) {
            if (self.isYourSelfJoin) {
                [self showAlertYourSelfJoinView];
            }else {
                @WeakObj(self);
                if (self.detailInfo.isRecurrence) {
                    [self showRadioViewWithTitle:NSLocalizedString(@"meeting_cancel", nil)
                                         message:NSLocalizedString(@"recurrence_cancleEntireWell", nil)
                                    cancelTitles:@[]
                                      alerAction:^(NSInteger index, _Bool isSelect) {
                        if (index == 1) {
                            @StrongObj(self)
                            [self deleteMeetingWithRecurrence:isSelect];
                        }
                    }];
                }else{
                    [self showAlertWithTitle:NSLocalizedString(@"meeting_cancel", nil)
                                     message:NSLocalizedString(@"meeting_cancleNoJoin", nil)
                                buttonTitles:@[NSLocalizedString(@"meeting_thinhAgain", nil),NSLocalizedString(@"meeting_yes", nil)]
                                  alerAction:^(NSInteger index) {
                        if (index == 1) {
                            @StrongObj(self)
                            [self deleteMeetingWithRecurrence:NO];
                        }
                    }];
                }
            }
        }else{
            [self addToCalendar];
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 3) {
        [self addToCalendar];
    }
}

- (void)showAlertYourSelfJoinView {
    @WeakObj(self);
    if (self.detailInfo.isRecurrence) {
        [self showAlertWithTitle:FLocalized(@"meeting_add_removeRecurrence_title", nil)
                         message:FLocalized(@"meeting_add_removeRecurrence_content", nil)
                    buttonTitles:@[NSLocalizedString(@"meeting_thinhAgain", nil),FLocalized(@"meeting_add_removeRecurrence", nil)]
                      alerAction:^(NSInteger index) {
            if (index == 1) {
                @StrongObj(self)
                [self removeMeetingFromMeetingList:self.detailInfo.groupInfoKey];
            }
        }];
    }else{
        [self showAlertWithTitle:FLocalized(@"meeting_add_removeMeeting_title", nil)
                         message:FLocalized(@"meeting_add_removeMeeting_content", nil)
                    buttonTitles:@[NSLocalizedString(@"meeting_thinhAgain", nil),FLocalized(@"meeting_add_removeRecurrence", nil)]
                      alerAction:^(NSInteger index) {
            if (index == 1) {
                @StrongObj(self)
                NSURL *url = [NSURL URLWithString:self.detailInfo.meeting_url];
                NSString *lastPath = [url.lastPathComponent stringByDeletingPathExtension];
                [self removeMeetingFromMeetingList:lastPath];
            }
        }];
    }
}

- (void)deleteMeetingWithRecurrence:(BOOL)isRecurrence {
    [MBProgressHUD showActivityMessage:@""];
    if (isRecurrence) {
        [self.presenter deleteRecurrenceMeetingWithId:self.detailInfo.reservation_id];
    }else{
        [self.presenter deleteScheduledMeetingWithId:self.detailInfo.reservation_id];
    }
    [[FrtcMeetingReminderDataManager sharedInstance] removeMeetingInfoFromLocalNotifications:self->_detailInfo.reservation_id];
}

- (void)removeMeetingFromMeetingList:(NSString *)meetingId {
    if (kStringIsEmpty(meetingId)) {
        return;
    }
    [self.presenter removeMeetingFromHomeList:meetingId];
}

- (void)addToCalendar {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if (@available(iOS 17.0, *)) {
        [eventStore requestWriteOnlyAccessToEventsWithCompletion:^(BOOL granted, NSError * _Nullable error) {
            [self addToCalendarWithEvent:eventStore granted:granted error:error];
        }];
    }else{
        if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                [self addToCalendarWithEvent:eventStore granted:granted error:error];
            }];
        }
    }
}


- (void)addToCalendarWithEvent:(EKEventStore *)eventStore granted:(BOOL)granted error:(NSError *)error {
    if (granted) {
        [self addDetailInfoToCalendar:@[self.detailInfo] event:eventStore];
    }
}

- (void)addDetailInfoToCalendar:(NSArray <FrtcScheduleDetailModel *> *)meetingInfos event:(EKEventStore *)eventStore{
    
    int i = 0;
    while (i < meetingInfos.count) {
        FrtcScheduleDetailModel *modelInfo = meetingInfos[i];
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        event.title = modelInfo.meeting_name;
        event.startDate = [NSDate dateWithTimeIntervalSince1970:[modelInfo.schedule_start_time longLongValue]/1000];
        event.endDate   = [NSDate dateWithTimeIntervalSince1970:[modelInfo.schedule_end_time longLongValue]/1000];
        event.calendar  = [eventStore defaultCalendarForNewEvents];
        event.location  = modelInfo.meeting_url;
        event.URL   = [NSURL URLWithString:modelInfo.meeting_url];
        event.notes = [FrtcInvitationInfoManage getShareInvitationMeetingInfo:modelInfo];
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-300];//五分钟前提醒
        [event addAlarm:alarm];
        
        NSError *saveError = nil;
        [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&saveError];
        if (saveError != nil) {
        } else {
        }
        i ++ ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.view makeToast:NSLocalizedString(@"MEETING_REMINDER_CALENDAR_ADDOK", nil)];
    });
}

#pragma mark - config join Meeting
- (void)configCallParameter{
    NSString *conferenceCallRate = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
    ISMLog(@"numberCallRate = %d",numberCallRate);
    FRTCSDKCallParam callParam;
    callParam.conferenceNumber = _detailInfo.meeting_number;
    NSString *displayName = [FrtcUserModel fetchUserInfo].real_name;
    callParam.clientName = displayName;
    callParam.callRate = numberCallRate;
    callParam.muteCamera = YES;
    callParam.muteMicrophone = YES;
    callParam.audioCall = NO;
    if (isLoginSuccess) {
        callParam.userToken = [FrtcUserModel fetchUserInfo].user_token;
    }
    if (!kStringIsEmpty(_detailInfo.meeting_password)) {
        callParam.password = _detailInfo.meeting_password;
    }
    [self joinMeetingWithCallParam:callParam];
}

- (void)joinMeetingWithCallParam:(FRTCSDKCallParam)callParam {
    if (![FrtcHelpers isNetwork]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        self.temporaryButton.enabled = YES;
        return;
    }
    if ([FrtcHelpers f_isInMieeting]) {
        self.temporaryButton.enabled = YES;
        return;
    }
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @WeakObj(self);
    [[FrtcMakeCallClient sharedSDKContext] makeCall:self withCallParam:callParam withCallSuccessBlock:^{
        [self.navigationController.view hideToastActivity];
        self.temporaryButton.enabled = YES;
    } withCallFailureBlock:^(FRTCMeetingStatusReason status, NSString * _Nonnull errMsg) {
        if (kStringIsEmpty(errMsg)) { return; }
        @StrongObj(self)
        [self.navigationController.view hideToastActivity];
        self.temporaryButton.enabled = YES;
        //        [self showAlertWithTitle:@"" message:errMsg buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
        //            @StrongObj(self)
        //            if (status == MEETING_STATUS_MEETINGNOTEXIST) {
        //                [self refreshScheduelist];
        //                [self.navigationController popViewControllerAnimated:YES];
        //            }
        //        }];
    } withInputPassCodeCallBack:^{
        [self.navigationController.view hideToastActivity];
        self.temporaryButton.enabled = YES;
        @StrongObj(self)
        [self showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil) textFieldStyle:FTextFieldPassword alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
            if (index == 1) {
                [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:alertString];
                [[FrtcUserDefault sharedUserDefault] setObject:alertString forKey:MEETING_PASSWORD];
            }else{
                [[FrtcCall frtcSharedCallClient] frtcHangupCall];
            }
        }];
    }];
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FrtcHDHomeDetailTableViewCell class] forCellReuseIdentifier:@"FrtcHDHomeDetailTableViewCell"];
        _tableView.rowHeight = KHomeDtailCellHeight;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = KBGColor;
        _tableView.sectionFooterHeight = 20;
        _tableView.tableHeaderView = self.headerView;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (FrtcScheduleListPresenter *)presenter {
    if (!_presenter) {
        _presenter = [FrtcScheduleListPresenter new];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (FrtcHomeDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[FrtcHomeDetailHeaderView alloc]init];
        _headerView.frame = CGRectMake(0, 0, KScreenWidth, 100);
        @WeakObj(self)
        _headerView.didSelectRecurrenceView = ^{
            @StrongObj(self)
            if (self.isRecurrenceList) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                FrtcRecurrenceGroupListViewController *listVC = [[FrtcRecurrenceGroupListViewController alloc]init];
                listVC.detailInfo = self->_detailInfo;
                listVC.group_id   = self->_detailInfo.recurrence_gid;
                listVC.isYourSelfJoin = self.isYourSelfJoin;
                @WeakObj(self)
                listVC.updateGroupListMeetingList = ^{
                    @StrongObj(self)
                    [self dismissViewControllerAnimated:YES completion:nil];
                    if (self.updateScheduledMeetingList) {
                        self.updateScheduledMeetingList();
                    }
                };
                listVC.updateRecurrenceMeetingModel = ^(NSString * _Nonnull rid) {
                    @StrongObj(self)
                    [self.presenter requestDetailDataWithId:rid];
                    [self requestRecurrenceMeetingList];
                    [self refreshScheduelist];
                };
                [self.navigationController pushViewController:listVC animated:YES];
            }
        };
    }
    return _headerView;
}

@end
