#import "FrtcRecurrenceGroupListViewController.h"
#import "FrtcManagement.h"
#import "FrtcUserModel.h"
#import "FrtcHomeRecurrenceGroupHeaderView.h"
#import "Masonry.h"
#import "UINavigationItem+Extensions.h"
#import "UIViewController+Extensions.h"
#import "YYModel.h"
#import "FrtcScheduleMeetingDetailViewController.h"
#import "FrtcHDHomeViewController.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcInvitationInfoManage.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcScheduleMeetingViewController.h"
#import "FrtcRecurrenceGroupTCell.h"
#import "UIImage+Extensions.h"
#import "FrtcCall.h"
#import "FrtcMakeCallClient.h"
#import "UIView+Toast.h"
#import "FrtcScheduleListPresenter.h"
#import "FrtcChangeOneRecurrenceViewController.h"
#import "FrtcScheduleListPresenter.h"

@interface FrtcRecurrenceGroupListViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FrtcHomeRecurrenceGroupHeaderView *groupHeaderView;
@property (nonatomic, strong) NSMutableArray <FrtcScheduleDetailModel *> *groupList;
@property (nonatomic, strong) UIButton *joinButton;

@end

@implementation FrtcRecurrenceGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = FLocalized(@"recurrence_meeting", nil);
    
    @WeakObj(self);
    if ((_detailInfo.isYourSelf && ![_detailInfo.meeting_type isEqualToString:@"instant"]) || self.isYourSelfJoin) {
        [self.navigationItem initWithRightImage:@"frtc_nav_right_threePoint" back:^{
            @StrongObj(self)
            if (self.isYourSelfJoin) {
                [self showJoinYourSelf];
                return;
            }
            [self showSheetWithTitle:@"" message:@"" buttonTitles:@[FLocalized(@"meeting_copy_info", nil),FLocalized(@"recurrence_editRecurring2", nil),FLocalized(@"recurrence_cacaleRecurringMeeting", nil)]
                          alerAction:^(NSInteger index) {
                @StrongObj(self)
                if (index == 0) {
                    [FrtcInvitationInfoManage shareInvitationMeetingInfo:self->_detailInfo];
                }else if (index == 1) {
                    [self pushCreateScheduleMeetingPage];
                }else if (index == 2) {
                    [self showAlert];
                }
            }];
        }];
    }
    
    [self requestGroupListData];
}

#pragma mark - action

- (void)pushCreateScheduleMeetingPage {
    FrtcScheduleMeetingViewController *vc = [[FrtcScheduleMeetingViewController alloc]init];
    vc.edit = YES;
    vc.detailInfo = self.detailInfo;
    @WeakObj(self);
    vc.updateRecurrenceMeetingSuccess = ^(NSString * _Nonnull reservation_id) {
        @StrongObj(self)
        if (self.updateRecurrenceMeetingModel) {
            self.updateRecurrenceMeetingModel(reservation_id);
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAlert {
    @WeakObj(self)
    [self showAlertWithTitle:FLocalized(@"recurrence_cancelMeeting", nil)
                     message:FLocalized(@"recurrence_allNoJoin", nil)
                buttonTitles:@[FLocalized(@"meeting_thinhAgain", nil),FLocalized(@"meeting_cancel", nil)]
                  alerAction:^(NSInteger index) {
        @StrongObj(self)
        if (index == 1) {
            [self delegateGroupListData];
        }
    }];
}

- (void)configUI {
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-KTabbarHeight-10);
    }];
    
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(kButtonHeight);
        make.bottom.mas_equalTo(-KSafeAreaBottomHeight-10);
    }];
}

- (void)showJoinYourSelf {
    @WeakObj(self);
    [self showSheetWithTitle:@"" message:@"" buttonTitles:@[FLocalized(@"meeting_copy_info", nil), FLocalized(@"meeting_add_removeRecurrence", nil)]
                  alerAction:^(NSInteger index) {
        @StrongObj(self)
        if (index == 0) {
            [FrtcInvitationInfoManage shareInvitationMeetingInfo:self->_detailInfo];
        }else if (index == 1) {
            @WeakObj(self);
            f_removeMeetingFromHomeList(self.detailInfo.groupInfoKey, ^(bool result, NSError * _Nonnull error) {
                if (result) {
                    @StrongObj(self)
                    [self backHomeMeetingList];
                }
            });
        }
    }];
}

