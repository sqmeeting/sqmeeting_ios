#import "FrtcHDHomeViewController.h"
#import "FrtcHDHomeTopView.h"
#import "FrtcHDHomeMeetingListView.h"
#import "FrtcHDHomeMeetingListHeaderView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIViewController+Extensions.h"
#import "Appdelegate.h"
#import "SettingHDViewController.h"
#import "FrtcSignLoginPresenter.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcUserModel.h"
#import "FrtcScheduleMeetingViewController.h"
#import "FrtcAlertView.h"

#import "TYTabPagerView.h"
#import "FrtcHomeScheduleListView.h"
#import "MJRefresh.h"
#import "FrtcScheduleShareMeetingView.h"

#define KHomeMeetingListViewId @"HomeMeetingListView"
#define KHomeScheduleListViewId @"HomeScheduleListViewId"

@interface FrtcHDHomeViewController ()<TYTabPagerViewDataSource, TYTabPagerViewDelegate>
{
    NSInteger _currentPage;
}

@property (nonatomic, strong) UIButton *navLeftBtn;
@property (nonatomic, strong) FrtcHDHomeTopView *topHomeView ;
@property (nonatomic, strong) FrtcHomeScheduleListView *scheduleListView ;
@property (nonatomic, strong) FrtcHDHomeMeetingListView *historyListView ;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) TYTabPagerView *pagerView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation FrtcHDHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTokenFailureView:) name:kTokenFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHomeView:) name:kUPDATEHOMEVIEWNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeetingList:) name:kRefreshHomeMeetingListNotification object:nil];
    [self configUI];
    [self updateHomeView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTokenFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUPDATEHOMEVIEWNotification object:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - UI

- (void)configUI {
    ///nav
    @WeakObj(self)
    [self.navLeftBtn setTitle:NSLocalizedString(@"app_title", nil) forState:UIControlStateNormal];
    self.navLeftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *leftViewItem = [[UIBarButtonItem alloc] initWithCustomView:self.navLeftBtn];
    self.navigationItem.leftBarButtonItem = leftViewItem;
    
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [settingsBtn setImage:[UIImage imageNamed:@"icon_setting"]forState:UIControlStateNormal];
    [settingsBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [settingsBtn.imageView setTintColor:UIColor.grayColor];
    [settingsBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self goSetting];
    }];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [scanButton setImage:[UIImage imageNamed:@"icon_scan"]forState:UIControlStateNormal];
    [scanButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [scanButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self goScan];
    }];
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:settingsItem,scanItem,nil]];
    
    [self.topHomeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.top.mas_offset(KNavBarHeight);
        make.height.mas_equalTo(180);
    }];
    
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KHomeMeetingLeftSpacing);
        make.right.mas_equalTo(-KHomeMeetingLeftSpacing);
        make.bottom.mas_equalTo(0);
        make.top.equalTo(self.topHomeView.mas_bottom).mas_offset(10);
    }];
    
    [self.pagerView reloadData];
    
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pagerView.tabBar);
        make.right.mas_equalTo(-KHomeMeetingLeftSpacing);
        make.width.mas_equalTo(100);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.pagerView.tabBar.mas_bottom).offset(-1);
    }];
}


#pragma mark - action

- (void)goAccount {
    UIViewController *vc = [[NSClassFromString(@"FrtcHDAccountController") alloc]init];
    [self presentHDViewController:vc animated:YES completion:^{ }];
}

- (void)goSetting {
    UIViewController *vc = [[NSClassFromString(@"FrtcSettingLoginViewController") alloc]init];
    [self presentHDViewController:vc animated:YES completion:^{ }];
}

