#import "RostListDlgController.h"
#import "RosterListTableViewCell.h"
#import "Masonry.h"
#import "ParticipantListModel.h"
#import "UIView+Extensions.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "RosterPresenter.h"
#import "MuteView.h"
#import "UIViewController+Extensions.h"
#import "FrtcLocalInforDefault.h"
#import "AllMuteView.h"
#import "NSObject+AlertView.h"
#import "FrtcCAlertView.h"
#import "FrtcUserModel.h"
#import "UIView+Toast.h"
#import "FrtcRequestUnmuteItemView.h"
#import "UIGestureRecognizer+Extensions.h"
#import "FrtcRequestUnmuteListViewController.h"
#import "FrtcRequestUnmuteModel.h"
#import "MBProgressHUD+Extensions.h"

#define KRostListTableViewCell @"UITableViewCellIdentifier"
#define KRostBottomViewHeight 85

@interface RostListDlgController ()<UITableViewDelegate, UITableViewDataSource,
RosterViewProtocol,UIGestureRecognizerDelegate, UISearchBarDelegate>
{
    NSString *updateName;
    ParticipantListModel *currentParticipant;
    NSString *searchText;
    BOOL isMuteMic;
}

@property (nonatomic, strong) RosterPresenter *presenter;
@property (nonatomic, strong) UIView *rosterMainView;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UITableView *rosterListTableView;
@property (nonatomic, strong) NSMutableArray<ParticipantListModel *> *rostListData;
@property (nonatomic, strong) NSArray<NSString *> *pinList;
@property (nonatomic, strong) NSMutableArray<ParticipantListModel *> *searchListData;
@property (nonatomic, copy)   NSArray<NSString *> *lecturesList;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *unmuteButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) FrtcRequestUnmuteItemView *requestUnmuteView;

@end

@implementation RostListDlgController

- (id)initWithRosterList:(NSMutableArray<ParticipantListModel *> *)rosterArray
            lecturesList:(nonnull NSArray<NSString *> *)lecturesList
                 pinList:(nonnull NSArray<NSString *> *)pinList {
    
    self = [super init];
    
    if(self) {
        _rostListData = rosterArray;
        _lecturesList = lecturesList;
        _pinList      = pinList;
        [self.searchListData addObjectsFromArray:_rostListData];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backGroundView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.3]];
    [self.rosterMainView setBackgroundColor:UIColor.whiteColor];
    NSString *numberString = [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"participants", nil), (unsigned long)_rostListData.count];
    self.titleLabel.text = numberString;
    [self configRostView];
    if (!self.isMeetingOperator) {
        self.muteButton.alpha = self.unmuteButton.alpha = 0;
    }else{
        self.muteButton.alpha = self.unmuteButton.alpha = 1;
    }
    
    @WeakObj(self);
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self disMiss];
    }];
    tapGesture.delegate = self;
    [self.backGroundView addGestureRecognizer:tapGesture];
    
    [self sortRostListData];

    if (self.requestUnmuteList.count > 0) {
        self.requestUnmuteView.redDotView.hidden = NO;
        self.requestUnmuteView.nameLable.text = self.requestUnmuteList.lastObject.name;
        self.rosterListTableView.tableHeaderView = self.requestUnmuteView;
    }else{
        self.rosterListTableView.tableHeaderView = [UIView new];
    }
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

#pragma mark - UI

- (void)configRostView {
    
    [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.rosterMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(0);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(58);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(60);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.closeButton);
        make.width.mas_greaterThanOrEqualTo(0);
        make.centerX.equalTo(self.rosterMainView);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(35);
        make.top.equalTo(self.titleLabel.mas_bottom);
    }];
    
    [self.rosterListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.searchBar.mas_bottom).offset(5);
        make.bottom.mas_equalTo(-KRostBottomViewHeight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.rosterListTableView.mas_bottom);
    }];
    
    [self.unmuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.right.mas_equalTo(-KLeftSpacing);
        make.height.mas_equalTo(40);
    }];
    
    [self.muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.right.equalTo(self.unmuteButton.mas_left).mas_offset(-10);
        make.height.mas_equalTo(40);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KLeftSpacing);
        make.centerY.equalTo(self.bottomView);
        make.height.mas_equalTo(30);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            [self.rosterMainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(LAND_SCAPE_WIDTH/2.2);
            }];
            [self.rosterMainView.superview layoutIfNeeded];
            [self.rosterMainView setCornerRadius:KCornerRadius * 2
                                  addRectCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft];
        } completion:^(BOOL finished) {
            
        }];
    });
}

