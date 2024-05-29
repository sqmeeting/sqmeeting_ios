#import "FrtcScheduleMeetingListView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcScheduleTextfiledCell.h"
#import "FrtcScheduleDetaileCell.h"
#import "FrtcScheduleMeetingModel.h"
#import "FrtcScheduleDatePickerView.h"
#import "FrtcScheduleTimePickerView.h"
#import "FrtcMeetingIntroductionViewController.h"
#import "FrtcScheduleNumberTableViewCell.h"
#import "FrtcNewMeetingPresenter.h"
#import "FrtcNewMeetingRoomListModel.h"
#import "FrtcScheduleRateListViewController.h"
#import "FrtcMeetingInviteUserViewController.h"
#import "FrtcHistoryMeetingListView.h"
#import "FrtcCycleSelectViewController.h"
#import "FrtcCycleSettingViewController.h"
#import "FrtcJoiningTimeViewController.h"


#define KScheduleTextFieldIdentifier @"FrtcScheduleTextfiledCell"
#define KFrtcScheduleDetaileCellIdentifier @"FrtcScheduleDetaileCell"
#define KFScheduleNumberIdentifier @"FrtcScheduleNumberTableViewCell"

@interface FrtcScheduleMeetingListView () <UITableViewDelegate,UITableViewDataSource,FScheduleIntroductionDelegate,FrtcNewMeetingProtocol>
{
    NSIndexPath *_selectIndexPath;
    BOOL _isOpen;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FrtcNewMeetingPresenter *presenter;
@property (nonatomic, strong) NSMutableArray <FNewMeetingRoomListInfo *> *meetingRoomList;
@property (nonatomic, strong) FrtcHistoryMeetingListView *historyMeetingListView;

@end

@implementation FrtcScheduleMeetingListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self scheduleMeetingListViewLayout];
    }
    return self;
}

- (void)scheduleMeetingListViewLayout {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setEdit:(BOOL)edit {
    _edit = edit;
    if (_edit) {
        [self.presenter requestMeetingRoomList];
    }
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - setter

- (void)setScheduleListData:(NSArray *)scheduleListData {
    _scheduleListData = scheduleListData;
    [self.tableView reloadData];
}

- (FrtcScheduleNumberTableViewCell *)getNumberCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    return (FrtcScheduleNumberTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)popUpNumberListView {
    @WeakObj(self);
    if (self.historyMeetingListView) {
        [self.historyMeetingListView disMiss];
        self.historyMeetingListView = nil;
    }else {
        self.historyMeetingListView = [[FrtcHistoryMeetingListView alloc]init];
        self.historyMeetingListView.array = self.meetingRoomList;
        self.historyMeetingListView.selectedBlock = ^(FNewMeetingRoomListInfo * _Nonnull info) {
            @StrongObj(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                FrtcScheduleNumberTableViewCell *numberCell = [self getNumberCell];
                numberCell.meetingNumbertextField.text = info.meeting_number;
                [self callBackDelegateWithCustomInfo:self->_selectIndexPath custonInfo:@{@"roomid":info.meeting_room_id,@"number":info.meeting_number}];
                //self.meetingNumbertextField.text = info.meeting_number;
                self.historyMeetingListView = nil;
            });
        };
        
        FrtcScheduleNumberTableViewCell *cell = [self getNumberCell];
        
        [self addSubview:self.historyMeetingListView];
        [self.historyMeetingListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.height.mas_equalTo(190);
            make.top.mas_equalTo(cell.mas_bottom).mas_offset(10);
        }];
    }
}

#pragma mark - FrtcNewMeetingProtocol

- (void)responseMeetingRoomSuccess:(NSArray <FNewMeetingRoomListInfo *> * _Nullable)result errMsg:(NSString * _Nullable)errMsg {
    if (!errMsg) {
        [self.meetingRoomList removeAllObjects];
        [self.meetingRoomList addObjectsFromArray:result];
        FrtcScheduleNumberTableViewCell *numberCell = [self getNumberCell];
        if (self.meetingRoomList.count > 0 ) {
            numberCell.meetingRoomList = self.meetingRoomList;
            [self callBackDelegateWithCustomInfo:_selectIndexPath custonInfo:@{@"roomid":self.meetingRoomList[0].meeting_room_id,@"number":self.meetingRoomList[0].meeting_number}];

            [self callBackDelegateSwitchStatusWithIndexPath:_selectIndexPath open:_isOpen];
        }else{
            numberCell.noiseSwitch.on = NO;
            _isOpen = NO;
            if (!_edit) {
                [MBProgressHUD showMessage:NSLocalizedString(@"meeting_not_meetingNumber", nil)];
            }
        }
    }else{
        if (!_edit) {
            [MBProgressHUD showMessage:errMsg];
        }
    }
}

#pragma mark - FScheduleIntroductionDelegate

- (void)didEditIntroductionWithResult:(NSString *)info {
    [self callBackDelegateWithIndexPath:_selectIndexPath content:info];
}

#pragma mark - action

