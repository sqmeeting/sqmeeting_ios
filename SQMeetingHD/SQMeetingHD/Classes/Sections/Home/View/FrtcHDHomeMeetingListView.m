#import "FrtcHDHomeMeetingListView.h"
#import "Masonry.h"
#import "FrtcHDHomeMeetingListCell.h"
#import "FrtcHDHomeMeetingDetailVC.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "UITableView+Extensions.h"
#import "UIViewController+Extensions.h"
#import "UIView+Extensions.h"

#define HomeMeetingListCellIdentifier @"HomeMeetingListCellIdentifier"

@interface FrtcHDHomeMeetingListView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *meetinglistdata;

@end

@implementation FrtcHDHomeMeetingListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.rowHeight  = 90;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcHDHomeMeetingListCell class] forCellReuseIdentifier:HomeMeetingListCellIdentifier];
        _tableView.rowHeight = HomeMeetingListCellHeight;
        [self addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.bottom.left.right.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_meetinglistdata.count > 20) {
        return 20;
    }
    return _meetinglistdata.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FrtcHDHomeMeetingListCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeMeetingListCellIdentifier forIndexPath:indexPath];
    cell.info = _meetinglistdata[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrtcHDHomeMeetingDetailVC *detailVC = [[FrtcHDHomeMeetingDetailVC alloc]init];
    detailVC.meetingIofo = _meetinglistdata[indexPath.row];
    [self.viewController presentHDViewController:detailVC animated:YES completion:^{}];
}

#pragma mark - FTableViewDelegate

- (UIImage  *)f_noDataViewImage {
    return [UIImage imageNamed:@"home_nodatabging"];
}

- (NSString *)f_noDataViewMessage {
    return  NSLocalizedString(@"history_meeting_null", nil);
}


#pragma mark - action

- (void)reloadTableView {
    _meetinglistdata = [FrtcHomeMeetingListPresenter getMeetingList];
    [_tableView reloadData];
}


@end