#pragma mark - action

- (void)sortRostListData {
    
    if(!kStringIsEmpty(self->searchText)) {
        [self.rosterListTableView reloadData];
        return;
    }
        
    BOOL isExistLectures = _lecturesList.count > 0 ;
    BOOL isExistPin      = _pinList.count > 0 ;
    
    __block NSMutableArray <ParticipantListModel *> *resultLecturesRosterList = [NSMutableArray arrayWithArray:self.searchListData];
    if (isExistLectures) {
        for (int i = 0 ; i < self.searchListData.count; i ++) {
            ParticipantListModel *item = self.searchListData[i];
            if ([item.UUID isEqualToString:_lecturesList.firstObject]) {
                if (item.isMe) {break;}
                [resultLecturesRosterList removeObjectAtIndex:i];
                [resultLecturesRosterList insertObject:item atIndex:1];
                break;
            }
        }
    }
    
    __block NSMutableArray <ParticipantListModel *> *resultRosterList = [NSMutableArray arrayWithArray:resultLecturesRosterList];
    if (isExistPin) {
        for (int i = 0 ; i < resultLecturesRosterList.count; i ++) {
            for (int j = 0 ; j < _pinList.count; j ++) {
                ParticipantListModel *item = resultLecturesRosterList[i];
                if ([item.UUID isEqualToString:_pinList[j]]) {
                    if (item.isMe) {continue;}
                    [resultRosterList removeObjectAtIndex:i];
                    [resultRosterList insertObject:item atIndex:1]; //isExistLectures ? 2 : 1
                    continue;
                }
            }
        }
    }
    
    [self.searchListData removeAllObjects];
    [self.searchListData addObjectsFromArray:resultRosterList];
    [self.rosterListTableView reloadData];
}

- (void)pushRequestUnmuteListView {
    self.requestUnmuteView.redDotView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(hiddenRedDotView)]) {
        [self.delegate hiddenRedDotView];
    };
    FrtcRequestUnmuteListViewController *unmuteListView = [[FrtcRequestUnmuteListViewController alloc]init];
    unmuteListView.requestUnmuteList = self.requestUnmuteList;
    unmuteListView.meetingNumber     = self.meetingNumber;
    @WeakObj(self)
    unmuteListView.unmuteListCallBack = ^{
        @StrongObj(self)
        self.rosterListTableView.tableHeaderView = [UIView new];
        self.rosterListTableView.sectionHeaderHeight = 0;
    };
    [self presentHDViewController:unmuteListView animated:YES completion:^{ }];
}

- (void)disMiss{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.rosterMainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        [self.rosterMainView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)updateRosterList:(NSMutableArray *)rosterArray {
    _rostListData = rosterArray;
    NSString *numberString = [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"participants", nil), (unsigned long)_rostListData.count];
    self.titleLabel.text = numberString;
    [self searchParticipants];
}

- (void)updateLecturesList:(NSArray <NSString *> *)lecturesList {
    _lecturesList = lecturesList;
    [self sortRostListData];
}

- (void)updatePinList:(NSArray<NSString *> *)pinList {
    _pinList = pinList;
    [self sortRostListData];
}

- (void)updateUnmuteRequestList:(NSMutableArray<FrtcRequestUnmuteModel *> *)requestUnmuteList {
    _requestUnmuteList = requestUnmuteList;
    if (self.requestUnmuteList.count > 0) {
        self.requestUnmuteView.nameLable.text = self.requestUnmuteList.lastObject.name;
        self.rosterListTableView.tableHeaderView = self.requestUnmuteView;
    }else{
        self.rosterListTableView.tableHeaderView = [UIView new];
    }
}

