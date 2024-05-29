#import "FrtcHomeMeetingListView.h"
#import "Masonry.h"
#import "FrtcHomeMeetingListCell.h"
#import "FrtcHomeMeetingDetailViewController.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "UITableView+Extensions.h"

#define HomeMeetingListCellIdentifier @"HomeMeetingListCellIdentifier"

@interface FrtcHomeMeetingListView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *meetinglistdata;

@end

@implementation FrtcHomeMeetingListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.redColor;
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcHomeMeetingListCell class] forCellReuseIdentifier:HomeMeetingListCellIdentifier];
        _tableView.rowHeight = HomeMeetingListCellHeight;
        [self addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_meetinglistdata.count > 20) {
        return 20;
    }
    return _meetinglistdata.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FrtcHomeMeetingListCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeMeetingListCellIdentifier forIndexPath:indexPath];
    cell.info = _meetinglistdata[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrtcHomeMeetingDetailViewController *detailVC = [[FrtcHomeMeetingDetailViewController alloc]init];
    detailVC.meetingIofo = _meetinglistdata[indexPath.row];
    [[FrtcHelpers getCurrentVC].navigationController pushViewController:detailVC animated:YES];
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
