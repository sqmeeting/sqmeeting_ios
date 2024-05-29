#import "FrtcMeetingReminderView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "UIGestureRecognizer+Extensions.h"
#import "UIView+Extensions.h"
#import "NSBundle+FLanguage.h"
#import "UIImage+Extensions.h"
#import "FrtcMeetingReminderCell.h"
#import "FrtcMakeCallClient.h"
#import "FrtcCall.h"
#import "MBProgressHUD+Extensions.h"
#import "UIView+Toast.h"
#import "FrtcUserModel.h"
#import "UIViewController+Extensions.h"
#import "FrtcMeetingReminderDataManager.h"

#define kMEETINGREMINDERCELL @"FrtcMeetingReminderCell"

static FrtcMeetingReminderView *meetingRemindView = nil;
static FMeetingReminderInfo meetingRemindSelectedBlock = nil;

@interface FrtcMeetingReminderView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *dataSoure;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation FrtcMeetingReminderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = UIColor.clearColor;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = KCornerRadius;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.mas_equalTo(300);
        }];
        
        //top
        UIView *headerView = [[UIView alloc]init];
        headerView.clipsToBounds = YES;
        headerView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(40);
        }];
        
        UIImageView *imageBgView = [[UIImageView alloc]init];
        imageBgView.image = [UIImage imageNamed:@"meeting_reminder_topImg"];
        [headerView addSubview:imageBgView];
        [imageBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.text = [NSString stringWithFormat:@"0%@",NSLocalizedString(@"MEETING_REMINDER_MEETINGALERTNUMBER", nil)];
        self.titleLabel.textColor = UIColor.whiteColor;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [headerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(headerView);
        }];
        
        //center
        self.tableView = [[UITableView alloc]init];
        self.tableView.backgroundColor = UIColor.whiteColor;
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight  = 70;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[FrtcMeetingReminderCell class] forCellReuseIdentifier:kMEETINGREMINDERCELL];
        [self.contentView addSubview:self.tableView];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(0);
        }];
        
        //bottom
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancleButton setTitle:NSLocalizedString(@"MEETING_REMINDER_IGNORE", nil) forState:UIControlStateNormal];
        [cancleButton setTitleColor:kMainColor forState:UIControlStateNormal];
        [cancleButton setBackgroundImage:[UIImage imageFromColor:UIColorHex(0xf0f0f5)] forState:UIControlStateNormal];
        [cancleButton setBackgroundImage:[UIImage imageFromColor:kCellSelecteColor] forState:UIControlStateHighlighted];
        cancleButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        @WeakObj(self)
        [cancleButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            [self disMiss];
        }];
        [self.contentView addSubview:cancleButton];
        [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tableView.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(kButtonHeight-4);
        }];
        
        [self.contentView setCornerRadius:12 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    }
    return self;
}

- (void)show {
    UIWindow *keyWindow = [FrtcHelpers keyWindow];
    self.frame = keyWindow.bounds;
    [keyWindow addSubview:self];
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
}

- (void)disMiss{
    [FrtcMeetingReminderDataManager sharedInstance].hasShownAlert = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self removeFromSuperview];
    }];
}

- (void)setNotificationList:(NSArray<NSDictionary *> *)notificationList {
    _notificationList = notificationList;
    [self.dataSoure addObjectsFromArray:_notificationList];
    [self reloadTableView];
}

- (void)reloadTableView {
    NSInteger count = self.dataSoure.count;
    self.titleLabel.text = [NSString stringWithFormat:@"%td%@",count,NSLocalizedString(@"MEETING_REMINDER_MEETINGALERTNUMBER", nil)];
    if (count >= 4 ) {
        count = 3.5;
    }
    CGFloat height = count * 70;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSoure.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrtcMeetingReminderCell *cell = [tableView dequeueReusableCellWithIdentifier:kMEETINGREMINDERCELL forIndexPath:indexPath];
    NSDictionary *dict = self.dataSoure[indexPath.row];
    cell.titleLabel.text  = dict[@"title"];
    cell.detailLabel.text = dict[@"subtitle"];;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataSoure[indexPath.row];
    [self joinMeetingWithMeetingNumber:dict[@"meeting_number"] meetingPassword:dict[@"meeting_password"]];
    [self deleteDataSoure:indexPath.row];
}

- (void)deleteDataSoure:(NSInteger)index {
    [self.dataSoure removeObjectAtIndex:index];
    [self reloadTableView];
    if (self.dataSoure.count == 0) {
        [self disMiss];
    }
}

- (void)joinMeetingWithMeetingNumber:(NSString *)meetingNumber
                     meetingPassword:(NSString *)meetingPassword {
    
    if (![FrtcHelpers isNetwork]) {
        [[FrtcHelpers keyWindow] makeToast:NSLocalizedString(@"meeting_network_error", nil)];
        return;
    }
    if ([FrtcHelpers f_isInMieeting]) {
        return;
    }
    NSString *userName = isLoginSuccess ? [FrtcUserModel fetchUserInfo].real_name : [FrtcLocalInforDefault getMeetingDisPlayName];
    if(userName == nil || [userName isEqualToString:@""]) {
        userName = [UIDevice currentDevice].name;
    }
    NSString *conferenceCallRate = [[FrtcUserDefault sharedUserDefault] objectForKey:CALL_RATE];
    int numberCallRate = [conferenceCallRate intValue];
    [[FrtcHelpers keyWindow] makeToastActivity:CSToastPositionCenter];
    FRTCSDKCallParam callParam;
    callParam.conferenceNumber = meetingNumber;
    callParam.clientName = userName;
    callParam.callRate = numberCallRate;
    callParam.muteCamera     = YES;
    callParam.muteMicrophone = YES;
    callParam.audioCall      = NO;
    if (isLoginSuccess) {
        callParam.userToken = [FrtcUserModel fetchUserInfo].user_token;
    }
    
    if (!kStringIsEmpty(meetingPassword)) {
        callParam.password = meetingPassword;
    }
    [self makeCallWithParam:callParam];
}

- (void)makeCallWithParam:(FRTCSDKCallParam )callParam {
    [[FrtcMakeCallClient sharedSDKContext] makeCall:[FrtcHelpers getCurrentVC] withCallParam:callParam withCallSuccessBlock:^{
        [[FrtcHelpers keyWindow] hideToastActivity];
    } withCallFailureBlock:^(FRTCMeetingStatusReason status, NSString * _Nonnull errMsg) {
        if (kStringIsEmpty(errMsg)) { return; }
        [[FrtcHelpers keyWindow] hideToastActivity];
    } withInputPassCodeCallBack:^{
        [[FrtcHelpers keyWindow] hideToastActivity];
        [[FrtcHelpers getCurrentVC] showTextFieldAlertWithTitle:NSLocalizedString(@"join_meeting_password", nil) textFieldStyle:FTextFieldPassword alerAction:^(NSInteger index, NSString * _Nonnull alertString) {
            if (index == 1) {
                [[FrtcHelpers keyWindow] makeToastActivity:CSToastPositionCenter];
                [[FrtcCall frtcSharedCallClient] frtcSendCallPasscode:alertString];
                [[FrtcUserDefault sharedUserDefault] setObject:alertString forKey:MEETING_PASSWORD];
            }else{
                [[FrtcCall frtcSharedCallClient] frtcHangupCall];
            }
        }];
    }];
}

- (NSMutableArray <NSDictionary *> *)dataSoure {
    if (!_dataSoure) {
        _dataSoure = [[NSMutableArray alloc]init];
    }
    return _dataSoure;
}

@end