- (void)showMuteViewWithInfo:(ParticipantListModel *)info {
    self->currentParticipant = info;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.isMeetingOperator || info.isMe) {
            @WeakObj(self);
            BOOL isLecture = NO;
            if (self->_lecturesList.count > 0) {
                isLecture = [self->_lecturesList containsObject:info.UUID];
            }
            
            BOOL isPin = NO;
            if (self->_pinList.count > 0) {
                isPin = [self->_pinList containsObject:info.UUID];
            }

            [MuteView showMuteAlertViewWithModel:info
                                  isExistLecture:(self->_lecturesList.count > 0)
                                 meetingOperator:self.isMeetingOperator
                                        lectures:isLecture
                                             pin:isPin
                                muteViewCallBack:^(KMuteType type) {
                @StrongObj(self)
                switch (type) {
                        
                    case KMuteViewTypeMute:
                        [self mutePeople];
                        break;
                    case KMuteViewTypeName:
                        [self updateParticipantName];
                        break;
                    case KMuteViewTypeLecture:
                        [self setLecture];
                        break;
                    case KMuteViewTypeRemove:
                        [self removeParticipant];
                        break;
                    case KMuteViewTypePin:
                        [self peoplePin];
                        break;
                    default:
                        break;
                }
            }];
        }
    });
}

- (void)mutePeople {
    if (currentParticipant.isMe) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(rostListMuteMicroPhone:)]) {
            //currentParticipant.muteAudio = !currentParticipant.isMuteAudio;
            [self.delegate rostListMuteMicroPhone:currentParticipant.muteAudio];
            [self.rosterListTableView reloadData];
        }
    }else{
        NSString * userId = currentParticipant.UUID;
        if (kStringIsEmpty(userId)) { return;}
        if (currentParticipant.isMuteAudio) {
            [self.presenter unMuteParticipantWithMeetingNumber:self.meetingNumber
                                               participantList:@[userId]];
        }else {
            [self.presenter muteParticipantWithMeetingNumber:self.meetingNumber
                                                 allowUnmute:YES
                                             participantList:@[userId]];
        }
    }
}

- (void)updateParticipantName{
    @WeakObj(self)
    NSString *me = NSLocalizedString(@"participants_me", nil);
    self->updateName = [currentParticipant.name stringByReplacingOccurrencesOfString:me withString:@""];
    [self showTextFieldWithTitle:NSLocalizedString(@"meeting_renamed", nil)
                     placeholder:self->updateName
                         buttons:@[NSLocalizedString(@"dialog_cancel", nil)]
                  textFieldBlock:^(NSString * _Nonnull text) {
        @StrongObj(self)
        NSString *changeName = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self->updateName = changeName;
    } doneBlock:^{
        @StrongObj(self)
        if (kStringIsEmpty(self->updateName)) {
            [self.view makeToast:NSLocalizedString(@"meeting_name_beEmpty", nil)];
            return;
        }
        
        NSString *userToken = @"";
        if (isLoginSuccess) {
            userToken = self->currentParticipant.UUID ;
        }
        [self.presenter updateParticipantInfoWithMeetingNumber:self.meetingNumber
                                                   disPlayName:self->updateName
                                                     userToken:userToken];
    }];
}

- (void)setLecture{
    if ([self->_lecturesList containsObject:currentParticipant.UUID]) {
        [self.presenter unSetLecturerWithMeetingNumber:self.meetingNumber];
    }else {
        [self.presenter setLecturerWithMeetingNumber:self.meetingNumber
                                         participant:currentParticipant.UUID];
    }
}

- (void)removeParticipant{
    @WeakObj(self)
    [self showAlertWithTitle:NSLocalizedString(@"meeting_remove", nil)
                     message:NSLocalizedString(@"meeting_removeUser", nil)
                     buttons:@[NSLocalizedString(@"dialog_cancel", nil)]
                   doneBlock:^{
        @StrongObj(self)
        [self.presenter disconnectParticipantsWithMeetingNumber:self.meetingNumber
                                                participantList:@[self->currentParticipant.UUID]];
    }];
}

