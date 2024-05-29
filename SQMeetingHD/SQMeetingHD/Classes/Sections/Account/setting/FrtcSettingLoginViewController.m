#import "FrtcSettingLoginViewController.h"
#import "HDStatusTableViewCell.h"
#import "PopUpHDViewController.h"
#import "PopUpHDRateController.h"
#import "FrtcUserDefault.h"
#import "FrtcCall.h"
#import "FrtcManagement.h"
#import "UIImage+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "FrtcLanguageSettingViewController.h"
#import "NSBundle+FLanguage.h"
#import "FrtcUserModel.h"
#import "FrtcSignLoginPresenter.h"
#import "AppDelegate.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcHDAccountUpdatePsdVC.h"
#import "FrtcMeetingReminderDataManager.h"
#import "FrtcFeedbackViewController.h"
#import "UINavigationItem+Extensions.h"
#import "FrtcMyRecordViewController.h"

@interface FrtcSettingLoginViewController ()<UITableViewDelegate, UITableViewDataSource, PopUpHDViewControllerDelegate,PopUpHDRateControllerDelegate,HDStatusTableViewCellDelegate,FrtcSignLoginProtocol>

@property (strong, nonatomic) UITableView *statusTableView;
@property (nonatomic, strong) UIButton *serviceAgreementBtn;
@property (nonatomic, strong) UIButton *agreementBtn;

@end

@implementation FrtcSettingLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"app_settings", nil);
    @WeakObj(self);
    [self.navigationItem initWithLeftButtonTitleCallBack:^{
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:^{        }];
    }];
    
    [self configTableView];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)configTableView {
    self.statusTableView.backgroundColor = KBGColor;
    [self.statusTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-60);
    }];
    
    [self.agreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.serviceAgreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.agreementBtn.mas_top).offset(-10);
        make.centerX.equalTo(self.contentView);
    }];
}

