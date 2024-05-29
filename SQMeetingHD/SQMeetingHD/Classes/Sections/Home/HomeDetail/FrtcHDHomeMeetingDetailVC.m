#import "FrtcHDHomeMeetingDetailVC.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIViewController+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcMakeCallClient.h"
#import "FrtcUserModel.h"
#import "FrtcHDHomeDetailTableViewCell.h"
#import "UIView+Toast.h"

#define KHomeMeetingDetailCellId @"KHomeMeetingDetailCellId"
#define KButtonTag 0xea1

@interface FrtcHDHomeMeetingDetailVC () <UITableViewDelegate,UITableViewDataSource,FrtcHomeMeetingDetailProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FrtcHomeMeetingListPresenter *presenter;
@property (nonatomic, strong) NSArray<FHomeDetailMeetingInfo *> *dataSore;
@property (nonatomic, weak) UIButton *temporaryButton;

@end

@implementation FrtcHDHomeMeetingDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"meeting_details", nil);
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
    KUpdateHomeView
}

- (void)configUI {
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
}

- (void)setMeetingIofo:(FHomeMeetingListModel *)meetingIofo {
    _meetingIofo = meetingIofo;
    [self.presenter requestHomeDetailDataWithInfo:meetingIofo];
}

#pragma mark - FrtcHomeMeetingDetailProtocol

- (void)loadHomeDetailDataWithList:(NSArray<FHomeDetailMeetingInfo *> *)ListData {
    _dataSore = ListData;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) { return 2; }
    return _dataSore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FrtcHDHomeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KHomeMeetingDetailCellId forIndexPath:indexPath];
        FHomeDetailMeetingInfo *info = _dataSore[indexPath.row];
        cell.info = info;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellMeeting"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = UIColor.clearColor;
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
            UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelBtn.frame = CGRectMake(KLeftSpacing, 10, self.tableView.bounds.size.width - KLeftSpacing * 2, 50);
            [cancelBtn setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateNormal];
            [cancelBtn setBackgroundImage:[UIImage imageFromColor:KBGColor] forState:UIControlStateHighlighted];
            @WeakObj(self);
            [cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                @StrongObj(self)
                [self didClickCellBtnAction:indexPath];
            }];
            cancelBtn.tag = KButtonTag;
            cancelBtn.layer.masksToBounds = YES;
            cancelBtn.layer.cornerRadius = KCornerRadius * 2;
            cancelBtn.layer.borderColor  = KLineColor.CGColor;
            cancelBtn.layer.borderWidth  = 1;
            [cell.contentView addSubview:cancelBtn];
        }
        UIButton *customBtn = (UIButton *)[cell viewWithTag:KButtonTag];
        if (indexPath.row == 0) {
            self.temporaryButton = customBtn;
            [customBtn setTitle:NSLocalizedString(@"start_meeting", nil) forState:UIControlStateNormal];
            [customBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        }else{
            [customBtn setTitle:NSLocalizedString(@"meeting_delete", nil) forState:UIControlStateNormal];
            [customBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        }
        return cell;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Btn action

- (void)didClickCellBtnAction:(NSIndexPath *)indexPath {
    @WeakObj(self);
    if (indexPath.section == 1 && indexPath.row == 1) { //delegate meeting
        [self showAlertWithTitle:NSLocalizedString(@"meeting_delete_m", nil) message:NSLocalizedString(@"meeting_alert_delete", nil) buttonTitles:@[NSLocalizedString(@"call_cancel", nil),NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
            if (index == 1) {
                @StrongObj(self)
                [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                [FrtcHomeMeetingListPresenter deleteHistoryMeetingWithMeetingStartTime:self.meetingIofo.meetingStartTime];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController.view hideToastActivity];
                    [self dismissViewControllerAnimated:YES completion:^{
                        KUpdateHomeView
                    }];
                });
            }
        }];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0 ) {
        self.temporaryButton.enabled = NO;
        [self configCallParameter];
    }
}


#pragma mark - config join Meeting
- (void)configCallParameter{
    NSString *conferenceCallRate = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
    FRTCSDKCallParam callParam;
    callParam.conferenceNumber = _meetingIofo.meetingNumber;
    NSString *displayName = [FrtcUserModel fetchUserInfo].real_name;
    callParam.clientName = displayName;
    callParam.callRate = numberCallRate;
    callParam.muteCamera = YES;
    callParam.muteMicrophone = YES;
    callParam.audioCall = NO;
    if (isLoginSuccess) {
        callParam.userToken = [FrtcUserModel fetchUserInfo].user_token;
    }
    if (!kStringIsEmpty(_meetingIofo.meetingPassword)) {
        callParam.password = _meetingIofo.meetingPassword;
    }
    [self joinMeetingWithCallParam:callParam];
}

- (void)joinMeetingWithCallParam:(FRTCSDKCallParam)callParam {
    if (![FrtcHelpers isNetwork]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        self.temporaryButton.enabled = YES;
        return;
    }
    if ([FrtcHelpers f_isInMieeting]) {
        self.temporaryButton.enabled = YES;
        return;
    }
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @WeakObj(self);
    [[FrtcMakeCallClient sharedSDKContext] makeCall:self withCallParam:callParam withCallSuccessBlock:^{
        [self.navigationController.view hideToastActivity];
        self.temporaryButton.enabled = YES;
    } withCallFailureBlock:^(FRTCMeetingStatusReason status, NSString * _Nonnull errMsg) {
        if (kStringIsEmpty(errMsg)) { return; }
        @StrongObj(self)
        [self.navigationController.view hideToastActivity];
        self.temporaryButton.enabled = YES;
    } withInputPassCodeCallBack:^{
        @StrongObj(self)
        [self.navigationController.view hideToastActivity];
        self.temporaryButton.enabled = YES;
        [self showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil) textFieldStyle:FTextFieldPassword alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
            if (index == 1) {
                [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:alertString];
                [[FrtcUserDefault sharedUserDefault] setObject:alertString forKey:MEETING_PASSWORD];
            }else{
                [[FrtcCall frtcSharedCallClient] frtcHangupCall];
            }
        }];
    }];
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FrtcHDHomeDetailTableViewCell class] forCellReuseIdentifier:KHomeMeetingDetailCellId];
        _tableView.rowHeight = KHomeDtailCellHeight;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = KBGColor;
        _tableView.sectionFooterHeight = 20;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (FrtcHomeMeetingListPresenter *)presenter {
    if (!_presenter) {
        _presenter = [FrtcHomeMeetingListPresenter new];
        [_presenter bindView:self];
    }
    return _presenter;
}

@end