- (void)peoplePin {
    if ([_pinList containsObject:currentParticipant.UUID]) {
        [self.presenter unPinParticipantWithMeetingNumber:self.meetingNumber];
    }else {
        [self.presenter pinParticipantWithMeetingNumber:self.meetingNumber parameters:@[self->currentParticipant.UUID]];
    }
}

- (void)reloadTableView {
    
    ParticipantListModel *info = _rostListData[_selectIndex];
    info.muteAudio = !info.isMuteAudio;
    [self.rosterListTableView reloadData];
}

#pragma mark - RosterViewProtocol

- (void)muteAllResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(rostListMuteMicroPhone:)]) {
            [self.delegate rostListMuteMicroPhone:YES];
        }
    }
}

- (void)unMuteAllResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        if (!errMsg) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(rostListMuteMicroPhone:)]) {
                [self.delegate rostListMuteMicroPhone:YES];
            }
        }
    }
}

- (void)muteOneOrListResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
    }
}

- (void)unMuteOneOrListResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
    }
}

- (void)updateParticipantInfoResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        if (self->currentParticipant.isMe) {
            ParticipantListModel *info = _rostListData[0];
            info.name = self->updateName;
            if(self.delegate && [self.delegate respondsToSelector:@selector(updateParticipantInfo:)]) {
                [self.delegate updateParticipantInfo:info];
            }
            [self.view makeToast:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"meeting_change_name_success", nil),self->updateName]];
            
            NSString *me = NSLocalizedString(@"participants_me", nil);
            self->updateName =[self->updateName stringByAppendingString:me];
            info.name = self->updateName;
            [self.rosterListTableView reloadData];
        }else{
            [self.view makeToast:NSLocalizedString(@"meeting_modify_success", nil)];
        }
    }
}

- (void)setLecturerResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        [self.view makeToast:NSLocalizedString(@"meeting_setLecture_success", nil)];
    }
}

- (void)unSetLecturerResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        [self.view makeToast:NSLocalizedString(@"meeting_cancelLecture_success", nil)];
    }
}

- (void)disconnectParticipantsResultWithMsg:(NSString *)errMsg {
    if (!errMsg) {
        [self.view makeToast:NSLocalizedString(@"meeting_removeUser_success", nil)];
    }
}
#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self->searchText = searchText;
    [self searchParticipants];
}

- (void)searchParticipants {
    if(!kStringIsEmpty(self->searchText)) {
        [self.searchListData removeAllObjects];
        for (ParticipantListModel *model in _rostListData) {
            if ([model.name rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
                [self.searchListData addObject:model];
            }
        }
    }else{
        [self.searchListData removeAllObjects];
        [self.searchListData addObjectsFromArray:_rostListData];
    }
    
    [self sortRostListData];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RosterListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KRostListTableViewCell forIndexPath:indexPath];
    ParticipantListModel *info = self.searchListData[indexPath.row];
    cell.nameLabel.text = info.name;
    if (info.isMe) {
        if (info.isMuteAudio) {
            cell.audioImageBtn.selected = NO;
        }
        if (self->isMuteMic) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"meeting_audio_mute"] forState:UIControlStateNormal];
        }
    }else{
        [cell.audioImageBtn setImage:[UIImage imageNamed:@"meeting_audio_mute"] forState:UIControlStateNormal];
        [cell.audioImageBtn setImage:[UIImage imageNamed:@"meeting_audio_unmute"] forState:UIControlStateSelected];
        cell.audioImageBtn.selected = !info.isMuteAudio;
    }
    cell.videoImageBtn.selected = !info.isMuteVideo;
    cell.pinImageView.hidden    = ![_pinList containsObject:info.UUID];
    if ([_lecturesList.firstObject isEqualToString:info.UUID]) {
        NSString *lecturerStr = [NSString stringWithFormat:@"%@ (%@)",info.name,NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_LECTURER", nil)];
        if (info.isMe) {
            NSString *meStr = [info.name stringByReplacingOccurrencesOfString:@")" withString:@""];
            lecturerStr = [NSString stringWithFormat:@"%@,%@)",meStr,NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_LECTURER", nil)];
        }
        cell.nameLabel.text = lecturerStr ;
    }

    @WeakObj(self);
    cell.didSelectedCell = ^{
        @StrongObj(self)
        self.selectIndex = indexPath.row;
        if (info.isMe) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(rostListMuteMicroPhone:)]) {                if (!info.muteAudio) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"meeting_you_youselfmute", nil)];
                }
                [self.delegate rostListMuteMicroPhone:info.muteAudio];
            }
        }else{
            [self showMuteViewWithInfo:info];
        }
    };
    return cell;
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectIndex = indexPath.row;
    ParticipantListModel *info = self.searchListData[indexPath.row];
    [self.searchBar.searchTextField resignFirstResponder];
    [self showMuteViewWithInfo:info];
}

