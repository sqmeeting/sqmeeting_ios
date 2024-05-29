#import "FrtcEntryViewController.h"
#import "Masonry.h"
#import "FrtcCallViewController.h"
#import "SettingViewController.h"
#import "FrtcSignInNameController.h"
#import "FrtcAccountController.h"
#import "FrtcUserDefault.h"
#import "FrtcCall.h"
#import "MBProgressHUD.h"
#import "FrtcScanQRViewController.h"
#import "UIImage+Extensions.h"
#import "FrtcManagement.h"
#import "MBProgressHUD+Extensions.h"
#import "PopUpViewController.h"

@interface FrtcEntryViewController ()<FrtcScanQRViewControllerDelegate>

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *centerImageView;

@property (strong, nonatomic) UIButton *joinMeetingBtn;
@property (strong, nonatomic) UIButton *btnLogin;

@property (nonatomic, strong) UIImageView *logoImageBottomView;
@property (strong, nonatomic) UILabel *versionLabel;

@property (strong, nonatomic) UIButton *accountBtn;
@property (strong, nonatomic) UIButton *scanButton;

@end

@implementation FrtcEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.hidden = YES;
    [self configFRView];
    self.initialized = NO;
    [self getNavItem];
    ISMLog(@"FViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
    //必须设置服务地址
    NSString *defaultAddress = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    if (kStringIsEmpty(defaultAddress)) {
        PopUpViewController *popUpVC = [[PopUpViewController alloc]init];
        [self.navigationController pushViewController:popUpVC animated:YES];
    }
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - ui

- (void)getNavItem{
    
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [settingsBtn setImage:[UIImage imageNamed:@"icon_setting"]forState:UIControlStateNormal];
    [settingsBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [settingsBtn.imageView setTintColor:UIColor.grayColor];
    [settingsBtn addTarget:self action:@selector(goSetting:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [scanButton setImage:[UIImage imageNamed:@"icon_scan"]forState:UIControlStateNormal];
    [scanButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [scanButton addTarget:self action:@selector(goScan:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:settingsItem,scanItem,nil]];
    
    UILabel *leftTitlelabel = [UILabel new];
    leftTitlelabel.text = NSLocalizedString(@"app_displayname", nil);
    leftTitlelabel.font = [UIFont boldSystemFontOfSize:18.f];
    UIBarButtonItem *lefttitleitem = [[UIBarButtonItem alloc]initWithCustomView:leftTitlelabel];
    
    [self.navigationItem setLeftBarButtonItems:@[lefttitleitem]];
}

- (void)configFRView {
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kTopSpacing(10));
        make.centerX.equalTo(self.view);
    }];
    
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.logoImageView);
    }];
    
    [self.joinMeetingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(kButtonHeight + 4);
        make.top.equalTo(self.logoImageView.mas_bottom).mas_offset(18);
    }];
    
    [self.logoImageBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.btnLogin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(self.joinMeetingBtn.mas_bottom).mas_offset(24);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(kButtonHeight + 4);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-35);
    }];
    
}

#pragma mark - FrtcScanQRViewControllerDelegate
- (void)scanUrlResult:(NSString *)callUrl {
    
    
}

#pragma mark - action

- (void)btnLoginView:(UIButton *)sender {
    [self isGoPage:^(BOOL go) {
        if (go) {
            FrtcSignInNameController *firstVC = [[FrtcSignInNameController alloc] init];
            [self.navigationController pushViewController:firstVC animated:YES];
        }else{
            [MBProgressHUD showMessage:NSLocalizedString(@"address_null_login", nil)];
        }
    }];
}

