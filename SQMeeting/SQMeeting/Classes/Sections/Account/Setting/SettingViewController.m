#import "SettingViewController.h"
#import "StatusTableViewCell.h"
#import "PopUpViewController.h"
#import "PopUpRateController.h"
#import "FrtcUserDefault.h"
#import "FrtcCall.h"
#import "FrtcManagement.h"
#import "UIImage+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "FrtcLanguageSettingViewController.h"
#import "NSBundle+FLanguage.h"
#import "FrtcFeedbackViewController.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource, PopUpViewControllerDelegate,PopUpRateControllerDelegate>

@property (strong, nonatomic) UITableView *statusTableView;
@property (nonatomic, strong) UIButton *serviceAgreementBtn;
@property (nonatomic, strong) UIButton *agreementBtn;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"app_settings", nil);
    [self configTableView];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)configTableView {
    self.statusTableView.backgroundColor = KBGColor;
    [self.statusTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
    
    [self.agreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-50);
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
    StatusTableViewCell *selectCell = (StatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    selectCell.detailLabel.text = newServerAddress;
}

#pragma mark- PopUpRateControllerDelegate
- (void)saveNewCallRate:(NSString *)newCallRate {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    StatusTableViewCell *selectCell = (StatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    selectCell.detailLabel.text = newCallRate;
    [[FrtcUserDefault sharedUserDefault] setObject:newCallRate forKey:CALL_RATE];
}

#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StatusTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
    cell.detailLabel.textColor = KDetailTextColor;
    if([indexPath row] == 0) {
        cell.nameLabel.text = NSLocalizedString(@"server_address", nil);
        cell.detailLabel.text = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
        cell.isShowRightView = YES;
    } else if([indexPath row] == 1) {
        cell.nameLabel.text = NSLocalizedString(@"setting_reduction", nil);
        cell.isShowRightView = NO;
        cell.noiseSwitch.hidden = NO;
        cell.noiseSwitch.on = [FrtcLocalInforDefault getNoiseSwitch];
    } else if (indexPath.row == 2) {
        cell.nameLabel.text = NSLocalizedString(@"language", nil);
        cell.detailLabel.text = [NSBundle currentLanguageDes];
        cell.isShowRightView = YES;
    } else if([indexPath row] == 3) {
        cell.nameLabel.text = NSLocalizedString(@"MEETING_LOG_TITLE", nil);
        cell.isShowRightView = YES;
    } else if([indexPath row] == 4) {
        cell.nameLabel.text = NSLocalizedString(@"app_version", nil);
        cell.isShowRightView = NO;
        cell.detailLabel.text = CUR_BUILD_VERSION;
    }
    return cell;
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([indexPath row] == 0) {
        PopUpViewController *vc = [PopUpViewController new];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([indexPath row] == 2) {
        FrtcLanguageSettingViewController *languageVC = [[FrtcLanguageSettingViewController alloc]init];
        [self.navigationController pushViewController:languageVC animated:YES];
    } else if (indexPath.row == 3) {
        FrtcFeedbackViewController *feedbackVC = [[FrtcFeedbackViewController alloc]init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
}

#pragma mark- lazy load

- (UITableView *)statusTableView {
    if(!_statusTableView) {
        _statusTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _statusTableView.delegate     = self;
        _statusTableView.dataSource  = self;
        _statusTableView.rowHeight   = Status_Cell_Height;
        _statusTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        [_statusTableView registerClass:[StatusTableViewCell class] forCellReuseIdentifier:@"UITableViewCellIdentifier"];
        if (@available(iOS 15.0, *)) { [_statusTableView setSectionHeaderTopPadding:0.0f]; }
        [self.contentView addSubview:_statusTableView];
    }
    return _statusTableView;
}

- (UIButton *)serviceAgreementBtn{
    if (!_serviceAgreementBtn) {
        _serviceAgreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_serviceAgreementBtn setTitle:[NSString stringWithFormat:@"%@ %@",FLocalized(@"app_website_url", nil),kAppWebsiteUrl] forState:UIControlStateNormal];
        [_serviceAgreementBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _serviceAgreementBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_serviceAgreementBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppWebsiteUrl]];
#pragma clang diagnostic pop
        }];
        [self.contentView addSubview:_serviceAgreementBtn];
    }
    return _serviceAgreementBtn;
}

- (UIButton *)agreementBtn {
    if (!_agreementBtn) {
        _agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreementBtn setTitle:[NSString stringWithFormat:@"%@ %@",FLocalized(@"app_Github_url", nil),kAppGithubUrl] forState:UIControlStateNormal];
        [_agreementBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        _agreementBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_agreementBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppGithubUrl]];
#pragma clang diagnostic pop
        }];
        [self.contentView addSubview:_agreementBtn];
    }
    return _agreementBtn;
}

@end