#pragma mark - action

- (void)updateMicrophoneImage:(int)microphoneValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        RosterListTableViewCell *cell = (RosterListTableViewCell *)[self.rosterListTableView cellForRowAtIndexPath:indexPath];
        if (microphoneValue == 100) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"meeting_audio_mute"] forState:UIControlStateNormal];
            self->isMuteMic = YES; return;
        }
        self->isMuteMic = NO;
        
        if (microphoneValue == 1) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_0"] forState:UIControlStateNormal];
        }else if (microphoneValue == 2) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_1"] forState:UIControlStateNormal];
        }else if (microphoneValue == 3) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_2"] forState:UIControlStateNormal];
        }else if (microphoneValue == 4) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_3"] forState:UIControlStateNormal];
        }else if (microphoneValue == 5) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_4"] forState:UIControlStateNormal];
        }else if (microphoneValue == 6) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_5"] forState:UIControlStateNormal];
        }else if (microphoneValue == 7) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_6"] forState:UIControlStateNormal];
        }else if (microphoneValue == 8) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_7"] forState:UIControlStateNormal];
        }else if (microphoneValue == 9) {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_8"] forState:UIControlStateNormal];
        }else {
            [cell.audioImageBtn setImage:[UIImage imageNamed:@"frtc_microphone_little_9"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark -- getter
- (UITableView *)rosterListTableView {
    if (!_rosterListTableView) {
        _rosterListTableView = [[UITableView alloc] init];
        _rosterListTableView.delegate = self;
        _rosterListTableView.dataSource = self;
        [_rosterListTableView registerClass:[RosterListTableViewCell class]
                     forCellReuseIdentifier:KRostListTableViewCell];
        _rosterListTableView.backgroundColor = KBGColor;
        _rosterListTableView.rowHeight = kRosterCellHeight;
        _rosterListTableView.separatorInset = UIEdgeInsetsZero;
        _rosterListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _rosterListTableView.tableFooterView = [UIView new];
        [self.rosterMainView addSubview:_rosterListTableView];
        
    }
    return _rosterListTableView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1.0;
        _titleLabel.text = @"Display Name";
        _titleLabel.font = [UIFont systemFontOfSize:18.0];
        _titleLabel.textColor = [UIColor blackColor];
        [self.rosterMainView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [UIView new];
        _backGroundView.userInteractionEnabled = YES;
        [self.view addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (UIView *)rosterMainView {
    if (!_rosterMainView) {
        _rosterMainView = [UIView new];
        _rosterMainView.clipsToBounds = YES;
        _rosterMainView.userInteractionEnabled = YES;
        [self.backGroundView addSubview:_rosterMainView];
    }
    return _rosterMainView;
}

- (UIButton *)closeButton {
    if(!_closeButton) {
        @WeakObj(self);
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"meeting_rost_right"]
                      forState:UIControlStateNormal];
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self disMiss];
        }];
        [self.rosterMainView addSubview:_closeButton];
    }
    
    return _closeButton;
}

- (RosterPresenter *)presenter {
    if (!_presenter) {
        _presenter = [RosterPresenter new];
        [_presenter bindView:self];
    }
    return _presenter;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.clipsToBounds = YES;
        //_bottomView.alpha = 0;
        _bottomView.backgroundColor = UIColor.whiteColor;
        [self.rosterMainView addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)muteButton {
    if(!_muteButton) {
        @WeakObj(self);
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteButton.layer.cornerRadius = KCornerRadius;
        _muteButton.backgroundColor = KBGColor;
        [_muteButton setTitle:NSLocalizedString(@"meeting_muteall", nil) forState:UIControlStateNormal];
        [_muteButton setTitleColor:kMainColor forState:UIControlStateNormal];
        _muteButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_muteButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            [AllMuteView showAllMuteAlertView:YES allMuteCallBack:^(BOOL isAllow) {
                @StrongObj(self)
                [self.presenter muteAllParticipantsWithMeetingNumber:self.meetingNumber allowUnmute:isAllow];
            }];
        }];
        [self.bottomView addSubview:_muteButton];
    }
    return _muteButton;
}

