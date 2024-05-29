#import "FrtcRequestUnmuteListViewController.h"
#import "FrtcRequestUnmuteListTableViewCell.h"
#import "UINavigationItem+Extensions.h"
#import "Masonry.h"
#import "UIViewController+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIStackView+Extensions.h"
#import "UITableView+Extensions.h"
#import "RosterPresenter.h"

@interface FrtcRequestUnmuteListViewController () <UITableViewDelegate,UITableViewDataSource,RosterViewProtocol>
{
    BOOL isAllData;
    FrtcRequestUnmuteModel *currentModel;
}
@property (nonatomic, strong) UITableView *unmuteListTableView;
@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) RosterPresenter *presenter;
@end

@implementation FrtcRequestUnmuteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"MEETING_ROSTER_UNMUTEREUQEST_LISTVIEW_TITLE", nil);
    self.view.backgroundColor = KBGColor;
    
    @WeakObj(self)
    [self.navigationItem initWithLeftButtonImage:@"nav_back_icon" back:^{
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.view addSubview:self.unmuteListTableView];
    [self.unmuteListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
    }];
    
    [self.view addSubview:self.okButton];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.bottom.mas_equalTo(-20);
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRequestUnmuteList:)
                                                 name:kUpdateRequestUnmuteList
                                               object:NULL];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateRequestUnmuteList object:nil];
}

- (void)updateRequestUnmuteList:(NSNotification *)notification {
    id request = [notification object];
    if ([request isKindOfClass:[NSArray class]]) {
        _requestUnmuteList = request;
        [self.unmuteListTableView reloadData];
    }
}

- (void)setRequestUnmuteList:(NSMutableArray<FrtcRequestUnmuteModel *> *)requestUnmuteList  {
    _requestUnmuteList = requestUnmuteList;
    [self.unmuteListTableView reloadData];
}

#pragma mark - RosterViewProtocol

- (void)requestUnmuteResultMsg:(NSString *)errMsg {
    if (!errMsg) {
        if (self->isAllData) {
            [self.requestUnmuteList removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUnmuteReuqestList
                                                                object:@{@"fullList":[NSNumber numberWithBool:YES],@"uuid":@""}];
        }else {
            [self.requestUnmuteList removeObject:self->currentModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUnmuteReuqestList
                                                                object:@{@"fullList":[NSNumber numberWithBool:NO],@"uuid":self->currentModel.uuid}];
        }
        [self.unmuteListTableView reloadData];
        
        if (self.requestUnmuteList.count == 0) {
            if (self.unmuteListCallBack) {
                self.unmuteListCallBack();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
}

#pragma mark - request

- (void)requestAllowUnmuteWithClients:(NSString *)clients {
    if (kStringIsEmpty(clients)) {
        self->isAllData = YES;
        NSMutableArray *list = [NSMutableArray array];
        for (FrtcRequestUnmuteModel *model in _requestUnmuteList) {
            [list addObject:model.uuid];
        }
        [self.presenter allowUnmuteWithMeetingNumber:self.meetingNumber parameters:list];
    }else{
        [self.presenter allowUnmuteWithMeetingNumber:self.meetingNumber parameters:@[clients]];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _requestUnmuteList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcRequestUnmuteListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrtcRequestUnmuteListTableViewCell" forIndexPath:indexPath];
    FrtcRequestUnmuteModel *model = _requestUnmuteList[indexPath.row];
    cell.nameLable.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrtcRequestUnmuteModel *model = _requestUnmuteList[indexPath.row];
    self->currentModel = model;
    self->isAllData = NO;
    [self requestAllowUnmuteWithClients:model.uuid];
}

#pragma mark - FTableViewDelegate

- (UIImage  *)f_noDataViewImage {
    return [UIImage imageNamed:@"meeting_unmute_nornl"];
}

- (NSString *)f_noDataViewMessage {
    return  NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_DEFAULT_CONTENT", nil);
}

#pragma mark - lazy

- (UITableView *)unmuteListTableView {
    if (!_unmuteListTableView) {
        _unmuteListTableView = [[UITableView alloc]init];
        _unmuteListTableView.backgroundColor = UIColor.whiteColor;
        _unmuteListTableView.delegate   = self;
        _unmuteListTableView.dataSource = self;
        _unmuteListTableView.backgroundColor = KBGColor;
        _unmuteListTableView.rowHeight = 45;
        [_unmuteListTableView registerClass:[FrtcRequestUnmuteListTableViewCell class] forCellReuseIdentifier:@"FrtcRequestUnmuteListTableViewCell"];
        _unmuteListTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 15.0, *)) { [_unmuteListTableView setSectionHeaderTopPadding:0.0f]; }
    }
    return _unmuteListTableView;
}

- (UIButton *)okButton {
    if (!_okButton) {
        @WeakObj(self);
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okButton setTitle:NSLocalizedString(@"MEETING_ROSTER_CELLVIEW_ALL_OK", nil) forState:UIControlStateNormal];
        [_okButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _okButton.layer.cornerRadius = 20;
        _okButton.layer.masksToBounds = YES;
        _okButton.backgroundColor = kMainColor;
        [_okButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self requestAllowUnmuteWithClients:@""];
        }];
    }
    return _okButton;
}

- (RosterPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[RosterPresenter alloc]init];
        [_presenter bindView:self];
    }
    return _presenter;
}
@end
