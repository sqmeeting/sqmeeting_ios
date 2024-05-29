#import "FrtcHomeScheduleListView.h"
#import "FrtcHDHomeMeetingListCell.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "UITableView+Extensions.h"
#import "FrtcHomeScheduleListHeaderView.h"
#import "FrtcScheduleMeetingDetailViewController.h"
#import "MJRefresh.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcScheduleListPresenter.h"
#import "FrtcUserModel.h"
#import "UIViewController+Extensions.h"
#import "FrtcHomeScheduleCell.h"
#import "NSTimer+Enhancement.h"

#define HomeScheduleListCellIdentifier @"FrtcHomeScheduleCell"
#define HomeScheduleListHeaderViewIdentifier @"FrtcHomeScheduleListHeaderView"

@interface FrtcHomeScheduleListView () <UITableViewDelegate,UITableViewDataSource,FrtcScheduleListResultProtocol>

@property (nonatomic, strong) NSMutableArray *scheduledlistdata;
@property (nonatomic, strong) FrtcScheduleListPresenter *presenter;

@end


@implementation FrtcHomeScheduleListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadScheduledListData];
        [self scheduleListViewLayout];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)scheduleListViewLayout {
    [NSTimer plua_scheduledTimerWithTimeInterval:15*60 block:^{
        [self.tableView.mj_header beginRefreshing];
    } repeats:YES];
}

- (void)loadScheduledListData {
    [self.presenter requestScheduledListDataWithPageNum:1];
}

#pragma mark - FrtcScheduleListResultProtocol

- (void)responseScheduledMeetingListData:(FScheduleListDataModel *)resultList errMsg:(NSString *)errMsg {
    [self.tableView.mj_header endRefreshing];
    if (!errMsg) {
        [self.scheduledlistdata removeAllObjects];
        NSArray *list = [self.presenter handleTimeSectionWithData:resultList.meeting_schedules];
        [self.scheduledlistdata addObjectsFromArray:list];
    }
    [self.tableView reloadData];
    self.tableView.mj_footer.hidden = YES;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getShowList:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcHomeScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeScheduleListCellIdentifier forIndexPath:indexPath];
    FrtcScheduleDetailModel *info = [self getShowList:indexPath.section][indexPath.row];
    cell.scheduledInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrtcScheduleDetailModel *info = [self getShowList:indexPath.section][indexPath.row];
    FrtcScheduleMeetingDetailViewController *detailVC = [[FrtcScheduleMeetingDetailViewController alloc]init];
    detailVC.detailInfo = info;
    detailVC.isYourSelfJoin = info.isJoinYourself;
    @WeakObj(self);
    detailVC.updateScheduledMeetingList = ^{
        @StrongObj(self)
        [self.tableView.mj_header beginRefreshing];
    };
    [[FrtcHelpers getCurrentVC] presentHDViewController:detailVC animated:YES completion:^{  }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.scheduledlistdata.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FrtcHomeScheduleListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HomeScheduleListHeaderViewIdentifier];
    FrtcScheduleDetailModel *info = [self getShowList:section][0];
    headerView.meetingTime = [FrtcHelpers getDateWithtimeStamp:info.schedule_start_time];
    return headerView;
}

- (NSArray<FrtcScheduleDetailModel *> *)getShowList:(NSInteger)index {
    NSDictionary *dict = self.scheduledlistdata[index];
    NSArray<FrtcScheduleDetailModel *> *list = [dict objectForKey:dict.allKeys[0]] ;
    return list;
}

#pragma mark - FTableViewDelegate

- (UIImage  *)f_noDataViewImage {
    return [UIImage imageNamed:@"home_nodatabging"];
}

- (NSString *)f_noDataViewMessage {
    return  NSLocalizedString(@"meeting_noAppointment", nil);;
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.contentInset = UIEdgeInsetsMake(6, 0, 0, 0);
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcHomeScheduleCell class] forCellReuseIdentifier:HomeScheduleListCellIdentifier];
        [_tableView registerClass:[FrtcHomeScheduleListHeaderView class] forHeaderFooterViewReuseIdentifier:HomeScheduleListHeaderViewIdentifier];
        _tableView.rowHeight = HomeScheduleCellHeight;
        _tableView.sectionHeaderHeight = 35;
        _tableView.sectionFooterHeight = 0.001;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGFLOAT_MIN)];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                         refreshingAction:@selector(loadScheduledListData)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        _tableView.mj_header = header;
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (FrtcScheduleListPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[FrtcScheduleListPresenter alloc]init];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (NSMutableArray *)scheduledlistdata {
    if (!_scheduledlistdata) {
        _scheduledlistdata = [NSMutableArray array];
    }
    return _scheduledlistdata;
}

@end
