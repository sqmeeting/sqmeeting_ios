#import "FrtcHDStaticsViewController.h"
#import "FrtcHDStaticsCallTypeView.h"
#import "FrtcHDStaticsTagView.h"
#import "Masonry.h"
#import "UIStackView+Extensions.h"
#import "StaticsTableViewCell.h"
#import "FrtcStatisticalModel.h"
#import "UIControl+Extensions.h"

#define StaticsTableCellIdentifier @"UITableViewCellIdentifier"

NSString * const FMeetingInfoStaticsInfoNotification = @"MEETINGINFOUPDATESTATICSINFO";

@interface FrtcHDStaticsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FrtcHDStaticsCallTypeView *callView;
@property (nonatomic, strong) FrtcHDStaticsTagView *tagView;
@property (strong, nonatomic) UITableView *staticsTableView;
@property (nonatomic) NSInteger staticsCount;
@property (nonatomic, strong) NSMutableArray<MediaDetailModel *> *mediaArray;

@property (nonatomic, copy) NSString *callType;
@property (nonatomic, copy) NSNumber *callRate;

@end


@implementation FrtcHDStaticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Demo_Meeting";
    self.view.backgroundColor = UIColor.whiteColor;
    [self configUI];
}

- (void)dealloc {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataStaticsInfo:) name:FMeetingInfoStaticsInfoNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FMeetingInfoStaticsInfoNotification object:nil];
}

#pragma mark - notification

- (void)updataStaticsInfo:(NSNotification *)cation {
    if ([[cation object] isKindOfClass:[FrtcStatisticalModel class]]) {
        [self handleStaticsEvent:(FrtcStatisticalModel *)[cation object]];
    }
}

#pragma mark - UI

- (void)configUI {
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setImage:[UIImage imageNamed:@"nav_back_icon"] forState:UIControlStateNormal];
    leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    @WeakObj(self);
    [leftBarButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.view addSubview:leftBarButton];
    [leftBarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(5);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = self.conferenceName;
    titleLabel.textColor = KTextColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(leftBarButton);
    }];
    
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.spacing = 0;
    stackView.backgroundColor = UIColor.redColor;
    stackView.axis = UILayoutConstraintAxisVertical;
    [self.view addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KNavBarHeight);
        make.bottom.right.left.mas_equalTo(0);
    }];
    
    [stackView addArrangedSubviews:@[self.callView,self.tagView,self.staticsTableView]];
    
    [self.callView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    [self handleStaticsEvent:self.staticsModel];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ISMLog(@"staticsCount = %td",_staticsCount);
    return _staticsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StaticsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StaticsTableCellIdentifier forIndexPath:indexPath];
    MediaDetailModel *model = _mediaArray[indexPath.row];
    [cell updateCellInfomation:model];
    cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? UIColorHex(0xf6f6f6) : UIColorHex(0xfbfbfb);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - action

- (void)handleStaticsEvent:(FrtcStatisticalModel *)staticsModel {
    
    self.callRate = staticsModel.signalStatistics.callRate;
    self.staticsCount =  staticsModel.mediaStatistics.apr.count + staticsModel.mediaStatistics.aps.count
    + staticsModel.mediaStatistics.vcr.count + staticsModel.mediaStatistics.vcs.count + staticsModel.mediaStatistics.vps.count + staticsModel.mediaStatistics.vpr.count ;
    
    self.callRate = staticsModel.signalStatistics.callRate;
    
    long rates = [self.callRate longValue];
    NSString *str;
    if (rates > 100000) {
        long rate1 = rates / 100000;
        long rate2 = rates % 100000;
        str = [NSString stringWithFormat:@" %ld / %ld", rate1, rate2];
    } else {
        str = [NSString stringWithFormat:@" %ld", rates];
    }
    self.callView.meetingNumberLabel.text = _conferenceAlias;
    self.callView.callRateLabel.text = str;
    
    
    _mediaArray = [NSMutableArray array];
    [_mediaArray removeAllObjects];
    [_mediaArray addObjectsFromArray:staticsModel.mediaStatistics.apr];
    [_mediaArray addObjectsFromArray:staticsModel.mediaStatistics.aps];
    [_mediaArray addObjectsFromArray:staticsModel.mediaStatistics.vpr];
    [_mediaArray addObjectsFromArray:staticsModel.mediaStatistics.vps];
    [_mediaArray addObjectsFromArray:staticsModel.mediaStatistics.vcr];
    [_mediaArray addObjectsFromArray:staticsModel.mediaStatistics.vcs];
    
    [self.staticsTableView reloadData];
}

#pragma mark - lazy

- (UITableView *)staticsTableView {
    if(!_staticsTableView) {
        _staticsTableView = [[UITableView alloc] init];
        _staticsTableView.delegate = self;
        _staticsTableView.dataSource = self;
        _staticsTableView.tableFooterView = [UIView new];
        _staticsTableView.estimatedRowHeight = 0;
        _staticsTableView.rowHeight = 40;
        _staticsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _staticsTableView.estimatedSectionHeaderHeight = 0;
        _staticsTableView.estimatedSectionFooterHeight = 0;
        [_staticsTableView registerClass:[StaticsTableViewCell class] forCellReuseIdentifier:StaticsTableCellIdentifier];
    }
    return _staticsTableView;
}

- (FrtcHDStaticsCallTypeView *)callView {
    if (!_callView) {
        _callView = [[FrtcHDStaticsCallTypeView alloc]init];
        _callView.backgroundColor = KBGColor;
    }
    return _callView;
}

- (FrtcHDStaticsTagView *)tagView {
    if (!_tagView) {
        _tagView = [[FrtcHDStaticsTagView alloc]init];
        _tagView.backgroundColor = UIColor.whiteColor;
    }
    return _tagView;
}

@end