- (void)goScan {
    UIViewController *vc = [[NSClassFromString(@"FrtcHDScanQRViewController") alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goNewMeeting {
    UIViewController *vc = [[NSClassFromString(@"FrtcHDNewMeetingViewController") alloc]init];
    [self presentHDViewController:vc animated:YES completion:^{ }];
}

- (void)joinTheMeeting {
    UIViewController *vc = [[NSClassFromString(@"FrtcHDCallViewController") alloc]init];
    [self presentHDViewController:vc animated:YES completion:^{ }];
}

- (void)goScheduleMeeting {
    FrtcScheduleMeetingViewController *vc = [[FrtcScheduleMeetingViewController alloc]init];
    @WeakObj(self);
    vc.createRecurrenceMeetingSuccess = ^(FrtcScheduleDetailModel * _Nonnull model) {
        @StrongObj(self)
        [self->_scheduleListView.tableView.mj_header beginRefreshing];
        [FrtcScheduleShareMeetingView showScheduleShareMeetingViewModel:model block:^{
            
        }];
    };
    [self presentHDViewController:vc animated:YES completion:^{ }];
}


- (void)clickTopViewWithIndex:(NSInteger)index {
    if (index == 0) {
        [self goNewMeeting];
    }else if (index == 1) {
        [self joinTheMeeting];
    }else if (index == 2) {
        [self goScheduleMeeting];
    }
}

- (NSString *)getDisplayName {
    NSString *displayName = [FrtcUserModel fetchUserInfo].real_name;
    if (displayName.length > 20) {
        displayName = [[displayName substringToIndex:20] stringByAppendingString:@"..."];
    }
    return displayName;
}

#pragma mark - Notification
- (void)alertTokenFailureView:(NSNotification *)notification {
    [FrtcAlertView showAlertViewWithTitle:NSLocalizedString(@"logout_notifica", nil) message:NSLocalizedString(@"login_again_notifica", nil) buttonTitles:@[NSLocalizedString(@"ok", nil)] didSelectCallBack:^(NSInteger index) {
        AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [myAppDelegate setEntryViewRootViewController];
    }];
}

- (void)updateHomeView:(NSNotification *)notification {
    [FrtcSignLoginPresenter refreshUserToken];
    if (_historyListView && _currentPage == 1) {
        self.clearButton.hidden = [FrtcHomeMeetingListPresenter getMeetingList].count <= 0 ? YES : NO;
        [_historyListView reloadTableView];
    }
}

- (void)refreshMeetingList:(NSNotification *)notification {
    if (self.scheduleListView) {
        [self.scheduleListView.tableView.mj_header beginRefreshing];
    }
}

#pragma mark - TYTabPagerViewDataSource

- (NSInteger)numberOfViewsInTabPagerView {
    return 2;
}

- (UIView *)tabPagerView:(TYTabPagerView *)tabPagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    if (index == 1) {
        FrtcHDHomeMeetingListView *meetingListView = (FrtcHDHomeMeetingListView *)[tabPagerView dequeueReusablePagerCellWithReuseIdentifier:KHomeMeetingListViewId forIndex:index];
        [meetingListView reloadTableView];
        _historyListView = meetingListView;
        return meetingListView;
    }else{
        FrtcHomeScheduleListView *scheduleView = (FrtcHomeScheduleListView *)[tabPagerView dequeueReusablePagerCellWithReuseIdentifier:KHomeScheduleListViewId forIndex:index];
        _scheduleListView = scheduleView;
        return scheduleView;
    }
}

- (NSString *)tabPagerView:(TYTabPagerView *)tabPagerView titleForIndex:(NSInteger)index {
    return (index == 0 ? NSLocalizedString(@"meeting_schedule_meeting", nil) : NSLocalizedString(@"history_meeting", nil));
}

- (void)tabPagerView:(TYTabPagerView *)tabPagerView didDisappearView:(UIView *)view forIndex:(NSInteger)index {
    if (index == 1) {
        _currentPage = 0;
        self.clearButton.hidden = YES;
    }else {
        _currentPage = 1;
        self.clearButton.hidden = [FrtcHomeMeetingListPresenter getMeetingList].count <= 0 ? YES : NO;
    }
}

#pragma mark - lazy

- (FrtcHDHomeTopView *)topHomeView {
    if (!_topHomeView) {
        @WeakObj(self);
        _topHomeView = [[FrtcHDHomeTopView alloc]init];
        _topHomeView.clickBtnBlock = ^(NSInteger index) {
            @StrongObj(self)
            [self clickTopViewWithIndex:index];
        };
        [self.view addSubview:_topHomeView];
    }
    return _topHomeView;
}

- (UIButton *)navLeftBtn {
    if (!_navLeftBtn) {
        _navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navLeftBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        _navLeftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        [_navLeftBtn setImage:[UIImage imageNamed:@"icon_shenqilogo"] forState:UIControlStateNormal];
        [_navLeftBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 3, 0)];
        _navLeftBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _navLeftBtn;
}


- (TYTabPagerView *)pagerView {
    if (!_pagerView) {
        _pagerView = [[TYTabPagerView alloc]init];
        _pagerView.backgroundColor = UIColor.whiteColor;
        _pagerView.tabBarHeight = 50;
        _pagerView.tabBar.collectionView.backgroundColor = UIColor.whiteColor;
        _pagerView.tabBar.progressView.backgroundColor = UIColor.whiteColor;
        [_pagerView.tabBar.progressView addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_page_line"]]];
        _pagerView.tabBar.layout.cellSpacing = 50;
        if (@available(iOS 16.0, *)) {
            _pagerView.tabBar.layout.progressVerEdging = -50;
        }
        _pagerView.tabBar.layout.barStyle = TYPagerBarStyleProgressView;
        _pagerView.tabBar.layout.selectedTextColor = KTextColor;
        _pagerView.tabBar.layout.selectedTextFont  = [UIFont systemFontOfSize:16];
        _pagerView.tabBar.layout.normalTextFont    = [UIFont systemFontOfSize:16];
        _pagerView.tabBar.layout.normalTextColor   = KDetailTextColor;
        [_pagerView registerClass:[FrtcHDHomeMeetingListView class] forPagerCellWithReuseIdentifier:KHomeMeetingListViewId];
        [_pagerView registerClass:[FrtcHomeScheduleListView class] forPagerCellWithReuseIdentifier:KHomeScheduleListViewId];
        _pagerView.dataSource = self;
        _pagerView.delegate   = self;
        [self.view addSubview:_pagerView];
    }
    return _pagerView;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setImage:[UIImage imageNamed:@"home_meeting_delegate"] forState:UIControlStateNormal];
        [_clearButton setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
        _clearButton.hidden = YES;
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_clearButton setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        _clearButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        _clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        @WeakObj(self);
        [_clearButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self showAlertWithTitle:NSLocalizedString(@"clear_history", nil) message:NSLocalizedString(@"clear_history_detail", nil) buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
                if (index == 0) { return; }
                if ([FrtcHomeMeetingListPresenter deleteAllMeeting]) {
                    self->_clearButton.hidden = YES;
                    [self->_historyListView reloadTableView];
                }
            }];
        }];
        [self.view addSubview:_clearButton];
    }
    return _clearButton;
}

- (UIView *) lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = KLineColor;
        [self.view addSubview:_lineView];
    }
    return _lineView;
}
@end
