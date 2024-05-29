#import "FrtcMeetingInfoViewController.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "FrtcMeetingInfoLeftView.h"
#import "FrtcMeetingNetWorkView.h"
#import "TYTabPagerView.h"
#import "StaticsViewController.h"

NSString * const FMeetingInfoMediaStaticsInfoNotNotification = @"MEETINGINFOUPDATESTATICSMEDIAINFO";

@interface FrtcMeetingInfoViewController ()<TYTabPagerViewDataSource, TYTabPagerViewDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *crossBarView;
@property (nonatomic, strong) TYTabPagerView *pagerView;
@property (nonatomic, strong) FrtcMeetingInfoLeftView *infoLeftView;
@property (nonatomic, strong) FrtcMeetingNetWorkView *staticsView;

@end

@implementation FrtcMeetingInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self meetingInfoViewLayout];
    [self addMeetingInfoGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ISMLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updataMediaStaticsInfo:)
                                                 name:FMeetingInfoMediaStaticsInfoNotNotification object:nil];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
       
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //ISMLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FMeetingInfoMediaStaticsInfoNotNotification object:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(LAND_SCAPE_HEIGHT);
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - Notification

- (void)updataMediaStaticsInfo:(NSNotification *)cation {
    if ([[cation object] isKindOfClass:[FrtcMediaStaticsModel class]]) {
        _staticsMediaModel = (FrtcMediaStaticsModel *)[cation object];
        _staticsView.staticsMediaModel = _staticsMediaModel;
    }
}

#pragma mark - UI

- (void)meetingInfoViewLayout {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(LAND_SCAPE_HEIGHT * 0.7);
        make.width.mas_equalTo(LAND_SCAPE_HEIGHT);
        make.centerX.equalTo(self.view);
    }];
    
    [self.crossBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.centerX.equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(60, 4));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing * 0.6);
        make.right.mas_equalTo(-KLeftSpacing *0.6);
        make.top.equalTo(self.crossBarView.mas_bottom).mas_offset(14);
    }];
    
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(10);
    }];
    
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom).mas_offset(10);
        make.left.right.equalTo(self.titleLabel);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.bgView.superview layoutIfNeeded];
    [self.bgView setCornerRadius:KCornerRadius * 4 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)addMeetingInfoGesture {
    @WeakObj(self);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self dismissViewControllerAnimated:self completion:^{ }];
    }];
    [self.view addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *recognizerUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizerUp setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:recognizerUp];
    
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizerDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:recognizerDown];
}

#pragma mark - action

- (void)setMeetingInfo:(FHomeMeetingListModel *)meetingInfo {
    _meetingInfo = meetingInfo;
    _titleLabel.text = _meetingInfo.meetingName;
    _infoLeftView.meetingInfo = _meetingInfo;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self dismissViewControllerAnimated:self completion:^{ }];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) { }
}

-(void)changeIndex{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    [self.pagerView scrollToViewAtIndex:index animate:YES];
}

#pragma mark - TYTabPagerViewDataSource

- (NSInteger)numberOfViewsInTabPagerView {
    return 2;
}

- (UIView *)tabPagerView:(TYTabPagerView *)tabPagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    if (index == 1) {
        FrtcMeetingNetWorkView *networkView = (FrtcMeetingNetWorkView *)[tabPagerView dequeueReusablePagerCellWithReuseIdentifier:@"FrtcMeetingNetWorkView" forIndex:index];
        networkView.backgroundColor = UIColor.clearColor;
        @WeakObj(self);
        networkView.staticsInfoCallBack = ^{
            @StrongObj(self)
            StaticsViewController * staticsViewController = [[StaticsViewController alloc]init];
            staticsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            staticsViewController.conferenceName = self.meetingInfo.meetingName;
            staticsViewController.conferenceAlias = self.meetingInfo.meetingNumber;
            staticsViewController.staticsModel = self.staticsModel;
            [self presentViewController:staticsViewController animated:YES completion:^{

            }];
        };
        _staticsView = networkView;
        return networkView;
    }else{
        FrtcMeetingInfoLeftView *infoView = (FrtcMeetingInfoLeftView *)[tabPagerView dequeueReusablePagerCellWithReuseIdentifier:@"FrtcMeetingInfoLeftView" forIndex:index];
        infoView.backgroundColor = UIColor.clearColor;
        _infoLeftView = infoView;
        return infoView;
    }
}

- (NSString *)tabPagerView:(TYTabPagerView *)tabPagerView titleForIndex:(NSInteger)index {
    return (index == 0 ? @"1" : @"2");
}

- (void)tabPagerView:(TYTabPagerView *)tabPagerView didDisappearView:(UIView *)view forIndex:(NSInteger)index {
    self.segmentedControl.selectedSegmentIndex = index == 0 ? 1 : 0;
}

#pragma mark - lazy

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.layer.backgroundColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:0.95].CGColor;
        [self.view addSubview:_bgView];
    }
    return _bgView;
}

- (UIView *)crossBarView {
    if (!_crossBarView) {
        _crossBarView = [[UIView alloc]init];
        _crossBarView.backgroundColor = UIColorHex(0xcccccc);
        _crossBarView.layer.cornerRadius = 2.5;
        [self.bgView addSubview:_crossBarView];
    }
    return _crossBarView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc]initWithItems:@[NSLocalizedString(@"meeting_info", nil),NSLocalizedString(@"meeting_nerworkstate", nil)]];
        _segmentedControl.selectedSegmentTintColor = kMainColor;
        NSDictionary *dics = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
        [_segmentedControl setTitleTextAttributes:dics forState:UIControlStateNormal];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(changeIndex) forControlEvents:UIControlEventValueChanged];
        [self.bgView addSubview:_segmentedControl];
    }
    return _segmentedControl;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"";
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.bgView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (TYTabPagerView *)pagerView {
    if (!_pagerView) {
        _pagerView = [[TYTabPagerView alloc]init];
        _pagerView.tabBarHeight = 0;
        _pagerView.pageView.fullScreen = NO;
        _pagerView.tabBar.progressView.backgroundColor = UIColor.clearColor;
        [_pagerView registerClass:[FrtcMeetingInfoLeftView class] forPagerCellWithReuseIdentifier:@"FrtcMeetingInfoLeftView"];
        [_pagerView registerClass:[FrtcMeetingNetWorkView class] forPagerCellWithReuseIdentifier:@"FrtcMeetingNetWorkView"];
        _pagerView.dataSource = self;
        _pagerView.delegate   = self;
        [self.bgView addSubview:_pagerView];
    }
    return _pagerView;
}

@end