#pragma mark - getdata

- (void)requestGroupListData {
    
    @WeakObj(self)
    [[FrtcManagement sharedManagement] getRecurrenceMeetingInGroupByPage:[FrtcUserModel fetchUserInfo].user_token
                                                                 groupId:self.group_id
                                                       withMeetingParams:@{@"page_num":@"1",@"page_size":@"100"}
                                                       completionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        @StrongObj(self)
        ISMLog(@"meetingInfo 987 success = %@",meetingInfo);
        FScheduleListDataModel *model = [FScheduleListDataModel yy_modelWithDictionary:meetingInfo];
        [self.groupList removeAllObjects];
        [self.groupList addObjectsFromArray:model.meeting_schedules];
        [self.tableView reloadData];

        NSString *totalSize = [NSString stringWithFormat:@"%ld",model.total_size];
        NSString *remainingMeeting = [NSString stringWithFormat:FLocalized(@"recurrence_remainingmeetings", nil),totalSize];
        
        NSString *stopDateStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingEndStopTime", nil),[FrtcHelpers getDateCustomStringWithTimeStr:self.detailInfo.recurrenceEndDay]];

        self.groupHeaderView.meetingStopTimeLabel.text = [NSString stringWithFormat:@"%@  %@%@",stopDateStr,remainingMeeting,FLocalized(@"recurrence_meetingStr", nil)];                
    } failure:^(NSError * _Nonnull error) {
    }];
}

- (void)delegateGroupListData {
    [MBProgressHUD showActivityMessage:@""];
    @WeakObj(self)
    [[FrtcManagement sharedManagement] deleteNonCurrentMeeting:[FrtcUserModel fetchUserInfo].user_token
                                             withReservationId:self.detailInfo.reservation_id
                                                   deleteGroup:YES
                                       deleteCompletionHandler:^{
        @StrongObj(self)
        [self backHomeMeetingList];
    } deleteFailure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }] ;
}

- (void)backHomeMeetingList {
    [MBProgressHUD hideHUD];
    if (self.updateGroupListMeetingList) {
        self.updateGroupListMeetingList();
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcRecurrenceGroupTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    FrtcScheduleDetailModel *info = self.groupList[indexPath.row];
    cell.detailInfo = info;
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = UIColor.whiteColor;
    }else{
        cell.contentView.backgroundColor = KBGColor;
    }
    if (!_detailInfo.isYourSelf) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrtcScheduleDetailModel *info = self.groupList[indexPath.row];
    //if ([info.reservation_id isEqualToString:self.detailInfo.reservation_id]) {
    //    [self.navigationController popViewControllerAnimated:YES];
    //}else{
    if (_detailInfo.isYourSelf) {
        [self didSelectTableViewCell:info];
    }
    //}
}

- (void)didSelectTableViewCell:(FrtcScheduleDetailModel *)info {
    @WeakObj(self)
    [self showSheetWithTitle:@""
                     message:@""
                buttonTitles:@[FLocalized(@"recurrence_editCurrent", nil),FLocalized(@"meeting_cancel", nil)]
                  alerAction:^(NSInteger index) {
        @StrongObj(self)
        if (index == 0) {
            [self pushChangeOneMeeting:info];
        }else if (index == 1) {
            [self showRemoveMeetingAlertView:info];
        }
    }];
}