- (void)selectCellWithInfo:(FrtcScheduleMeetingModel *)info indexPath:(NSIndexPath *)indexPath {
    _selectIndexPath = indexPath;
    if (indexPath.section == 0 && indexPath.row == 1 ) {
        FrtcMeetingIntroductionViewController  *vc = [[FrtcMeetingIntroductionViewController alloc]init];
        vc.delegate = self;
        vc.introduction = info.detailTitle;
        [[FrtcHelpers getCurrentVC].navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.section == 1 ) {
        if (indexPath.row == 0 ) {
            @WeakObj(self)
            [FrtcScheduleDatePickerView showDatePickerViewWithMinimumDate:f_nextTimeNodeTimestampMilliseconds(@"")
                                                               maxDate:@""
                                                           DefaultDate:@""
                                                             dateBlock:^(NSString * _Nonnull timeStamp) {
                @StrongObj(self)
                [self callBackDelegateWithIndexPath:self->_selectIndexPath content:timeStamp];
            }];
        }
        
        if (indexPath.row == 1 ) {
            [FrtcScheduleTimePickerView showTimePickerViewWithTimeStr:^(NSString * _Nonnull hh, NSString * _Nonnull mm) {
                NSArray *times = @[hh,mm];
                [self callBackDelegateWithIndexPath:self->_selectIndexPath content:[times componentsJoinedByString:@","]];
            }];
        }
        
        if (indexPath.row == 3) { //重复频率
            
            if (info.isEditing && !info.recurrentMeetingResultModel.isRecurrent) {
                [MBProgressHUD showMessage:@"非周期性会议,无法修改为周期性会议"];
                return;
            }
            
            FrtcScheduleMeetingModel *stopTimeInfo = (FrtcScheduleMeetingModel *)_scheduleListData[1][0];
            FrtcScheduleMeetingModel *recurrentInfo = (FrtcScheduleMeetingModel *)_scheduleListData[1][3];

            FrtcCycleSelectViewController *cycleSelectVC = [[FrtcCycleSelectViewController alloc]init];
            cycleSelectVC.editModel = recurrentInfo.recurrentMeetingResultModel;
            cycleSelectVC.startTime = stopTimeInfo.timeStamp;
            cycleSelectVC.edit = info.isEditing;
            @WeakObj(self)
            cycleSelectVC.recurrentSelectMeetingResult = ^(FRecurrentMeetingResutModel * _Nonnull model) {
                @StrongObj(self)
                [self callBackDelegateWithCustomInfo:self->_selectIndexPath custonInfo:model];
            };
            [[FrtcHelpers getCurrentVC].navigationController pushViewController:cycleSelectVC animated:YES];
        }
        
        if (indexPath.row == 4) {
            
            FrtcScheduleMeetingModel *stopTimeInfo = (FrtcScheduleMeetingModel *)_scheduleListData[1][0];
            FrtcScheduleMeetingModel *recurrentInfo = (FrtcScheduleMeetingModel *)_scheduleListData[1][3];
            
            FrtcCycleSettingViewController * recurrentecSettingView = [[FrtcCycleSettingViewController alloc]init];
            recurrentecSettingView.editSettingModel = recurrentInfo.recurrentMeetingResultModel;
            recurrentecSettingView.startTime = stopTimeInfo.timeStamp;
            recurrentecSettingView.settingType = recurrentInfo.recurrentMeetingResultModel.recurrent_Enum_Type;
            self->_selectIndexPath = [NSIndexPath indexPathForRow:self->_selectIndexPath.row - 1  inSection:self->_selectIndexPath.section];
            
            @WeakObj(self)
            recurrentecSettingView.recurrentMeetingResult = ^(FRecurrentMeetingResutModel * _Nonnull model) {
                @StrongObj(self)
                [self callBackDelegateWithCustomInfo:self->_selectIndexPath custonInfo:model];
            };
            [[FrtcHelpers getCurrentVC].navigationController pushViewController:recurrentecSettingView animated:YES];
        }
    }
    
    if (indexPath.section == (_isOpen ? 3 : 4)) {

        if (indexPath.row == 0 ) {
            FrtcMeetingInviteUserViewController *vc = [[FrtcMeetingInviteUserViewController alloc]init];
            vc.userIds = info.inviteUsers;
            @WeakObj(self);
            vc.inviteUserList = ^(NSArray<FInviteUserListInfo *> * _Nonnull users) {
                @StrongObj(self)
                [self callBackDelegateWithCustomInfo:self->_selectIndexPath custonInfo:users];
            };
            [[FrtcHelpers getCurrentVC].navigationController pushViewController:vc animated:YES];
        }
        
        if (indexPath.row == 1 ) {
            FrtcScheduleRateListViewController *vc = [[FrtcScheduleRateListViewController alloc]init];
            vc.rate = info.detailTitle;
            @WeakObj(self);
            vc.rateResultCallBack = ^(NSString * _Nonnull rate) {
                @StrongObj(self)
                [self callBackDelegateWithIndexPath:self->_selectIndexPath content:rate];
            };
            [[FrtcHelpers getCurrentVC].navigationController pushViewController:vc animated:YES];
        }
        
        if (indexPath.row == 2) {
            
            FrtcJoiningTimeViewController *vc = [[FrtcJoiningTimeViewController alloc]init];
            vc.joiningTime = info.detailTitle;
            @WeakObj(self);
            vc.joiningTimeResultCallBack = ^(NSString * _Nonnull time) {
                @StrongObj(self)
                [self callBackDelegateWithIndexPath:self->_selectIndexPath content:time];
            };
            [[FrtcHelpers getCurrentVC].navigationController pushViewController:vc animated:YES];
        }

    }
}

- (void)callBackDelegateWithIndexPath:(NSIndexPath *)indexPath content:(NSString *)content {
    if ([self.delegate respondsToSelector:@selector(updateScheduleListViewWithInfo:indexPath:)]) {
        [self.delegate updateScheduleListViewWithInfo:content indexPath:indexPath];
    }
}

- (void)callBackDelegateSwitchStatusWithIndexPath:(NSIndexPath *)indexPath open:(BOOL)open {
    if ([self.delegate respondsToSelector:@selector(updateScheduleListSwitchStatusWithOpen:indexPath:)]) {
        [self.delegate updateScheduleListSwitchStatusWithOpen:open indexPath:indexPath];
    }
}

- (void)callBackDelegateWithCustomInfo:(NSIndexPath *)indexPath custonInfo:(id)info {
    if ([self.delegate respondsToSelector:@selector(updateScheduleListViewCustomInfo:indexPath:)]) {
        [self.delegate updateScheduleListViewCustomInfo:info indexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _scheduleListData[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcScheduleMeetingModel *info = (FrtcScheduleMeetingModel *)_scheduleListData[indexPath.section][indexPath.row];
    if (info.cellType == FScheduleCellTextfiled) {
        FrtcScheduleTextfiledCell *cell = [tableView dequeueReusableCellWithIdentifier:KScheduleTextFieldIdentifier forIndexPath:indexPath];
        cell.model = info;
        @WeakObj(self);
        cell.textFieldDidEndEditing = ^(NSString * _Nonnull text) {
            @StrongObj(self)
            [self callBackDelegateWithIndexPath:indexPath content:text];
        };
        return cell;
    }
    else if (info.cellType == FScheduleCellNumber) {
        FrtcScheduleNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KFScheduleNumberIdentifier forIndexPath:indexPath];
        @WeakObj(self);
        cell.noiseSwitch.on = info.isSwitchStatus;
        //ISMLog(@"info.personalMeetingRoomId = %@",info.personalMeetingRoomId);
        if (info.isEditing && info.isSwitchStatus && !kStringIsEmpty(info.personalMeetingRoomId)) {//编辑状态下更新高度
            cell.meetingNumbertextField.text = info.personalMeetingNumber;
            self->_isOpen = YES;
            cell.meetingNumberBottomView.hidden = NO;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }
        cell.numberSwitchCallBack = ^(BOOL isOn) {
            @StrongObj(self)
            self->_selectIndexPath = indexPath;
            self->_isOpen = isOn;
            if (self->_isOpen) {
                [self.presenter requestMeetingRoomList];
            }else{
                [self callBackDelegateSwitchStatusWithIndexPath:indexPath open:NO];
            }
        };
        cell.popUpPersonalNumber = ^{
            @StrongObj(self)
            self->_selectIndexPath = indexPath;
            [self popUpNumberListView];
        };
        return cell;
    }
    else {
        FrtcScheduleDetaileCell *cell = [tableView dequeueReusableCellWithIdentifier:KFrtcScheduleDetaileCellIdentifier forIndexPath:indexPath];
        cell.model = info;
        @WeakObj(self);
        cell.switchCallBack = ^(BOOL isOn) {
            @StrongObj(self)
            [self callBackDelegateSwitchStatusWithIndexPath:indexPath open:isOn];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrtcScheduleMeetingModel *info = (FrtcScheduleMeetingModel *)_scheduleListData[indexPath.section][indexPath.row];
    [self selectCellWithInfo:info indexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _scheduleListData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return _isOpen ? 105 : Detail_Cell_Height;
    }
    return Detail_Cell_Height;
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = KBGColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcScheduleTextfiledCell class] forCellReuseIdentifier:KScheduleTextFieldIdentifier];
        [_tableView registerClass:[FrtcScheduleDetaileCell class] forCellReuseIdentifier:KFrtcScheduleDetaileCellIdentifier];
        [_tableView registerClass:[FrtcScheduleNumberTableViewCell class] forCellReuseIdentifier:KFScheduleNumberIdentifier];
        _tableView.sectionFooterHeight = 0.001;
        _tableView.sectionHeaderHeight = 10;
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGFLOAT_MIN)];
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 15.0, *)) { [_tableView setSectionHeaderTopPadding:0.0f]; }
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (FrtcNewMeetingPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[FrtcNewMeetingPresenter alloc]init];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (NSMutableArray *)meetingRoomList {
    if (!_meetingRoomList) {
        _meetingRoomList = [NSMutableArray new];
    }
    return _meetingRoomList;
}


@end
