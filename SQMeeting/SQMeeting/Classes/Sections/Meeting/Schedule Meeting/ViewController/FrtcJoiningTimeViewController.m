#import "FrtcJoiningTimeViewController.h"
#import "FrtcScheduleCustomListView.h"
#import "FrtcScheduleMeetingPresenter.h"
#import "Masonry.h"

@interface FrtcJoiningTimeViewController () <FrtcScheduleMeetingProtocol>

@property (nonatomic, strong) FrtcScheduleCustomListView *customListView;;
@property (nonatomic, strong) FrtcScheduleMeetingPresenter *presenter;

@end

@implementation FrtcJoiningTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = FLocalized(@"meeting_early_joining_time", nil);
    [self.presenter getJoiningTimeDataWithTime:_joiningTime];
}

- (void)configUI {
    [self.customListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - FrtcScheduleMeetingProtocol

- (void)responseJoiningTimeListData:(NSArray<FrtcScheduleCustomModel *>* _Nullable)result {
    self.customListView.customListData = result;
}

#pragma mark - lazy

- (FrtcScheduleMeetingPresenter *) presenter {
    if (!_presenter) {
        _presenter = [FrtcScheduleMeetingPresenter new];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (FrtcScheduleCustomListView *) customListView {
    if (!_customListView) {
        _customListView = [FrtcScheduleCustomListView new];
        @WeakObj(self);
        _customListView.customListCallBack = ^(NSString * _Nonnull result) {
            @StrongObj(self)
            if (self.joiningTimeResultCallBack) {
                self.joiningTimeResultCallBack(result);
            }
        };
        [self.contentView addSubview:_customListView];
    }
    return _customListView;
}

@end

