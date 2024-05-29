#import "FrtcScheduleMeetingViewController.h"
#import "FrtcScheduleMeetingListView.h"
#import "FrtcScheduleMeetingPresenter.h"
#import "Masonry.h"
#import "UINavigationItem+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcScheduleDetailModel.h"
#import "UIImage+Extensions.h"

@interface FrtcScheduleMeetingViewController () <FrtcScheduleMeetingProtocol,FrtcScheduleMeetingListViewDelegate>

@property (nonatomic, strong) FrtcScheduleMeetingListView *scheduleListView;
@property (nonatomic, strong) FrtcScheduleMeetingPresenter *schedulePresenter;
@property (nonatomic, strong) UIButton *reserveButton;

@end

@implementation FrtcScheduleMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"schedule_meeting", nil);
    [self.schedulePresenter loadLocalScheduleMeetingListDataWithDetailModel:self.isEditing  ? _detailInfo : nil];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)configUI {
    
    [self.scheduleListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-100);
    }];
    
    [self.reserveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(kButtonHeight);
        make.bottom.mas_equalTo(-KSafeAreaBottomHeight-10);
    }];
}

#pragma mark - UIButton action

- (void)didClickReserveButton:(UIButton *)button {
    
    [self.view endEditing:YES];
    
    if (self.isEditing) {
        [self.schedulePresenter requestUpdateNonRecurrenceMeetingWithModel:self.detailInfo];
    }else{
        [self.schedulePresenter requestCreateNonRecurrenceMeeting];
    }
}

#pragma mark - FrtcScheduleMeetingProtocol

- (void)responseScheduleMeetingListSuccess:(NSArray<NSArray *> *)result errMsg:(NSString *)errMsg {
    if (!errMsg) {
        self.scheduleListView.scheduleListData = result;
    }
}

- (void)responseScheduleMeetingSuccess:(FrtcScheduleDetailModel * _Nullable)model errMsg:(NSString * _Nullable)errMsg {
    if (!errMsg) {
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_schedule_success", nil)];
        if (self.createRecurrenceMeetingSuccess) {
            self.createRecurrenceMeetingSuccess(model);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [MBProgressHUD showMessage:errMsg];
    }
}

- (void)responseupdateNonRecurrenceMeeting:(FrtcScheduleDetailModel * _Nullable)model  errMsg:(NSString * _Nullable)errMsg {
    if (!errMsg) {
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_update_success", nil)];
        if (self.updateRecurrenceMeetingSuccess) {
            NSString *reservationId = kStringIsEmpty(model.reservation_id) ? self.detailInfo.reservation_id : model.reservation_id;
            self.updateRecurrenceMeetingSuccess(reservationId);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [MBProgressHUD showMessage:errMsg];
    }
}

#pragma mark - FrtcScheduleMeetingListViewDelegate

- (void)updateScheduleListViewWithInfo:(NSString *)info indexPath:(NSIndexPath *)indexPath {
    [self.schedulePresenter changeScheduleMeetingListDataWith:indexPath content:info];
}

- (void)updateScheduleListSwitchStatusWithOpen:(BOOL)open indexPath:(NSIndexPath *)indexPath {
    [self.schedulePresenter changeScheduleMeetingListSwitchStatusWith:indexPath status:open];
}

- (void)updateScheduleListViewCustomInfo:(id)customInfo indexPath:(NSIndexPath *)indexPath {
    [self.schedulePresenter changeScheduleMeetingListCustomInfo:indexPath customInfo:customInfo];
}

- (void)addScheduleListCellIndexPath:(NSIndexPath *)indexPath {
    [self.schedulePresenter addLocalScheduleListDataWith:indexPath];
}

#pragma mark - lazy

- (FrtcScheduleMeetingListView *)scheduleListView {
    if (!_scheduleListView) {
        _scheduleListView = [FrtcScheduleMeetingListView new];
        _scheduleListView.delegate = self;
        _scheduleListView.edit = (self.isEditing && !kStringIsEmpty(self.detailInfo.meeting_room_id));
        [self.contentView addSubview:_scheduleListView];
    }
    return _scheduleListView;
}

- (FrtcScheduleMeetingPresenter *)schedulePresenter {
    if (!_schedulePresenter) {
        _schedulePresenter = [FrtcScheduleMeetingPresenter new];
        [_schedulePresenter bindView:self];
    }
    return _schedulePresenter;
}

- (UIButton *)reserveButton {
    if(!_reserveButton) {
        _reserveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reserveButton setTitle:self.isEditing ? FLocalized(@"recurrence_done", nil) : FLocalized(@"recurrence_Scheduled", nil) forState:UIControlStateNormal];
        [_reserveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reserveButton setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_reserveButton setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        _reserveButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_reserveButton addTarget:self action:@selector(didClickReserveButton:) forControlEvents:UIControlEventTouchUpInside];
        _reserveButton.layer.masksToBounds = YES;
        _reserveButton.layer.cornerRadius = KCornerRadius;
        [self.contentView addSubview:_reserveButton];
    }
    
    return _reserveButton;
}


@end
