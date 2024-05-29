#import "FrtcScheduleAddUserResultViewController.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "FrtcInviteUserModel.h"
#import "UIControl+Extensions.h"
#import "FrtcInviteUserModel.h"
#import "FrtcScheduleUserTableViewCell.h"
#import "UITableView+Extensions.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcScheduleMeetingViewController.h"
#import "UIViewController+Extensions.h"

#define InviteUserCellId @"InviteUs111erCellId"

@interface FrtcScheduleAddUserResultViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *inviteUserListData;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *headerBtn;
@property (nonatomic, strong) UILabel *lable;

@end

@implementation FrtcScheduleAddUserResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"meeting_add_user", nil);
    self.definesPresentationContext = YES;
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
}

- (void)configUI {
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(- (KSafeAreaBottomHeight + 70));
    }];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.top.equalTo(self.tableView.mas_bottom).mas_offset(15);
    }];
    
    [self.lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.centerY.equalTo(self.doneBtn);
    }];
}

- (void)doneBntCallBack {
    
    if (self.selectListData.count > 100) {
        [self showAlertWithTitle:NSLocalizedString(@"meeting_number_max", nil) message:NSLocalizedString(@"meeting_overload_people", nil) buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) {
            
        }];
        return;
    }
    
    if (self.inviteBtnCallBack) {
        self.inviteBtnCallBack();
    }
    [MBProgressHUD showActivityMessage:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[FrtcScheduleMeetingViewController class]]) {
                [MBProgressHUD hideHUD];
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    });
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcScheduleUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InviteUserCellId forIndexPath:indexPath];
    FInviteUserListInfo *info = self.selectListData[indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)",info.real_name,info.username];
    cell.selectBtn.enabled = !info.isSelect;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) { return; }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FInviteUserListInfo *info = self.selectListData[indexPath.row];
    [self.selectListData removeObject:info];
    self.lable.text = [NSString stringWithFormat:@"%@ %td %@",NSLocalizedString(@"meeting_added", nil),self.selectListData.count,NSLocalizedString(@"people", nil)];;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    if (self.deleteUser) {
        self.deleteUser(info);
    }
}

- (NSString *)f_noDataViewMessage {
    return NSLocalizedString(@"meeting_noInvitees", nil);
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = KBGColor;
        [_tableView registerClass:[FrtcScheduleUserTableViewCell class] forCellReuseIdentifier:InviteUserCellId];
        _tableView.rowHeight = 52;
        _tableView.tableHeaderView = self.headerBtn;
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        if (@available(iOS 15.0, *)) { [_tableView setSectionHeaderTopPadding:0.0f]; }
        [self.contentView addSubview:_tableView];
    }
    return _tableView;
}


- (NSMutableArray *)inviteUserListData {
    if (!_inviteUserListData) {
        _inviteUserListData = [NSMutableArray array];
    }
    return _inviteUserListData;
}


- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:NSLocalizedString(@"string_done", nil) forState:UIControlStateNormal];
        [_doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _doneBtn.layer.cornerRadius = KCornerRadius;
        _doneBtn.backgroundColor = kMainColor;
        [_doneBtn addTarget:self action:@selector(doneBntCallBack) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_doneBtn];
    }
    return _doneBtn;
}

- (UIButton *)headerBtn {
    if (!_headerBtn) {
        _headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerBtn.frame = CGRectMake(0, 0, KScreenWidth, 60);
        [_headerBtn setImage:[UIImage imageNamed:@"meeting_addUser"] forState:UIControlStateNormal];
        [_headerBtn setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"meeting_add_user_d", nil)] forState:UIControlStateNormal];
        [_headerBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        _headerBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _headerBtn.backgroundColor = UIColor.whiteColor;
        _headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _headerBtn.imageEdgeInsets = UIEdgeInsetsMake(0, KLeftSpacing - 4, 0, 0);
        _headerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, KLeftSpacing + 5, 0, 0);
        @WeakObj(self);
        [_headerBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _headerBtn;
}

- (UILabel *)lable {
    if (!_lable) {
        _lable = [UILabel new];
        _lable.textColor = KDetailTextColor;
        _lable.font = [UIFont boldSystemFontOfSize:16];
        _lable.textAlignment = NSTextAlignmentCenter;
        _lable.text = [NSString stringWithFormat:@"%@ %td %@",NSLocalizedString(@"meeting_added", nil),self.selectListData.count,NSLocalizedString(@"people", nil)];
        [self.contentView addSubview:_lable];
    }
    return _lable;
}
@end