#pragma mark- PopUpViewControllerDelegate
- (void)saveNewAddress:(NSString *)newServerAddress {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    HDStatusTableViewCell *selectCell = (HDStatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    selectCell.detailLabel.text = newServerAddress;
}

#pragma mark- PopUpRateControllerDelegate
- (void)saveNewCallRate:(NSString *)newCallRate {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    HDStatusTableViewCell *selectCell = (HDStatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    selectCell.detailLabel.text = newCallRate;
    [[FrtcUserDefault sharedUserDefault] setObject:newCallRate forKey:CALL_RATE];
}

#pragma mark- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 1;
    if (section == 0) {
        count = 2;
    }else if (section == 3) {
        count = 3;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HDStatusTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
    cell.detailLabel.textColor = KDetailTextColor;
    cell.valueChangeBlock = ^(BOOL isOn) {
        if (indexPath.section == 0 ) {
            [FrtcLocalInforDefault saveNoiseSwitch:isOn];
            [[FrtcCall frtcSharedCallClient] frtcIntelligentDenoise:isOn];
        }else if (indexPath.section == 1) {
            FrtcMeetingReminderDataManager.acceptMeetingReminders = !isOn;
        }
    };
    
    NSString *server_address = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];

    if (indexPath.section == 0) {
        if([indexPath row] == 0) {
            cell.nameLabel.text = NSLocalizedString(@"server_address", nil);
            cell.detailLabel.text = server_address;
            cell.isShowRightView = YES;
            cell.signOutButton.hidden = YES;
        } else if([indexPath row] == 1) {
            cell.nameLabel.text = NSLocalizedString(@"setting_reduction", nil);
            cell.isShowRightView = NO;
            cell.noiseSwitch.hidden = NO;
            cell.noiseSwitch.on = [FrtcLocalInforDefault getNoiseSwitch];
            cell.signOutButton.hidden = YES;
        }
    }
    
    if (indexPath.section == 1) {
        cell.nameLabel.text  = NSLocalizedString(@"MEETING_REMINDER_ACCEPTMEETING", nil);
        cell.isShowRightView = NO;
        cell.noiseSwitch.hidden   = NO;
        cell.signOutButton.hidden = YES;
        cell.noiseSwitch.on = FrtcMeetingReminderDataManager.acceptMeetingReminders;
    }
    
    if (indexPath.section == 2) {
        cell.nameLabel.text = NSLocalizedString(@"FM_VIDEO_MY_RECORDING", nil);
        cell.detailLabel.text = @"";
        cell.isShowRightView = YES;
        cell.signOutButton.hidden = YES;
    }
    
    if (indexPath.section == 3) {
        cell.isShowRightView = YES;
        if (indexPath.row == 0) {
            cell.nameLabel.text = NSLocalizedString(@"Account", nil);
            cell.detailLabel.text = [FrtcUserModel fetchUserInfo].username;
            cell.isShowRightView = NO;
            cell.signOutButton.hidden = YES;
        }else if(indexPath.row == 1) {
            cell.nameLabel.text = NSLocalizedString(@"display_name_join_meeting", nil);
            NSString *userName = [FrtcUserModel fetchUserInfo].real_name;//;
            cell.detailLabel.text = userName;
            cell.isShowRightView = NO;
            cell.signOutButton.hidden = YES;
        } else if(indexPath.row == 2) {
            cell.nameLabel.text = NSLocalizedString(@"set_pwd", nil);
            cell.signOutButton.hidden = YES;
        }
    }
    
    if (indexPath.section == 4) {
        cell.nameLabel.text = NSLocalizedString(@"language", nil);
        cell.detailLabel.text = [NSBundle currentLanguageDes];
        cell.isShowRightView = YES;
        cell.signOutButton.hidden = YES;
    }
    
    if (indexPath.section == 5) {
        cell.nameLabel.text = NSLocalizedString(@"MEETING_LOG_TITLE", nil);
        cell.signOutButton.hidden = YES;
    }
 
    if (indexPath.section == 6) {
        cell.nameLabel.text = NSLocalizedString(@"app_version", nil);
        cell.isShowRightView = NO;
        cell.signOutButton.hidden = YES;
        cell.detailLabel.text = CUR_BUILD_VERSION;
    }
    
    if (indexPath.section == 7) {
        cell.delegate = self;
        cell.nameLabel.text = @"";
        cell.isShowRightView = NO;
        cell.noiseSwitch.hidden = YES;
        cell.signOutButton.hidden = NO;
    }
    
    return cell;
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if([indexPath row] == 0) {
            PopUpHDViewController *vc = [PopUpHDViewController new];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == 2 ) {
        FrtcMyRecordViewController *myRecordVC = [[FrtcMyRecordViewController alloc]init];
        [self.navigationController pushViewController:myRecordVC animated:YES];
    }
    
    if (indexPath.section == 3 && indexPath.row == 2) {
        FrtcHDAccountUpdatePsdVC *updatePsdvc = [[FrtcHDAccountUpdatePsdVC alloc]init];
        [self.navigationController pushViewController:updatePsdvc animated:YES];
    }
    
    if (indexPath.section == 4) {
        FrtcLanguageSettingViewController *languageVC = [[FrtcLanguageSettingViewController alloc]init];
        [self.navigationController pushViewController:languageVC animated:YES];
    }
    
    if (indexPath.section == 5) {
        FrtcFeedbackViewController *feedbackVC = [[FrtcFeedbackViewController alloc]init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
}

#pragma mark - StatusTableViewCellDelegate

- (void)signOut {
    FrtcSignLoginPresenter *presenter = [[FrtcSignLoginPresenter alloc]init];
    [presenter bindView:self];
    [presenter requestLogOut];
}

#pragma mark - FrtcSignLoginProtocol

- (void)responseLogOutResultWithSuccess:(BOOL)result errMsg:(NSString *)errMsg {
    if (result) {
        AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [myAppDelegate setEntryViewRootViewController];
    }else{
        [MBProgressHUD showMessage:errMsg];
    }
}

#pragma mark- lazy load

- (UITableView *)statusTableView {
    if(!_statusTableView) {
        _statusTableView = [[UITableView alloc] init ];
        _statusTableView.delegate    = self;
        _statusTableView.dataSource  = self;
        _statusTableView.rowHeight   = Status_Cell_Height;
        _statusTableView.sectionHeaderHeight = 8;
        _statusTableView.sectionFooterHeight = 0.01;
        _statusTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        [_statusTableView registerClass:[HDStatusTableViewCell class] forCellReuseIdentifier:@"UITableViewCellIdentifier"];
        if (@available(iOS 15.0, *)) { [_statusTableView setSectionHeaderTopPadding:0.0f]; }
        [self.contentView addSubview:_statusTableView];
    }
    return _statusTableView;
}

- (UIButton *)serviceAgreementBtn{
    if (!_serviceAgreementBtn) {
        _serviceAgreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_serviceAgreementBtn setTitle:[NSString stringWithFormat:@"%@ https://shenqi.isgo.com",FLocalized(@"app_website_url", nil)] forState:UIControlStateNormal];
        [_serviceAgreementBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _serviceAgreementBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_serviceAgreementBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://shenqi.isgo.com"]];
#pragma clang diagnostic pop
        }];
        [self.contentView addSubview:_serviceAgreementBtn];
    }
    return _serviceAgreementBtn;
}

- (UIButton *)agreementBtn {
    if (!_agreementBtn) {
        _agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreementBtn setTitle:[NSString stringWithFormat:@"%@ https://github.com/sqmeeting",FLocalized(@"app_Github_url", nil)] forState:UIControlStateNormal];
        [_agreementBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _agreementBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_agreementBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/sqmeeting"]];
#pragma clang diagnostic pop
        }];
        [self.contentView addSubview:_agreementBtn];
    }
    return _agreementBtn;
}
@end
