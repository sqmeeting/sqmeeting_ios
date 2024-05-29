#import "FrtcHDEntryViewController.h"
#import "Masonry.h"
#import "FrtcHDCallViewController.h"
#import "SettingHDViewController.h"
#import "FrtcHDSignInNameController.h"
#import "FrtcHDAccountController.h"
#import "FrtcUserDefault.h"
#import "MBProgressHUD.h"
#import "FrtcHDScanQRViewController.h"
#import "MBProgressHUD+Extensions.h"
#import "UIImage+Extensions.h"
#import "UIViewController+Extensions.h"
#import "ContentShareGadget.h"
#import "FrtcRtcsdkExtention.h"
#import "PopUpHDViewController.h"

#define KColorRGB(r,g,b,a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]

@interface FrtcHDEntryViewController ()<FrtcHDScanQRViewControllerDelegate>

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *centerImageView;

@property (strong, nonatomic) UIButton *joinMeetingBtn;
@property (strong, nonatomic) UIButton *btnLogin;

@property (nonatomic, strong) UIImageView *logoImageBottomView;
@property (strong, nonatomic) UILabel *versionLabel;

@property (strong, nonatomic) UIButton *accountBtn;
@property (strong, nonatomic) UIButton *scanButton;

@end

@implementation FrtcHDEntryViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configFRView];
    self.initialized = NO;
    [self getNavItem];
}

- (void)viewWillAppear:(BOOL)animated {
    //必须设置服务地址
    NSString *defaultAddress = [[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS];
    if (kStringIsEmpty(defaultAddress)) {
        PopUpHDViewController *popUpVC = [[PopUpHDViewController alloc]init];
        [self presentHDViewController:popUpVC animated:YES completion:^{}];
    }
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
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
        //make.width.mas_equalTo(310);
        //make.height.mas_equalTo(310);
        make.centerX.equalTo(self.view);
    }];
    
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.logoImageView);
    }];
    
    [self.joinMeetingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(500);
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
        make.width.mas_equalTo(500);
        make.height.mas_equalTo(kButtonHeight + 4);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-35);
    }];
    
}

#pragma mark - FScanQRViewControllerDelegate
- (void)scanUrlResult:(NSString *)callUrl {
    
    
}

#pragma mark - action

- (void)btnLoginView:(UIButton *)sender {
    @WeakObj(self);
    [self isGoPage:^(BOOL go) {
        @StrongObj(self)
        if (go) {
            FrtcHDSignInNameController *firstVC = [[FrtcHDSignInNameController alloc] init];
            [self presentHDViewController:firstVC animated:YES completion:^{}];
        }else{
            [MBProgressHUD showMessage:NSLocalizedString(@"address_null_login", nil)];
        }
    }];
}

- (void)goSetting:(UIButton *)sender {
    SettingHDViewController *settingViewController = [[SettingHDViewController alloc] init];
    [self presentHDViewController:settingViewController animated:YES completion:^{}];
}

- (void)goScan:(UIButton *)sender {
    @WeakObj(self);
    [self isGoPage:^(BOOL go) {
        @StrongObj(self)
        if (go) {
            FrtcHDScanQRViewController *scanQRViewController = [[FrtcHDScanQRViewController alloc] init];
            [self.navigationController pushViewController:scanQRViewController animated:YES];
        }else{
            [MBProgressHUD showMessage:NSLocalizedString(@"address_null", nil)];
        }
    }];
}

- (void)goAccount:(UIButton *)sender {
    FrtcHDAccountController *accountViewController = [[FrtcHDAccountController alloc] init];
    [self presentHDViewController:accountViewController animated:YES completion:^{}];
}

- (void)joinTheMeeting:(UIButton *)sender {
    @WeakObj(self);
    [self isGoPage:^(BOOL go) {
        @StrongObj(self)
        if (go) {
            //save joining name default iPad
            if (kStringIsEmpty([FrtcLocalInforDefault getMeetingDisPlayName])) {
                [FrtcLocalInforDefault saveMeetingName:[UIDevice currentDevice].name];
            }
            FrtcHDCallViewController *callVc = [[FrtcHDCallViewController alloc] init];
            [self presentHDViewController:callVc animated:YES completion:^{}];
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

//end add

- (UILabel *)versionLabel {
    if(!_versionLabel) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.textAlignment = NSTextAlignmentLeft;
        _versionLabel.numberOfLines = 1.0;
        NSString *version = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"app_copyright", nil),CUR_BUILD_VERSION];
        _versionLabel.text = version;
        _versionLabel.font = [UIFont systemFontOfSize:11.0];
        _versionLabel.textColor = KColorRGB(153, 153, 153, 1);
        [self.backGroundView addSubview:_versionLabel];
    }
    
    return _versionLabel;
}

@end