- (UIButton *)unmuteButton {
    if(!_unmuteButton) {
        @WeakObj(self);
        _unmuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unmuteButton setTitle:NSLocalizedString(@"meeting_ask_unmute", nil) forState:UIControlStateNormal];
        [_unmuteButton setTitleColor:kMainColor forState:UIControlStateNormal];
        [_unmuteButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            [AllMuteView showAllMuteAlertView:NO allMuteCallBack:^(BOOL isAllow) {
                @StrongObj(self)
                [self.presenter unMuteAllParticipantsWithMeetingNumber:self.meetingNumber];
            }];
        }];
        _unmuteButton.backgroundColor = KBGColor;
        _unmuteButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _unmuteButton.layer.cornerRadius = KCornerRadius;
        [self.bottomView addSubview:_unmuteButton];
    }
    return _unmuteButton;
}

- (UIButton *)shareButton {
    if(!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setTitle:NSLocalizedString(@"meeting_invite_join", nil) forState:UIControlStateNormal];
        @WeakObj(self)
        [_shareButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if(self.delegate && [self.delegate respondsToSelector:@selector(rostShareInvitationInfo)]) {
                [self.delegate rostShareInvitationInfo];
            }
        }];
        [_shareButton setTitleColor:KTextColor forState:UIControlStateNormal];
        _shareButton.backgroundColor = KBGColor;
        _shareButton.layer.cornerRadius = KCornerRadius;
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [self.bottomView addSubview:_shareButton];
    }
    return _shareButton;
}

- (NSMutableArray *)searchListData {
    if (!_searchListData) {
        _searchListData = [NSMutableArray array];
    }
    return _searchListData;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]init];
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.layer.borderColor = KDetailTextColor.CGColor;
        _searchBar.layer.borderWidth = 0.5;
        _searchBar.layer.cornerRadius = 4;
        _searchBar.layer.masksToBounds = YES;
        UITextField *searchTextField = _searchBar.searchTextField;
        searchTextField.borderStyle = UITextBorderStyleNone;
        searchTextField.textColor = KTextColor;
        searchTextField.leftView.tintColor = KDetailTextColor;
        [self.rosterMainView addSubview:_searchBar];
    }
    return _searchBar;
}

- (FrtcRequestUnmuteItemView *)requestUnmuteView {
    if (!_requestUnmuteView) {
        _requestUnmuteView = [[FrtcRequestUnmuteItemView alloc]init];
        _requestUnmuteView.frame = CGRectMake(0, 0, KScreenWidth, 40);
        _requestUnmuteView.userInteractionEnabled = YES;
        @WeakObj(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self pushRequestUnmuteListView];
        }];
        [_requestUnmuteView addGestureRecognizer:tap];
    }
    return _requestUnmuteView;
}

@end