- (void)showRemoveMeetingAlertView:(FrtcScheduleDetailModel *)info {
    @WeakObj(self)
    [self showAlertWithTitle:FLocalized(@"meeting_add_removeMeeting_title", nil)
                     message:FLocalized(@"meeting_add_removeMeeting_content", nil)
                buttonTitles:@[NSLocalizedString(@"meeting_thinhAgain", nil),FLocalized(@"meeting_add_removeRecurrence", nil)]
                  alerAction:^(NSInteger index) {
        if (index == 1) {
            @StrongObj(self)
            f_deleteScheduledMeetingWithId(info.reservation_id, ^(bool result, NSError * _Nonnull error) {
                @StrongObj(self)
                if (result) {
                    [MBProgressHUD showMessage:FLocalized(@"meeting_remove_Onemeeting", nil)];
                    [self backHomeMeetingList];
                }
            });
        }
    }];
}

- (void)pushChangeOneMeeting:(FrtcScheduleDetailModel *)info {
    FrtcChangeOneRecurrenceViewController *vc = [[FrtcChangeOneRecurrenceViewController alloc]init];
    vc.detailInfo = info;
    vc.groupMeetingList = self.groupList;
    @WeakObj(self);
    vc.UpdateDetailMeetingView = ^(NSString * _Nonnull reId) {
        @StrongObj(self)
        [self requestGroupListData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - button

- (void)didClickReserveButton:(UIButton *)sender {
    self.joinButton.enabled = NO;
    [self configCallParameter];
}

- (void)configCallParameter{
    NSString *conferenceCallRate = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
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
        self.joinButton.enabled = YES;
        return;
    }
    if ([FrtcHelpers f_isInMieeting]) {
        self.joinButton.enabled = YES;
        return;
    }
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @WeakObj(self);
    [[FrtcMakeCallClient sharedSDKContext] makeCall:self withCallParam:callParam withCallSuccessBlock:^{
        [self.navigationController.view hideToastActivity];
        self.joinButton.enabled = YES;
    } withCallFailureBlock:^(FRTCMeetingStatusReason status, NSString * _Nonnull errMsg) {
        if (kStringIsEmpty(errMsg)) { return; }
        @StrongObj(self)
        [self.navigationController.view hideToastActivity];
        self.joinButton.enabled = YES;
        //        [self showAlertWithTitle:@""
        //                         message:errMsg
        //                    buttonTitles:@[NSLocalizedString(@"ok", nil)]
        //                      alerAction:^(NSInteger index) {
        //            @StrongObj(self)
        //            if (status == MEETING_STATUS_MEETINGNOTEXIST) {
        //                [self.navigationController popViewControllerAnimated:YES];
        //            }
        //        }];
    } withInputPassCodeCallBack:^{
        @StrongObj(self)
        [self.navigationController.view hideToastActivity];
        self.joinButton.enabled = YES;
        [self showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil)
                           textFieldStyle:FTextFieldPassword
                               alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
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
        [_tableView registerClass:[FrtcRecurrenceGroupTCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = KBGColor;
        _tableView.sectionFooterHeight = 20;
        _tableView.tableHeaderView = self.groupHeaderView;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (FrtcHomeRecurrenceGroupHeaderView *)groupHeaderView {
    if (!_groupHeaderView) {
        _groupHeaderView = [[FrtcHomeRecurrenceGroupHeaderView alloc]init];
        _groupHeaderView.frame = CGRectMake(0, 0, KScreenWidth, 140);
        _groupHeaderView.detailModel = self.detailInfo;
    }
    return _groupHeaderView;
}

- (NSMutableArray <FrtcScheduleDetailModel *> *)groupList {
    if (!_groupList) {
        _groupList = [[NSMutableArray alloc]init];
    }
    return _groupList;
}

- (UIButton *)joinButton {
    if(!_joinButton) {
        _joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setTitle:FLocalized(@"meeting_join", nil) forState:UIControlStateNormal];
        [_joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_joinButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_joinButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_joinButton addTarget:self action:@selector(didClickReserveButton:) forControlEvents:UIControlEventTouchUpInside];
        _joinButton.layer.masksToBounds = YES;
        _joinButton.layer.cornerRadius = KCornerRadius;
        [self.contentView addSubview:_joinButton];
    }
    
    return _joinButton;
}
@end
