#import "FrtcScheduleCustomListView.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcScheduleCustomTableViewCell.h"
#import "FrtcScheduleCustomModel.h"

#define KCustomTableViewCellIdentifier @"FrtcScheduleCustomTableViewCell"

@interface FrtcScheduleCustomListView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation FrtcScheduleCustomListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self scheduleCustomListViewLayout];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)scheduleCustomListViewLayout {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
}

- (void)setCustomListData:(NSArray<FrtcScheduleCustomModel *> *)customListData {
    _customListData = customListData;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _customListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcScheduleCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KCustomTableViewCellIdentifier forIndexPath:indexPath];
    FrtcScheduleCustomModel *info = _customListData[indexPath.row];
    cell.model = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for (FrtcScheduleCustomModel *info in _customListData) {
        info.isSelect = NO;
    }
    FrtcScheduleCustomModel *info = _customListData[indexPath.row];
    info.isSelect = YES;
    [self.tableView reloadData];
    
    if (self.customListCallBack) {
        self.customListCallBack(info.title);
    }
    
    [[FrtcHelpers getCurrentVC].navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = KBGColor;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcScheduleCustomTableViewCell class] forCellReuseIdentifier:KCustomTableViewCellIdentifier];
        _tableView.rowHeight = 50;
        _tableView.sectionFooterHeight = 0.001;
        _tableView.sectionHeaderHeight = 10;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 15.0, *)) { [_tableView setSectionHeaderTopPadding:0.0f]; }
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
