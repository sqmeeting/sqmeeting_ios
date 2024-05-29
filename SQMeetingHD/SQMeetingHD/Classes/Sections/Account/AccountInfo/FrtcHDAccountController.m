#import "FrtcHDAccountController.h"
#import "HDStatusTableViewCell.h"
#import "FrtcUserDefault.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "FrtcSignLoginPresenter.h"
#import "FrtcCall.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "FrtcUserModel.h"
#import "FrtcSignLoginPresenter.h"
#import "MBProgressHUD+Extensions.h"
#import "AppDelegate.h"
#import "FrtcHDAccountUpdatePsdVC.h"
#import "UINavigationItem+Extensions.h"

@interface FrtcHDAccountController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource,FrtcSignLoginProtocol>

@property (strong, nonatomic) UITableView *statusTableView;
@property (strong, nonatomic) FrtcSignLoginPresenter *logOutPresenter;

@end

@implementation FrtcHDAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"user_account", nil);
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
    KUpdateHomeView
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)configUI {
    
    @WeakObj(self)
    [self.navigationItem initWithLeftButtonImage:@"nav_back_icon" back:^{
        @StrongObj(self)
        [self dismissViewControllerAnimated:YES completion:^{ }];
    }];
    
    [self.statusTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(Status_Cell_Height * 3);
        make.top.mas_equalTo(10);
    }];
    
    [self.signOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.statusTableView.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(kButtonHeight + 4);
    }];
}

- (void)didClickSignOutButton:(UIButton*)sender {
    [self.logOutPresenter requestLogOut];
}

#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDStatusTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    
    if (nil == cell) {
        cell = [[HDStatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        cell.isShowRightView = YES;
        if (indexPath.row == 0) {
            cell.nameLabel.text = NSLocalizedString(@"Account", nil);
            cell.detailLabel.text = [FrtcUserModel fetchUserInfo].username;
            cell.isShowRightView = NO;
        }else if(indexPath.row == 1) {
            cell.nameLabel.text = NSLocalizedString(@"display_name_join_meeting", nil);
            NSString *userName = [FrtcUserModel fetchUserInfo].real_name;
            cell.detailLabel.text = userName;
            cell.isShowRightView = NO;
            NSLog(@"userName = %@",userName);
        } else if(indexPath.row == 2) {
            cell.nameLabel.text = NSLocalizedString(@"set_pwd", nil);
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 2:{
            FrtcHDAccountUpdatePsdVC *updatePsdvc = [[FrtcHDAccountUpdatePsdVC alloc]init];
            [self.navigationController pushViewController:updatePsdvc animated:YES];
        }
            break;
        default:
            break;
    }
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

#pragma mark - PopUpViewControllerDelegate
- (void)saveNewAddress:(NSString *)newServerAddress {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    HDStatusTableViewCell *selectCell = (HDStatusTableViewCell *) [_statusTableView cellForRowAtIndexPath:indexPath];
    selectCell.detailLabel.text = newServerAddress;
    [[FrtcUserDefault sharedUserDefault] setObject:newServerAddress forKey:SERVER_ADDRESS];
}

#pragma mark - lazy load

- (FrtcSignLoginPresenter *)logOutPresenter {
    if (!_logOutPresenter) {
        _logOutPresenter = [FrtcSignLoginPresenter new];
        [_logOutPresenter bindView:self];
    }
    return _logOutPresenter;
}

- (UITableView *)statusTableView {
    if(!_statusTableView) {
        _statusTableView = [[UITableView alloc] init];
        _statusTableView.delegate   = self;
        _statusTableView.dataSource = self;
        _statusTableView.scrollEnabled = NO;
        _statusTableView.rowHeight  = Status_Cell_Height;
        _statusTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_statusTableView];
    }
    return _statusTableView;
}

- (UIButton *)signOutButton {
    if(!_signOutButton) {
        _signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signOutButton setTitle:NSLocalizedString(@"sign_out", nil) forState:UIControlStateNormal];
        [_signOutButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        _signOutButton.backgroundColor = UIColor.whiteColor;
        _signOutButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_signOutButton setBackgroundImage:[UIImage imageFromColor:UIColorHex(0xd3d3d3)] forState:UIControlStateHighlighted];
        [_signOutButton addTarget:self action:@selector(didClickSignOutButton:) forControlEvents:UIControlEventTouchUpInside];
        _signOutButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _signOutButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.contentView addSubview:_signOutButton];
    }
    return _signOutButton;
}


@end
