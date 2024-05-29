#import "FrtcMeetingInviteUserViewController.h"
#import "Masonry.h"
#import "UIImage+Extensions.h"
#import "FrtcInviteUserModel.h"
#import "UIControl+Extensions.h"
#import "FrtcScheduleMeetingPresenter.h"
#import "UINavigationItem+Extensions.h"
#import "FrtcScheduleUserTableViewCell.h"
#import "FrtcScheduleAddUserResultViewController.h"
#import "MBProgressHUD+Extensions.h"
#import "MJRefresh.h"

#define InviteUserCellId @"InviteUserCellId"

@interface FrtcMeetingInviteUserViewController () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate,FrtcScheduleMeetingProtocol,UITextFieldDelegate>
{
    NSInteger _pageNum;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FInviteUserListInfo *> *inviteUserListData;
@property (nonatomic, strong) NSMutableArray<FInviteUserListInfo *> *selectListData;
@property (nonatomic, strong) NSMutableArray<FInviteUserListInfo *> *searchListData;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) FrtcScheduleMeetingPresenter *schedulePresenter;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation FrtcMeetingInviteUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"meeting_invite_user", nil);
    self.definesPresentationContext = YES;
    [self assignmentSelectedData];
    _pageNum = 1;
    [self.schedulePresenter requestUserListDataWithPage:_pageNum filter:@""];
    
}

- (void)dealloc {
    ISMLog(@"%s",__func__)
}

- (void)configUI {
    
    self.lineView = [UIView new];
    self.lineView.backgroundColor = KBGColor;
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(- (KSafeAreaBottomHeight + 70));
    }];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.top.equalTo(self.tableView.mas_bottom).mas_offset(15);
    }];
}

#pragma mark - action

- (void)assignmentSelectedData {
    if (self.userIds.count > 0) {
        for (FInviteUserListInfo *info in self.userIds) {
            info.select = YES;
        }
        [self.selectListData addObjectsFromArray:self.userIds];
    }
}

- (void)setButtonTitle
{
    [self.doneBtn setTitle:[NSString stringWithFormat:@"%@ (%td)",NSLocalizedString(@"string_next", nil),self.selectListData.count] forState:UIControlStateNormal];
}

- (void)pushDeleteUserView {
    if (self.selectListData == 0) {
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_select_user", nil)];
        return;
    }
    FrtcScheduleAddUserResultViewController *vc = [[FrtcScheduleAddUserResultViewController alloc]init];
    vc.selectListData = self.selectListData;
    @WeakObj(self);
    vc.deleteUser = ^(FInviteUserListInfo * _Nonnull info) {
        @StrongObj(self)
        [self.selectListData removeObject:info];
        [self setButtonTitle];
        for (FInviteUserListInfo *user in self.inviteUserListData) {
            if ([user.user_id isEqualToString:info.user_id]) {
                user.select = !user.select;
            }
        }
        [self.tableView reloadData];
    };
    
    vc.inviteBtnCallBack = ^{
        @StrongObj(self)
        if (self.inviteUserList) {
            self.inviteUserList(self.selectListData);
        }
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - FrtcScheduleMeetingProtocol
- (void)responseInviteUserListData:(FrtcInviteUserModel * _Nullable)result errMsg:(NSString * _Nullable)errMsg {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    if (!errMsg) {
        if (self.searchController.isActive) {
            if (self.searchListData.count > 0) {
                [self.searchListData removeAllObjects];
            }
            [self.searchListData addObjectsFromArray:result.users];
        }else{
            if (_pageNum == 1) {
                [self setButtonTitle];
                
            }
            [self.inviteUserListData addObjectsFromArray:result.users];
        }
        
        for (FInviteUserListInfo *info in self.searchController.isActive ? self.searchListData : self.inviteUserListData) {
            for (FInviteUserListInfo *userInfo in self.selectListData) {
                if ([userInfo.user_id isEqualToString:info.user_id]) {
                    info.select = YES;
                }
            }
        }
        [self setButtonTitle];
        
        [self.tableView reloadData];
        self.tableView.mj_footer.hidden = (result.total_page_num == _pageNum);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    @WeakObj(self);
    [self.navigationItem initWithLeftButtonTitleCallBack:^{
        @StrongObj(self)
        self.searchController.active = NO;
        [self.navigationItem initWithLeftButtonImage:@"nav_back_icon" back:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    return YES;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text ;
    self.tableView.mj_footer.hidden = YES;
    [self.schedulePresenter requestUserListDataWithPage:1 filter:inputStr];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return self.searchListData.count ;
    }
    return self.inviteUserListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcScheduleUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InviteUserCellId forIndexPath:indexPath];
    FInviteUserListInfo *info = self.searchController.isActive ? self.searchListData[indexPath.row] : self.inviteUserListData[indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)",info.real_name,info.username];
    cell.selectBtn.selected = info.isSelect;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) { return; }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FInviteUserListInfo *info = self.searchController.isActive ? self.searchListData[indexPath.row] : self.inviteUserListData[indexPath.row];
    info.select = !info.select;
    if (info.select) {
        [self.selectListData addObject:info];
    }else{
        for (FInviteUserListInfo *uinfo in self.selectListData) {
            if ([uinfo.user_id isEqualToString:info.user_id]) {
                [self.selectListData removeObject:uinfo];
                break;
            }
        }
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self setButtonTitle];
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
        _tableView.tableHeaderView = self.searchController.searchBar;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        @WeakObj(self);
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @StrongObj(self)
            self->_pageNum ++;
            [self.schedulePresenter requestUserListDataWithPage:self->_pageNum filter:@""];
        }];
        if (@available(iOS 15.0, *)) { [_tableView setSectionHeaderTopPadding:0.0f]; }
        [self.contentView addSubview:_tableView];
    }
    return _tableView;
}

- (UISearchController *) searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _searchController.obscuresBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.searchBar.delegate = self;
        _searchController.searchBar.showsCancelButton = NO;
        _searchTextField = _searchController.searchBar.searchTextField;
        _searchTextField.borderStyle = UITextBorderStyleNone;
        _searchTextField.textColor = KTextColor;
        _searchTextField.leftView.tintColor = KDetailTextColor;
        _searchTextField.delegate = self;
    }
    return _searchController;
}

- (NSMutableArray *)inviteUserListData {
    if (!_inviteUserListData) {
        _inviteUserListData = [NSMutableArray array];
    }
    return _inviteUserListData;
}

- (NSMutableArray *)selectListData {
    if (!_selectListData) {
        _selectListData = [NSMutableArray array];
    }
    return _selectListData;
}

- (NSMutableArray *)searchListData {
    if (!_searchListData) {
        _searchListData = [NSMutableArray array];
    }
    return _searchListData;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:[NSString stringWithFormat:@"%@ (0)",NSLocalizedString(@"string_next", nil)] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _doneBtn.layer.cornerRadius = KCornerRadius;
        _doneBtn.backgroundColor = kMainColor;
        @WeakObj(self);
        [_doneBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self pushDeleteUserView];
        }];
        [self.contentView addSubview:_doneBtn];
    }
    return _doneBtn;
}

- (FrtcScheduleMeetingPresenter *)schedulePresenter {
    if (!_schedulePresenter) {
        _schedulePresenter = [FrtcScheduleMeetingPresenter new];
        [_schedulePresenter bindView:self];
    }
    return _schedulePresenter;
}


@end