- (void)goSetting:(UIButton *)sender {
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (void)goScan:(UIButton *)sender {
    [self isGoPage:^(BOOL go) {
        if (go) {
            FrtcScanQRViewController *scanQRViewController = [[FrtcScanQRViewController alloc] init];
            [self.navigationController pushViewController:scanQRViewController animated:YES];
        }else{
            [MBProgressHUD showMessage:NSLocalizedString(@"address_null", nil)];
        }
    }];
}

- (void)goAccount:(UIButton *)sender {
    FrtcAccountController *accountViewController = [[FrtcAccountController alloc] init];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)joinTheMeeting:(UIButton *)sender {
    [self isGoPage:^(BOOL go) {
        if (go) {
            if (kStringIsEmpty([FrtcLocalInforDefault getMeetingDisPlayName])) {
                [FrtcLocalInforDefault saveMeetingName:[UIDevice currentDevice].name];
            }
            FrtcCallViewController *firstVC = [[FrtcCallViewController alloc] init];
            [self.navigationController pushViewController:firstVC animated:YES];
        }else{
            [MBProgressHUD showMessage:NSLocalizedString(@"address_null_meeting", nil)];
        }
    }];
}

- (void)isGoPage:(void(^)(BOOL go))block {
    NSString *address = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    block(!kStringIsEmpty(address));
}

#pragma mark -- lazy load

- (UIImageView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _backGroundView.userInteractionEnabled = YES;
        [self.view addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:[UIImage imageNamed:@"setup-logo-mobile"]];
        [self.backGroundView addSubview:_logoImageView];
    }
    return _logoImageView;
}

- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc] init];
        [_centerImageView setImage:[UIImage imageNamed:@"setup_logo_center"]];
        [self.backGroundView addSubview:_centerImageView];
    }
    return _centerImageView;
}


- (UIButton *)joinMeetingBtn {
    if(!_joinMeetingBtn) {
        _joinMeetingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinMeetingBtn setTitle:NSLocalizedString(@"join_meeting_entry", nil) forState:UIControlStateNormal];
        _joinMeetingBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_joinMeetingBtn setBackgroundImage:[UIImage imageFromColor:kMainColor] forState:UIControlStateNormal];
        [_joinMeetingBtn setBackgroundImage:[UIImage imageFromColor:kMainHoverColor] forState:UIControlStateHighlighted];
        [_joinMeetingBtn addTarget:self action:@selector(joinTheMeeting:) forControlEvents:UIControlEventTouchUpInside];
        _joinMeetingBtn.layer.masksToBounds = YES;
        _joinMeetingBtn.layer.cornerRadius  = KCornerRadius;
        [self.backGroundView addSubview:_joinMeetingBtn];
    }
    
    return _joinMeetingBtn;
}

- (UIImageView *)logoImageBottomView {
    if (!_logoImageBottomView) {
        _logoImageBottomView = [[UIImageView alloc] init];
        [_logoImageBottomView setImage:[UIImage imageNamed:@"entry_bottom_img"]];
        [self.backGroundView addSubview:_logoImageBottomView];
    }
    return _logoImageBottomView;
}

- (UIButton *)btnLogin {
    if(!_btnLogin) {
        _btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnLogin setTitle:NSLocalizedString(@"sign_in", nil) forState:UIControlStateNormal];
        [_btnLogin setTitleColor:KTextColor forState:UIControlStateNormal];
        _btnLogin.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_btnLogin addTarget:self action:@selector(btnLoginView:) forControlEvents:UIControlEventTouchUpInside];
        [_btnLogin setBackgroundImage:[UIImage imageFromColor:KGreyColor] forState:UIControlStateNormal];
        [_btnLogin setBackgroundImage:[UIImage imageFromColor:KGreyHoverColor]        forState:UIControlStateHighlighted];
        _btnLogin.layer.masksToBounds = YES;
        _btnLogin.layer.cornerRadius = KCornerRadius;
        [self.backGroundView addSubview:_btnLogin];
    }
    
    return _btnLogin;
}

- (UILabel *)versionLabel {
    if(!_versionLabel) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.textAlignment = NSTextAlignmentLeft;
        _versionLabel.numberOfLines = 1.0;
        NSString *version = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"app_copyright", nil),CUR_BUILD_VERSION];
        _versionLabel.text = version;
        _versionLabel.font = [UIFont systemFontOfSize:11.0];
        _versionLabel.textColor = KDetailTextColor;
        [self.backGroundView addSubview:_versionLabel];
    }
    
    return _versionLabel;
}

@end
