#import "FrtcHomeViewController.h"
#import "FrtcHomeTopView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "FrtcHomeMeetingListView.h"
#import "FrtcHomeMeetingListHeaderView.h"
#import "UIControl+Extensions.h"
#import "FrtcSignLoginPresenter.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "UIViewController+Extensions.h"
#import "Appdelegate.h"
#import "SettingViewController.h"
#import "FrtcUserModel.h"
#import "TYTabPagerView.h"
#import "FrtcHomeScheduleListView.h"
#import "FrtcScheduleMeetingViewController.h"
#import "MJRefresh.h"
#import "FrtcScheduleShareMeetingView.h"
#import "FrtcCustomPresentationController.h"
#import "FrtcShareMeetingInfoViewController.h"

#define KHomeMeetingListViewId @"HomeMeetingListView"
#define KHomeScheduleListViewId @"HomeScheduleListViewId"

@interface FrtcHomeViewController () <TYTabPagerViewDataSource, TYTabPagerViewDelegate, UIViewControllerTransitioningDelegate>
{
    NSInteger _currentPage;
}
@property (nonatomic, strong) UIButton *navLeftBtn;
@property (nonatomic, strong) FrtcHomeTopView *topHomeView ;
@property (nonatomic, strong) TYTabPagerView *pagerView;
@property (nonatomic, strong) FrtcHomeScheduleListView *scheduleListView ;
@property (nonatomic, strong) FrtcHomeMeetingListView *historyListView ;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation FrtcHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTokenFailureView:) name:kTokenFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeetingList:) name:kRefreshHomeMeetingListNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [FrtcSignLoginPresenter refreshUserToken];
    if (_historyListView && _currentPage == 1) {
        self.clearButton.hidden = [FrtcHomeMeetingListPresenter getMeetingList].count <= 0 ? YES : NO;
        [_historyListView reloadTableView];
    }
    if (self.pagerView) {
        [self.pagerView scrollToViewAtIndex:_currentPage animate:NO];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTokenFailureNotification object:nil];
}

#pragma mark - UI

- (void)configUI {
    
    @WeakObj(self);
    [self.navLeftBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"app_title", nil)] forState:UIControlStateNormal];
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
        make.left.right.top.mas_offset(0);
        make.height.mas_equalTo(135);
    }];
    
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.topHomeView.mas_bottom).mas_offset(10);
    }];
    
    [self.pagerView reloadData];
    
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pagerView.tabBar);
        make.right.mas_equalTo(-KLeftSpacing);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.pagerView.tabBar.mas_bottom).offset(-1);
    }];
}

#pragma mark - action

- (void)goAccount {
    UIViewController *vc = [[NSClassFromString(@"FrtcAccountController") alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goSetting {
    UIViewController *vc = [[NSClassFromString(@"FrtcSettingLoginViewController") alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goScan {
    UIViewController *vc = [[NSClassFromString(@"FrtcScanQRViewController") alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goNewMeeting {
    UIViewController *vc = [[NSClassFromString(@"FrtcNewMeetingViewController") alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)joinTheMeeting {
    UIViewController *vc = [[NSClassFromString(@"FrtcCallViewController") alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
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
    [self.navigationController pushViewController:vc animated:YES];
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
    if (displayName.length > 15) {
        displayName = [[displayName substringToIndex:15] stringByAppendingString:@"..."];
    }
    return displayName;
}

- (void)showShareIinfoVew:(FrtcScheduleDetailModel *)model {
    FrtcShareMeetingInfoViewController *customViewController = [[FrtcShareMeetingInfoViewController alloc] init];
    customViewController.detailModel = model;
    customViewController.modalPresentationStyle = UIModalPresentationCustom;
    customViewController.transitioningDelegate = self;
    [self presentViewController:customViewController animated:NO completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                               presentingViewController:(UIViewController *)presenting
                                                                   sourceViewController:(UIViewController *)source {
    FrtcCustomPresentationController *customPresentationVc = [[FrtcCustomPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    customPresentationVc.presentedViewHeight = 400;
    return customPresentationVc;
}


#pragma mark - Notification
- (void)alertTokenFailureView:(NSNotification *)notification {
    [self showAlertWithTitle:NSLocalizedString(@"logout_notifica", nil) message:NSLocalizedString(@"login_again_notifica", nil) buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
        AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [myAppDelegate logOutSettingEntryRootView];
    }];
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
        FrtcHomeMeetingListView *meetingListView = (FrtcHomeMeetingListView *)[tabPagerView dequeueReusablePagerCellWithReuseIdentifier:KHomeMeetingListViewId forIndex:index];
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

- (FrtcHomeTopView *)topHomeView {
    if (!_topHomeView) {
        @WeakObj(self);
        _topHomeView = [[FrtcHomeTopView alloc]init];
        _topHomeView.clickBtnBlock = ^(NSInteger index) {
            @StrongObj(self)
            [self clickTopViewWithIndex:index];
        };
        [self.contentView addSubview:_topHomeView];
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
        _pagerView.tabBar.contentInset = UIEdgeInsetsMake(0, KLeftSpacing - 4, 0, 0 );
        _pagerView.tabBarHeight = 50;
        _pagerView.tabBar.collectionView.backgroundColor = UIColor.whiteColor;
        _pagerView.tabBar.progressView.backgroundColor = UIColor.whiteColor;
        [_pagerView.tabBar.progressView addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_page_line"]]];
        _pagerView.tabBar.layout.barStyle = TYPagerBarStyleProgressView;
        if (@available(iOS 16.0, *)) {
            _pagerView.tabBar.layout.progressVerEdging = -13;
        }
        _pagerView.tabBar.layout.cellSpacing = 15;
        _pagerView.tabBar.layout.selectedTextColor = KTextColor;
        _pagerView.tabBar.layout.selectedTextFont  = [UIFont systemFontOfSize:16];
        _pagerView.tabBar.layout.normalTextFont    = [UIFont systemFontOfSize:16];
        _pagerView.tabBar.layout.normalTextColor   = KDetailTextColor;
        [_pagerView registerClass:[FrtcHomeMeetingListView class] forPagerCellWithReuseIdentifier:KHomeMeetingListViewId];
        [_pagerView registerClass:[FrtcHomeScheduleListView class] forPagerCellWithReuseIdentifier:KHomeScheduleListViewId];
        _pagerView.dataSource = self;
        _pagerView.delegate   = self;
        [self.contentView addSubview:_pagerView];
    }
    return _pagerView;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
        _clearButton.hidden = YES;
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_clearButton setTitleColor:KDetailTextColor forState:UIControlStateNormal];
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
        [self.contentView addSubview:_clearButton];
    }
    return _clearButton;
}

- (UIView *) lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = KLineColor;
        [self.contentView addSubview:_lineView];
    }
    return _lineView;
}

@end
