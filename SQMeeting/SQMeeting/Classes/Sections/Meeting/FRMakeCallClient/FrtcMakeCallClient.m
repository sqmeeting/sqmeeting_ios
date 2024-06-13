#import "FrtcMakeCallClient.h"
#import "ParticipantListModel.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcScanQRViewController.h"
#import "YYModel.h"
#import "FrtcUserModel.h"
#import "FrtcMeetingInfoView.h"
#import "FrtcManagement.h"
#import "PYNavigationController.h"
#import "UIViewController+Extensions.h"
#import "TalkingToolBarView.h"
#import "TopLayoutBarView.h"
#import "EndMeetingController.h"
#import "WZLBadgeImport.h"
#import "RostListViewController.h"
#import "FrtcStatisticalModel.h"
#import "OverlayMessageModel.h"
#import "TopOverLayMessageView.h"
#import "FrtcMeetingInfoLeftView.h"
#import "FrtcMeetingInfoViewController.h"
#import "FrtcSignLoginPresenter.h"
#import "UIView+Toast.h"
#import "FrtcAlertView.h"
#import "FrtcAudioVideoAuthManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSData+AES.h"
#import "FrtcContentShareGadget.h"
#import "FrtcTimer.h"
#import "FrtcCallNetworkErrorView.h"
#import "FrtcShareMeetingMaskView.h"
#import "FrtcInvitationInfoManage.h"
#import "FrtcManager.h"
#import "FrtcSettingMoreView.h"
#import "FrtcSendOverlayMessageView.h"
#import "Masonry.h"
#import "FrtcMediaStaticsInstance.h"
#import "FrtcLiveStatusModel.h"
#import "FrtcLiveTipsMaskView.h"
#import "RosterPresenter.h"
#import "FrtcLiveManagerView.h"
#import "FrtcRecordingMaskView.h"
#import "FrtcShareLiveUrlMaskView.h"
#import "FrtcRequestUnmuteListMaskView.h"
#import "FrtcRequestUnmuteListViewController.h"
#import "FrtcRequestUnmuteModel.h"
#import "MuteView.h"
#import "FrtcCAlertView.h"
#import "FrtcAudioVideoAuthManager.h"

static FrtcMakeCallClient *callClient = nil;
static CallSuccessBlock fCallSuccessBlock = nil;
static CallFailureBlock fCallFailureBlock = nil;
static InputPassCodeCallBack fInputPassCodeCallBack = nil;

@interface FrtcMakeCallClient () <TalkingToolBarViewDelegate,EndMeetingControllerDelegate,
RostListViewControllerDelegate, TopOverLayMessageViewDelegate,TopLayoutBarViewProtocol,FrtcCallDelegate>
{
    FRTCSDKCallParam  callParam;
    MASConstraint     *toolBarBottomConstraint;
    MASConstraint     *topLayouYConstraint;
    FrtcLiveStatusModel  *liveStatusModel;
    NSString          *currentUserUUID;
    CGFloat           badgenumber;
    BOOL              isAppear;
    BOOL              isPinSelf;
}

@property (nonatomic, weak)   UIViewController           *parentViewController;
@property (nonatomic, strong) TalkingToolBarView         *toolBarView;
@property (nonatomic, strong) TopLayoutBarView           *topLayoutBarView;
@property (nonatomic, strong) RostListViewController     *rosterListViewController;
@property (nonatomic, strong) TopOverLayMessageView      *messageView;

@property (nonatomic, strong) FrtcSettingMoreView           *settingMoreView;
@property (nonatomic, strong) FrtcCallNetworkErrorView      *networkError;
@property (nonatomic, strong) UIStackView                *meetingStatusView;
@property (nonatomic, strong) FrtcLiveTipsMaskView          *liveStatusView;
@property (nonatomic, strong) FrtcLiveTipsMaskView          *recordingStatusView;
@property (nonatomic, strong) FrtcLiveManagerView           *liveManagerView;
@property (nonatomic, strong) FrtcRecordingMaskView         *recordingMaskView;
@property (nonatomic, strong) FrtcRequestUnmuteListMaskView *requestUnmuteListView;

@property (nonatomic, strong) NSMutableArray<NSString *>             *lecturesList;
@property (nonatomic, strong) NSMutableArray<NSString *>             *pinList;
@property (nonatomic, strong) NSMutableArray<ParticipantListModel *> *participantList;
@property (nonatomic, strong) NSMutableArray<FrtcRequestUnmuteModel *>  *requestUnmuteList;
@property (nonatomic, strong) NSMutableDictionary                    *requestUnmuteDict;


@property (nonatomic) NSInteger        num;
@property (nonatomic) NSInteger        participantsNum;
@property (nonatomic, copy) NSString   *userName;
@property (nonatomic, strong) NSTimer  *staticsTimer;
@property (nonatomic, strong) NSString *reconnectTimer;

@property (nonatomic, strong) FrtcStatisticalModel         *staticsModel;
@property (nonatomic, strong) OverlayMessageModel   *messageOverLayModel;
@property (nonatomic, strong) FHomeMeetingListModel *meetingInfo;
@property (nonatomic, strong) FrtcAudioVideoAuthManager *audioVideoManager;
@property (nonatomic) FRTCMeetingStatus callMeetingStatus;

@property (nonatomic, getter=isServerMute)         BOOL serverMute;
@property (nonatomic, getter=isAllowUserUnMute)    BOOL allowUserUnMute;
@property (nonatomic, getter=isMeetingOperator)    BOOL meetingOperator;
@property (nonatomic, getter=isOverlayMessage)     BOOL overlayMessage;
@property (nonatomic, getter=isJoinMeetingSuccess) BOOL joinMeetingSuccess;
@property (nonatomic, getter=isShowUnMuteView)     BOOL showUnMuteView;
@property (nonatomic, getter=isSharing)            BOOL sharing;
@property (nonatomic, getter=isServerUrlSame)      BOOL serverUrlSame;
@property (nonatomic, getter=isReconnect)          BOOL reconnect;
@property (nonatomic, getter=isPortrait)           BOOL portrait;
@property (nonatomic, getter=isUnmuteRequesting)   BOOL unmuteRequesting;
@property (nonatomic, getter=isShowRequestUnMuteView) BOOL showRequestUnMuteView;

@end

@implementation FrtcMakeCallClient

+ (FrtcMakeCallClient *)sharedSDKContext {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callClient = [[FrtcMakeCallClient alloc] init];
    });
    return callClient;
}

-(instancetype)init {
    [self registerNotification];
    self.overlayMessage = NO;
    
    self.callMeetingStatus = MEETING_STATUS_IDLE;
    return self;
}

- (void)dealloc {
}

- (void)registerNotification {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(controlBarHidden:)
                               name:FMeetingUIDisappearOrNotNotification object:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [notificationCenter addObserver:self selector:@selector(audioSessionRouteChangeObserver:)
                               name:AVAudioSessionRouteChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground)
                               name:UIApplicationWillEnterForegroundNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateShareContentButtonState:)
                               name:kShareContentDisconnectNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(updateUmmuteRequestList:)
                               name:kUpdateUnmuteReuqestList object:nil];
}

- (void)makeCall:(UIViewController *)parentViewController
   withCallParam:(FRTCSDKCallParam)param
withCallSuccessBlock:(CallSuccessBlock)callSuccessBlock
withCallFailureBlock:(CallFailureBlock)callFailureBlock
withInputPassCodeCallBack:(InputPassCodeCallBack)inputPassCodeBlock{
    
    fCallSuccessBlock = callSuccessBlock;
    fCallFailureBlock = callFailureBlock;
    fInputPassCodeCallBack = inputPassCodeBlock;
    
    [self changeFrtcCallReconectValue:NO];
    
    [self.requestUnmuteList removeAllObjects];
    [self.participantList removeAllObjects];
    [self.lecturesList removeAllObjects];
    [self.pinList removeAllObjects];
    
    self.parentViewController = parentViewController;
    self->callParam = param;
    self->callParam.floatWindow = NO;
    self->currentUserUUID = [FrtcCall frtcSharedCallClient].frtcGetClientUUID;
    self->isPinSelf = NO;
    self.sharing = NO;
    self.unmuteRequesting = NO;
    self.reconnect = NO;
    self.showRequestUnMuteView = NO;
    isAppear = YES;
    if (liveStatusModel) {
        liveStatusModel.live      = NO;
        liveStatusModel.recording = NO;
    }
    
    [self frtcMakeCallWithCallParam:self->callParam];
}

- (void)frtcMakeCallWithCallParam:(FRTCSDKCallParam)param {
    
    self.joinMeetingSuccess = NO;
    [[FrtcUserDefault sharedUserDefault] setObject:@"" forKey:MEETING_PASSWORD];
    [FrtcLocalInforDefault saveYourSelf:NO];
    self.userName = param.clientName;
    
    @WeakObj(self);
    
    [FrtcCall frtcSharedCallClient].callDelegate = self;
    [[FrtcCall frtcSharedCallClient] frtcMakeCall:param
                                       controller:self.parentViewController
                                   callCompletion:^(FRTCMeetingStatus callMeetingStatus,
                                                    FRTCMeetingStatusReason status,
                                                    FRTCMeetingStatusSuccessParam callReaultParam,
                                                    UIViewController * _Nullable meetingViewController) {
        @StrongObj(self)
        UserInfoModel *userInfo = [FrtcUserModel fetchUserInfo];
        BOOL operator = userInfo.isMeetingOperator || [userInfo.user_id isEqualToString:callReaultParam.ownerID] || userInfo.isSystemAdmin;
        
        if (kStringIsEmpty(param.callUrl)) {
            self.serverUrlSame = YES;
            self.meetingOperator = operator;
        }else{
            self.serverUrlSame = [self serviceIsSame];
            self.meetingOperator = self.serverUrlSame ? operator : NO;
        }
        
        NSString *meetingvcs = [NSString stringWithFormat:@"[] %@",meetingViewController];
        [kFrtcCallShared f_InfoLog:meetingvcs];
        ISMLog(@"meetingViewController = %@",meetingViewController);
        self.parentViewController = meetingViewController;
        
        self.callMeetingStatus = callMeetingStatus;
        if(callMeetingStatus == MEETING_STATUS_CONNECTE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FrtcManager.inMeeting = YES;
                [self getMeetingInfoWith:callReaultParam param:param];
                self.joinMeetingSuccess = YES;
                
                if (!self.isReconnect) {
                    [self configTalkBarView];
                    [self configTopLayoutView];
                    [self configTopOverLayMessageView];
                }else {
                    [self muteCamera:self.toolBarView.btnTurnOffCamera.selected];
                }
                [[FrtcMediaStaticsInstance share] startGetMediaStatics];
                if (!self.reconnect) {
                    fCallSuccessBlock();
                }
                self.reconnect = NO;
                [self changeFrtcCallReconectValue:NO];
                [self stopReconnect];
            });
        } else {
            
            self.overlayMessage = NO;
            [self changeFrtcCallReconectValue:NO];
            [[FrtcMediaStaticsInstance share] stopGetMediaStatics];
            [FrtcTimer canelTimer:self->_reconnectTimer];
            
            NSString *failureReason = [self getMeetingErrorInfo:status];
            if(status == MEETING_STATUS_END_ABNORMAL) {
                [self startReconnect];
            }
            fCallFailureBlock(status,failureReason);
            [MBProgressHUD hideHUD];
            
            if (!kStringIsEmpty(failureReason)) {
                [[FrtcHelpers getCurrentVC] showAlertWithTitle:@"" message:failureReason buttonTitles:@[NSLocalizedString(@"ok", nil)] alerAction:^(NSInteger index) { }];
            }
        }
        
    } requestPassword:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            fInputPassCodeCallBack();
        });
    } contentRequest:^{
        @StrongObj(self)
        if(self.isSharing) {
            return;
        } else {
            self.sharing = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[FrtcContentShareGadget sharedInstance] startSendContentStream];
                [[self presentedViewController].view bringSubviewToFront:self.toolBarView];
                [[self presentedViewController].view bringSubviewToFront:self.topLayoutBarView];
            });
        }
    }];
}

- (void)getMeetingInfoWith:(FRTCMeetingStatusSuccessParam)callReaultParam param:(FRTCSDKCallParam)param{
    
    self.meetingInfo.meetingNumber = callReaultParam.conferenceAlias;
    self.meetingInfo.meetingName   = callReaultParam.conferenceName;
    self.meetingInfo.ownerID       = callReaultParam.ownerID;
    //if (callReaultParam.scheduleStartTime == 0) {
    self.meetingInfo.meetingStartTime = [FrtcHelpers currentTimeStr];
    //}else{
    //self.meetingInfo.meetingStartTime = [NSString stringWithFormat:@"%lld",callReaultParam.scheduleStartTime];
    //}
    self.meetingInfo.meetingEndTime  = [NSString stringWithFormat:@"%lld",callReaultParam.scheduleEndTime];
    self.meetingInfo.ownerUserName   = callReaultParam.ownerName;
    self.meetingInfo.meetingUrl      = callReaultParam.meetingUrl;
    self.meetingInfo.groupMeetingUrl = callReaultParam.groupMeetingUrl;
    if (!kStringIsEmpty(callReaultParam.groupMeetingUrl)) {
        self.meetingInfo.recurrence = YES;
    }
    NSString *password = param.password;
    self.meetingInfo.meetingPassword = password;
    self.meetingInfo.password = !kStringIsEmpty(password);
    self.meetingInfo.muteCamera = NO;//param.muteCamera;
    self.meetingInfo.muteMicrophone = NO;//param.muteMicrophone;
    self.meetingInfo.audioCall = param.audioCall;
    UserInfoModel *userInfo1 = [FrtcUserModel fetchUserInfo];
    self.meetingInfo.meetingOperator = userInfo1.isMeetingOperator;
    self.meetingInfo.systemAdmin     = userInfo1.isSystemAdmin;
}

- (NSString *)getMeetingErrorInfo:(FRTCMeetingStatusReason)status {
    
    NSString *failureReason;
    if(status == MEETING_STATUS_SERVERERROR) {
        failureReason = [FrtcHelpers isNetwork] ? NSLocalizedString(@"server_unreachable", nil) : NSLocalizedString(@"meeting_network_error", nil);
    } else if(status == MEETING_STATUS_LOCKED) {
        failureReason = NSLocalizedString(@"meeting_locked", nil);
    } else if(status == MEETING_STATUS_MEETINGNOTEXIST) {
        failureReason = NSLocalizedString(@"meeting_not_exist", nil);
    } else if(status == MEETING_STATUS_SUCCESS) {
        [self endMeetingClicked:NO];
        //failureReason = NSLocalizedString(@"call_ended", nil);
    } else if (status == MEETING_STATUS_STOP) {
        [self endMeetingClicked:NO];
        failureReason = [FrtcLocalInforDefault getYourSelf] ? @"" : NSLocalizedString(@"meeting_host_endMeeting", nil);
    } else if (status == MEETING_STATUS_PASSWORD_TOO_MANY_RETRIES) {
        failureReason = NSLocalizedString(@"meeting_psd_max", nil);
    } else if (status == MEETING_STATUS_PASSWORD_TOO_MANY_RETRIES) {
        failureReason = NSLocalizedString(@"meeting_psdTimeout", nil);
    } else if (status == MEETING_STATUS_REMOVE) {
        [self endMeetingClicked:NO];
        failureReason = NSLocalizedString(@"meeting_host_remove", nil);
    } else if(status == MEETING_STATUS_EXPIRED) {
        failureReason = NSLocalizedString(@"meeting_overdue", nil);
    } else if(status == MEETING_STATUS_NOT_STARTED) {
        failureReason = NSLocalizedString(@"meeting_timeLimit", nil);
    } else if(status == MEETING_STATUS_GUEST_UNALLOWED) {
        failureReason = NSLocalizedString(@"meeting_loginJoin", nil);
    } else if(status == MEETING_STATUS_PEOPLE_FULL) {
        failureReason = NSLocalizedString(@"meeting_full", nil);
    } else if(status == MEETING_STATUS_NO_LICENSE) {
        failureReason = NSLocalizedString(@"meeting_licenseOverdue", nil);
    } else if(status == MEETING_STATUS_LICENSE_MAX_LIMIT_REACHED) {
        failureReason = NSLocalizedString(@"meeting_upgradeLicense", nil);
    }
    return failureReason;
}


#pragma mark - Reconnect

- (void)startReconnect {
    
    [kFrtcCallShared f_InfoLog:@"[reconnect] startReconnect"];

    if (self.reconnect) {
        return;
    }
    
    self.reconnect = YES;
    [self changeFrtcCallReconectValue:YES];
    
    if (self.isSharing) {
        self.sharing = NO;
        self.toolBarView.btnShareContent.selected = UIControlStateNormal;
        [[FrtcContentShareGadget sharedInstance] startRecordScreenSharing:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.fmeeting.removeContentBackView" object:nil];
    }
    
    UIView *parentView = [self presentedViewController].view;
    if (!parentView) { return; }
    
    [parentView insertSubview:self.networkError atIndex:4];
    
    [self.networkError mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    
    [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:NO];
    
    [self reconnectWithCallParam:self->callParam];
}

- (void)stopReconnect {
    [FrtcTimer canelTimer:_reconnectTimer];
    [self removeNetworkErrorMaskView];
}

- (void)reconnectWithCallParam:(FRTCSDKCallParam)param{
    __block int count = 0;
    @WeakObj(self)
    _reconnectTimer = [FrtcTimer timerTask:^{
        @StrongObj(self)
        if (count == 3 ) {
            [self alertMakeCall];
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self frtcMakeCallWithCallParam:self->callParam];
        });
        count ++;
        
        [kFrtcCallShared f_InfoLog:[NSString stringWithFormat:@"[reconnect] count = %d",count]];
        
    } start:0 interval:15 repeats:YES async:YES];
}

- (void)alertMakeCall {
    [FrtcTimer canelTimer:_reconnectTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeNetworkErrorMaskView];
        @WeakObj(self)
        [[self presentedViewController] showAlertWithTitle:@""
                                                   message:NSLocalizedString(@"meeting_networkRejoin", nil)
                                              buttonTitles:@[NSLocalizedString(@"meeting_leave", nil),NSLocalizedString(@"meeting_rejoin", nil)]
                                                alerAction:^(NSInteger index) {
            @StrongObj(self)
            if (index == 0) {
                [self endMeetingClicked:0];
            }else{
                [self frtcMakeCallWithCallParam:self->callParam];
            }
        }];
    });
}

- (void)removeNetworkErrorMaskView{
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *maskView in [[self presentedViewController].view subviews])
        {
            if ([maskView isKindOfClass:[FrtcCallNetworkErrorView class]]) {
                [maskView removeFromSuperview];
            }
        }
    });
}

- (void)changeFrtcCallReconectValue:(BOOL)isReconnect {
    [[FrtcCall frtcSharedCallClient] setValue:[NSNumber numberWithBool:isReconnect]
                                       forKey:@"reconnect"];
}

- (BOOL)serviceIsSame {
    if(self->callParam.callUrl != nil) {
        NSString *cipherString;
        NSDictionary *jsonDict;
        NSData *afterDecodeData = [[NSData alloc]initWithBase64EncodedString:self->callParam.callUrl options:0];
        cipherString  =[[NSString alloc] initWithData:afterDecodeData encoding:NSUTF8StringEncoding];
        if (kStringIsEmpty(cipherString)) {
            NSData *afterDesData = [afterDecodeData AES256DecryptWithKey:kEncryptionKey];
            cipherString  =[[NSString alloc] initWithData:afterDesData encoding:NSUTF8StringEncoding];
            if(kStringIsEmpty(cipherString)) {
                return NO;
            }
            jsonDict = [NSJSONSerialization JSONObjectWithData:afterDesData options:NSJSONReadingMutableLeaves error:nil];
        }else{
            jsonDict = [NSJSONSerialization JSONObjectWithData:afterDecodeData options:NSJSONReadingMutableLeaves error:nil];
        }
        
        if ([jsonDict.allKeys containsObject:@"server_address"]) {
            NSString *tempServerAddress = [jsonDict[@"server_address"] lowercaseString];
            NSString *currentAddress = [[[FrtcUserDefault sharedUserDefault] objectForKey:SERVER_ADDRESS] lowercaseString];
            if(isLoginSuccess && [tempServerAddress isEqualToString:currentAddress]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark -- FrtcCallDelegate

- (void)onParticipantsNumber:(NSInteger)participantsNumber {
    self.participantsNum = participantsNumber;
    self.toolBarView.btnFloatingFrame.enabled = self.participantsNum > 1;
    if (self->callParam.audioCall) {
        self.toolBarView.btnFloatingFrame.enabled = NO;
    }
    self.toolBarView.badgeView.text = [NSString stringWithFormat:@"%ld",self.participantsNum];
}

- (void)onRostList:(NSString *)rostListString {
    NSData *data = [rostListString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSArray *fullRostList = dic[@"rosters"];
    if(fullRostList.count == 0) {
        [self.participantList enumerateObjectsUsingBlock:^(ParticipantListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![obj.UUID isEqualToString:self->currentUserUUID]) {
                [self.participantList removeObject:obj];
            }
        }];
    } else {
        for(NSDictionary *dic in fullRostList) {
            BOOL find = NO;
            ParticipantListModel *tempParticipantModel;
            for(ParticipantListModel *participantModel in self.participantList) {
                tempParticipantModel = participantModel;
                if([participantModel.UUID isEqualToString:dic[@"uuid"]]) {
                    find = YES;
                    break;
                }
            }
            
            if(!find) {
                [self.participantList removeObject:tempParticipantModel];
            }
        }
    }
    [_rosterListViewController updateRosterList:self.participantList];
}

- (void)onLectureList:(NSMutableArray<NSString *> *)lectureListArray {
    [self.lecturesList removeAllObjects];
    [self.lecturesList addObjectsFromArray:lectureListArray];
    for (NSString *lecture in self.lecturesList) {
        if ([lecture isEqualToString:self->currentUserUUID]) {
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_settLecture", nil)];
            break;
        };
    }
    [_rosterListViewController updateLecturesList:self.lecturesList];
}

- (void)onReceiveAllowUnmute {
    if (self.toolBarView.btnMuteMicrophone.isSelected && !self.isShowRequestUnMuteView) {
        self.unmuteRequesting = NO;
        self.showRequestUnMuteView = YES;
        if ([FrtcCall frtcSharedCallClient].isFloatWindow) { return; }
        FrtcCAlertView *alertView = [[FrtcCAlertView alloc]init];
        [alertView showAlertWithTitle:NSLocalizedString(@"MEETING_REQUESTUNMUTE_OK_TITLE", nil)
                         withSubtitle:NSLocalizedString(@"MEETING_REQUESTUNMUTE_OK_MESSAGE", nil)
                      withCustomImage:nil
                  withDoneButtonTitle:NSLocalizedString(@"MEETING_REQUESTUNMUTE_OK_OK", nil)
                           andButtons:nil];
        [alertView addButton:NSLocalizedString(@"MEETING_REQUESTUNMUTE_OK_CANCLE", nil) withActionBlock:^{
            self.showRequestUnMuteView = NO;
        }];
        [alertView doneActionBlock:^{
            self.showRequestUnMuteView = NO;
            [self frtcMuteMicroPhone:NO];
        }];
    }
}

- (void)onReceiveUnmuteRequest:(NSMutableDictionary *)requestUnmuteDictionary {
    NSDictionary *unmuteRequest = requestUnmuteDictionary;
    NSString *uuid = [unmuteRequest allKeys][0];
    NSString *name = [unmuteRequest allValues][0];
    [self.requestUnmuteDict setObject:name forKey:uuid];
    [self.requestUnmuteList removeAllObjects];
    for (int i = 0 ; i < [self.requestUnmuteDict allKeys].count ; i++) {
        NSString *uuid = [self.requestUnmuteDict allKeys][i];
        NSString *name = [self.requestUnmuteDict allValues][i];
        FrtcRequestUnmuteModel *model = [[FrtcRequestUnmuteModel alloc]init];
        model.uuid = uuid; model.name = name;
        [self.requestUnmuteList addObject:model];
    }
    [kNotificationCenter postNotificationName:kUpdateRequestUnmuteList object:self.requestUnmuteList];
    
    if (_rosterListViewController) {
        [_rosterListViewController updateUnmuteRequestList:self.requestUnmuteList];
    }
    if (self.requestUnmuteList.count > 0 ) {
        self.toolBarView.redDotView.hidden = NO;
    }
    UIView *parentView = [self presentedViewController].view;
    self.requestUnmuteListView.unmuteName = name;
    if(![self.requestUnmuteListView isDescendantOfView:parentView]) {
        [parentView addSubview:self.requestUnmuteListView];
        [self.requestUnmuteListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-kToolBarHeight);
            make.height.mas_equalTo(40);
            make.width.mas_lessThanOrEqualTo(LAND_SCAPE_HEIGHT - 50);
            make.centerX.mas_equalTo(parentView);
        }];
        
        [FrtcTimer timerTask:^{
            [UIView animateWithDuration:0.25 animations:^{
                self.requestUnmuteListView.hidden = YES;
            } completion:^(BOOL finished) {
                [self.requestUnmuteListView removeFromSuperview];
                self.requestUnmuteListView = nil;
            }];
        } start:4 interval:10 repeats:NO async:NO];
    }
}

- (void)onMeetingMessage:(NSString *)message {
    self.overlayMessage = YES;
    self.messageOverLayModel = [OverlayMessageModel yy_modelWithJSON:message];
    
    UIView *parentView = [self presentedViewController].view;
    
    if(self.isOverlayMessage) {
        if(self.messageOverLayModel.enabledMessageOverlay) {
            if (self.isReconnect) {
                [self removeOverLayMessageView];
                [self configTopOverLayMessageView];
            }
        } else {
            self.overlayMessage = NO;
            [self removeOverLayMessageView];
            return;
        }
    } else {
        if(self.messageOverLayModel.enabledMessageOverlay) {
            self.overlayMessage = YES;
        } else {
            self.overlayMessage = NO;
            return;
        }
    }
    
    if([self.messageView isDescendantOfView:parentView]) {
        if([self.messageOverLayModel.type isEqualToString:@"global"]) {
            if([self.messageView isDescendantOfView:parentView]) {
                [self.messageView updateNewAnimation];
                [self updateOverlayMessageView];
            } else {
                [self configTopOverLayMessageView];
            }
        }else{
            [self configTopOverLayMessageView];
        }
    } else {
        if(self.callMeetingStatus == MEETING_STATUS_CONNECTE){
            [self configTopOverLayMessageView];
        }
    }
}

- (void)onMute:(BOOL)mute allowSelfUnmute:(BOOL)allowSelfUnmute {
    self.serverMute = mute;
    self.allowUserUnMute = allowSelfUnmute;
    if (self.toolBarView.btnMuteMicrophone.isSelected) {
        if (!self.serverMute && self.isJoinMeetingSuccess && !self.isShowUnMuteView) {
            if ([FrtcCall frtcSharedCallClient].isFloatWindow) { return; }
            @WeakObj(self);
            self.showUnMuteView = YES;
            [FrtcAlertView showAlertViewWithTitle:NSLocalizedString(@"join_UNmute", nil)
                                          message:NSLocalizedString(@"meeting_host_openMicrophone", nil)
                                     buttonTitles:@[NSLocalizedString(@"meeting_keep_mute", nil),NSLocalizedString(@"unmute_now_new", nil)]
                                didSelectCallBack:^(NSInteger index) {
                @StrongObj(self);
                self.showUnMuteView = NO;
                if (index == 1) {
                    [self frtcMuteMicroPhone:NO];
                    [self updateRosterList];
                }
            }];
        }
    }
    if (self.serverMute && self.isJoinMeetingSuccess) {
        NSString *tipsString = NSLocalizedString(@"meeting_Host_mute", nil);
        [MBProgressHUD showMessage:tipsString];
        [self frtcMuteMicroPhone:self.serverMute];
    }
    
    if (self.serverMute && !self.isJoinMeetingSuccess) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *tipsString = NSLocalizedString(@"meeting_you_needspeak", nil);
            [MBProgressHUD showMessage:tipsString];
        });
    }
    
    [self updateRosterList];
}

- (void)onNetworkStateChanged:(NSInteger)state {
    
    if ([FrtcCall frtcSharedCallClient].frtcGetCurrentRemotePeopleVideoMuteStatus) {
        return;
    }
    
    if ([FrtcCall frtcSharedCallClient].isFloatWindow) { return; }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self presentedViewController] showAlertWithTitle:@""
                                                   message:NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_MESSAGE", nil) buttonTitles:@[NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_CANCLE", nil),NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_OK", nil)]
                                                alerAction:^(NSInteger index) {
            if (index == 1) {
                [self muteCamera:YES];
                self.toolBarView.btnTurnOffCamera.selected = YES;
                [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:YES];
            }
        }];
    });
}

- (void)onContentState:(NSInteger)state {
    NSInteger sharingContent = state;
    if (1 == sharingContent && self.isSharing) {
        return;
    }
    
    if (0 == sharingContent && self.isSharing) {
        self.sharing = NO;
        self.toolBarView.btnShareContent.selected = UIControlStateNormal;
        [[FrtcContentShareGadget sharedInstance] startRecordScreenSharing:NO];
    }
}

- (void)onRecordingLiveStateChange:(NSDictionary *)resultDictionary {
    NSString *liveStatusStr = resultDictionary.yy_modelToJSONString;

    [kFrtcCallShared f_InfoLog:[NSString stringWithFormat:@"[iOS Live] %@",liveStatusStr]];
    
    NSDictionary *liveStatus = resultDictionary;
    FrtcLiveStatusModel *model = [FrtcLiveStatusModel yy_modelWithDictionary:liveStatus];
    
    if (_settingMoreView) {
        _settingMoreView.liveButton.selected   = model.isLive;
        _settingMoreView.recordButton.selected = model.isRecording;
    }
    
    UIView *parentView = [self presentedViewController].view;
    if (!parentView) { return; }
    
    if (self.isMeetingOperator) {
        
        [parentView addSubview:self.liveManagerView];
        [self.liveManagerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.portrait ? 10 : isiPhoneX ? (KStatusBarHeight + 10) : 20);
            make.top.mas_equalTo(KNavBarHeight + 10);
        }];
        
        if (!liveStatusModel.isRecording && model.isRecording) {
            self.liveManagerView.recordView.hidden = NO;
            [MBProgressHUD showMessage:NSLocalizedString(@"FM_VIDEO_RECORDING_START_REMINDER", @"Recording started with meeting layout of the host")];
            [parentView addSubview:self.recordingMaskView];
            [self.recordingMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-kToolBarHeight);
                make.width.mas_equalTo(LAND_SCAPE_HEIGHT);
                make.centerX.equalTo(parentView);
            }];
        }
        
        if (!liveStatusModel.isLive && model.isLive) {
            self.liveManagerView.liveView.hidden = NO;
            [MBProgressHUD showMessage:NSLocalizedString(@"FM_VIDEO_STREAMING_START_REMINDER", @"Live started with meeting layout of the host")];
        }
        
        if (liveStatusModel.isLive && !model.isLive) {
            [UIView animateWithDuration:0.25 animations:^{
                self.liveManagerView.liveView.hidden = YES;
            }];
        }
        
        if (liveStatusModel.isRecording && !model.isRecording) {
            [UIView animateWithDuration:0.25 animations:^{
                self.liveManagerView.recordView.hidden = YES;
            }];
        }
        
    }else{
        
        [parentView addSubview:self.meetingStatusView];
        [self.meetingStatusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.portrait ? 0 : isiPhoneX ? (KStatusBarHeight + 10) : 20);
            make.top.mas_equalTo(KNavBarHeight + 10);
        }];
        
        [self.meetingStatusView addArrangedSubview:self.liveStatusView];
        [self.meetingStatusView addArrangedSubview:self.recordingStatusView];
        
        [@[self.liveStatusView,self.recordingStatusView] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(35);
        }];
        
        if (!liveStatusModel.isLive && model.isLive) {
            self.liveStatusView.hidden = NO;
            [self.liveStatusView setTipsStatus:FLiveTipsStatusLive];
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_start_live", nil)];
        }
        
        if (!liveStatusModel.isRecording && model.isRecording) {
            self.recordingStatusView.hidden = NO;
            [self.recordingStatusView setTipsStatus:FLiveTipsStatusRecording];
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_start_recording", nil)];
        }
        
        if (liveStatusModel.isLive && !model.isLive) {
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_end_live", nil)];
            [UIView animateWithDuration:0.25 animations:^{
                self.liveStatusView.hidden = YES;
            }];
        }
        
        if (liveStatusModel.isRecording && !model.isRecording) {
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_end_recording", nil)];
            [UIView animateWithDuration:0.25 animations:^{
                self.recordingStatusView.hidden = YES;
            }];
        }
    }
    
    if (!model.isLive && !model.isRecording) {
        [self removeLiveAndRecordStatusView];
    }
    
    liveStatusModel = model;
}

- (void)onDidChangeOrientation:(BOOL)isPortrait {
    
    self.portrait = isPortrait;
    UIView *parentView = [self presentedViewController].view;
    if (self.isPortrait) {
        self.topLayoutBarView.timeLabel.hidden = YES;
        [self.topLayoutBarView updateTopLayout:1];
        CGFloat height = KStatusBarHeight + KLayoutBarHeight;
        [self.topLayoutBarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        if (!isAppear) {
            self->topLayouYConstraint.mas_equalTo(-height);
        }
        [self updateOverlayMessageViewFrame];
        [self updatePortraitMessageView];
        if (!self.isMeetingOperator) {
            if ([self.meetingStatusView isDescendantOfView:parentView]) {
                if (liveStatusModel.isLive || liveStatusModel.isRecording) {
                    [self.meetingStatusView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(10);
                        make.top.mas_equalTo(height + 10);
                    }];
                }
            }
        }else{
            if ([self.liveManagerView isDescendantOfView:parentView]) {
                if (liveStatusModel.isLive || liveStatusModel.isRecording) {
                    [self.liveManagerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(10);
                        make.top.mas_equalTo(height + 10);
                    }];
                }
            }
        }
    }else {
        self.topLayoutBarView.timeLabel.hidden = NO;
        [self.topLayoutBarView updateTopLayout:0];
        [self.topLayoutBarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(KLayoutBarHeight);
        }];
        [self updateOverlayMessageViewFrame];
        [self updatePortraitMessageView];
        if (!self.isMeetingOperator) {
            if ([self.meetingStatusView isDescendantOfView:parentView]) {
                if (liveStatusModel.isLive || liveStatusModel.isRecording) {
                    [self.meetingStatusView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(isiPhoneX ? (KStatusBarHeight + 50) : 20);
                        make.top.mas_equalTo(KLayoutBarHeight + 10);
                    }];
                }
            }
        }else{
            if ([self.liveManagerView isDescendantOfView:parentView]) {
                if ((liveStatusModel.isLive || liveStatusModel.isRecording)) {
                    [self.liveManagerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(isiPhoneX ? (KStatusBarHeight + 50) : 20);
                        make.top.mas_equalTo(KLayoutBarHeight + 10);
                    }];
                }
            }
        }
    }
}

- (void)onPeopleVideoPinList:(NSArray *)pinList {
    [self.pinList removeAllObjects];
    if (pinList.count > 0) {
        [self.pinList addObjectsFromArray:pinList];
    }else{
        if (self->isPinSelf) {
            self->isPinSelf = NO;
            [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_UNPIN_ME", nil)];
        }
    }
    [_rosterListViewController updatePinList:self.pinList];
    
    if ([self.pinList containsObject:self->currentUserUUID]) {
        self->isPinSelf = YES;
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_PIN_ME", nil)];
    }
}

- (void)onParticipantsList:(NSMutableArray<NSDictionary *>  *)rosterList {
    
    [self.participantList removeAllObjects];
    for(NSDictionary *str in rosterList) {
        ParticipantListModel *participantModel = [ParticipantListModel yy_modelWithDictionary:str];
        [self.participantList addObject:participantModel];
    }
    
    ParticipantListModel *ownModel = [self getParticipantMeMode];
    if(self.participantList.count == 0) {
        [self.participantList addObject:ownModel];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"UUID == %@",ownModel.UUID];
        NSArray <ParticipantListModel *>*filterArray = [self.participantList filteredArrayUsingPredicate:predicate];
        if (filterArray.count > 0) {
            NSArray <ParticipantListModel *>* sortedList = [self sortedParticipantList];
            [self.participantList removeAllObjects];
            [self.participantList addObjectsFromArray:sortedList];
            ParticipantListModel *unknownParticipantModel = self.participantList.firstObject;
            NSString *userName = unknownParticipantModel.name;
            if (![userName isEqualToString:self.userName]) {
                self->callParam.clientName = userName;
                [MBProgressHUD showMessage:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"meeting_change_name_success", nil),userName]];
            }
            self.userName = userName;
            unknownParticipantModel.me = YES;
            unknownParticipantModel.name = [userName stringByAppendingString:NSLocalizedString(@"participants_me", nil)];
            [self.participantList replaceObjectAtIndex:0 withObject:unknownParticipantModel];
        } else {
            [self.participantList insertObject:ownModel atIndex:0];
        }
    }
    
    ParticipantListModel *myModel = [self getParticipantMeMode];
    [self.participantList enumerateObjectsUsingBlock:^(ParticipantListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.UUID isEqualToString:myModel.UUID]) {
            [self.participantList replaceObjectAtIndex:idx withObject:myModel];
            *stop = YES;
        }
    }];
    
    [_rosterListViewController updateRosterList:self.participantList];
}

#pragma mark --Notification

- (void)controlBarHidden:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger disappearOrNotKey = [[userInfo valueForKey:FMeetingUIDisappearOrNotKey] integerValue];
    switch (disappearOrNotKey) {
        case FMeetingUIDisappear:
        {
            isAppear = NO;
            [self updateToolBarViewConstraintWithZero:NO];
            [UIView animateWithDuration:0.25 animations:^{
                [self.topLayoutBarView.superview layoutIfNeeded];
                if (self.messageView && [self.messageOverLayModel.verticalPosition intValue] == 0) {
                    CGRect topLayoutFrame = CGRectMake(0 , CGRectGetMaxY(self.topLayoutBarView.frame), LAND_SCAPE_WIDTH, 35);
                    self.messageView.frame = topLayoutFrame;
                }
                
                if (self.messageView && [self.messageOverLayModel.verticalPosition intValue] == 100) {
                    CGRect topLayoutFrame = CGRectMake(0,CGRectGetMinY(self.toolBarView.frame) - 35 , LAND_SCAPE_WIDTH, 35);
                    self.messageView.frame = topLayoutFrame;
                }
                if (self->_settingMoreView) {
                    [self->_settingMoreView removeFromSuperview];
                    self->_settingMoreView = nil;
                }
            }];
            
        }
            break;
        case FMeetingUIAppear:
        {
            isAppear = YES;
            [self updateToolBarViewConstraintWithZero:YES];
            [UIView animateWithDuration:0.25 animations:^{
                [self.topLayoutBarView.superview layoutIfNeeded];
                if (self.messageView && [self.messageOverLayModel.verticalPosition intValue] == 0) {
                    CGRect topLayoutFrame = CGRectMake(0 , CGRectGetMaxY(self.topLayoutBarView.frame), LAND_SCAPE_WIDTH, 35);
                    self.messageView.frame = topLayoutFrame;
                }
                
                if (self.messageView && [self.messageOverLayModel.verticalPosition intValue] == 100) {
                    CGRect topLayoutFrame = CGRectMake(0,CGRectGetMinY(self.toolBarView.frame) - 35 , LAND_SCAPE_WIDTH, 35);
                    self.messageView.frame = topLayoutFrame;
                }
            }];
        }
            break;
    }
}

- (void)updateToolBarViewConstraintWithZero:(BOOL)isZero {
    CGFloat height = (self.isPortrait ? KStatusBarHeight : 0) + KLayoutBarHeight;
    if (self->topLayouYConstraint) {
        self->topLayouYConstraint.mas_equalTo(isZero ? 0 : -height);
    }
    if (self->toolBarBottomConstraint) {
        self->toolBarBottomConstraint.mas_equalTo(isZero ? 0 : kToolBarHeight);
    }
}

- (ParticipantListModel *)getParticipantMeMode {
    
    NSString *me = NSLocalizedString(@"participants_me", nil);
    NSString *strMe;
    strMe =[self.userName stringByAppendingString:me];
    
    ParticipantListModel *model = [[ParticipantListModel alloc] init];
    model.name = strMe;
    model.me = YES;
    model.muteAudio = self.toolBarView.btnMuteMicrophone.selected;
    model.muteVideo = self.toolBarView.btnTurnOffCamera.selected;
    model.UUID = [[FrtcCall frtcSharedCallClient] frtcGetClientUUID];
    
    return model;
}

- (NSArray <ParticipantListModel *> *)sortedParticipantList{
    NSString *uuid = self->currentUserUUID;
    NSArray *resultList = [self.participantList sortedArrayUsingComparator:^NSComparisonResult(ParticipantListModel *obj1,
                                                                                               ParticipantListModel *obj2) {
        if ([uuid isEqualToString:obj2.UUID]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return resultList;
}

- (void)updateRosterList {
    ParticipantListModel *model = [self getParticipantMeMode];
    if (self.participantList.count > 0) {
        [self.participantList replaceObjectAtIndex:0 withObject:model];
    }
    [_rosterListViewController updateRosterList:self.participantList];
}

- (void)removeOverLayMessageView {
    
    UIView *parentView = [self presentedViewController].view;
    
    if([self.messageView isDescendantOfView:parentView]) {
        [self.messageView updateNewAnimation];
        [self.messageView removeFromSuperview];
    }
}

- (void)audioSessionRouteChangeObserver:(NSNotification*)notification {
    NSDictionary *routeChangeUserInfo = notification.userInfo;
    NSInteger audioSessionRouteChangeValue = [[routeChangeUserInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (audioSessionRouteChangeValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            self.topLayoutBarView.btnMuteSpeakder.selected = YES;
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            self.topLayoutBarView.btnMuteSpeakder.selected = NO;
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            break;
    }
}

- (void)applicationWillEnterForeground {
    self.topLayoutBarView.btnMuteSpeakder.selected = ![FrtcAudioVideoAuthManager isSpeakerMode];
    if (!self.toolBarView.btnMuteMicrophone.isSelected) {
        [self toolBarAudioChange];
    }
}

- (void)updateShareContentButtonState:(NSNotification *)notification {
    self.sharing = NO;
}

- (void)removeLiveAndRecordStatusView {
    if (self.liveManagerView) {
        [self.liveManagerView removeFromSuperview];
        self.liveManagerView = nil;
    }
    if (self.meetingStatusView) {
        [self.meetingStatusView removeFromSuperview];
        self.meetingStatusView = nil;
    }
    if (self.liveStatusView) {
        [self.liveStatusView removeFromSuperview];
        self.liveStatusView = nil;
    }
    if (self.recordingStatusView) {
        [self.recordingStatusView removeFromSuperview];
        self.recordingStatusView = nil;
    }
}

- (void)updateUmmuteRequestList:(NSNotification *)notification {
    NSDictionary *userinfo = [notification object];
    if ([userinfo[@"fullList"] boolValue]) {
        [self.requestUnmuteDict removeAllObjects];
    }else{
        [self.requestUnmuteDict removeObjectForKey:userinfo[@"uuid"]];
    }
}

- (void)onNetworkStatusChanged:(NSNotification *)notification {
    if ([FrtcCall frtcSharedCallClient].frtcGetCurrentRemotePeopleVideoMuteStatus) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self presentedViewController] showAlertWithTitle:@""
                                                   message:NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_MESSAGE", nil) buttonTitles:@[NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_CANCLE", nil),NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_OK", nil)]
                                                alerAction:^(NSInteger index) {
            if (index == 1) {
                [self muteCamera:YES];
                self.toolBarView.btnTurnOffCamera.selected = YES;
                [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:YES];
            }
        }];
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        BOOL isSelected = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isSelected) { //mute
            [self.audioVideoManager f_stopAudioTimer];
            if (self->_rosterListViewController) {
                [self->_rosterListViewController updateMicrophoneImage:100];
            }
        }else{ //unmute
            [self toolBarAudioChange];
        }
    }
}

- (void)toolBarAudioChange {
    @WeakObj(self)
    [self.audioVideoManager f_audioSizeChange:^(int audioLevel) {
        @StrongObj(self)
        [self.toolBarView updateMicrophoneImageForValue:audioLevel];
        if (self->_rosterListViewController) {
            [self->_rosterListViewController updateMicrophoneImage:audioLevel];
        }
    }];
}

#pragma mark -- TopLayoutBarViewProtocol

- (void)changeCameraPosition {
    [[FrtcCall frtcSharedCallClient] frtcSwitchCameraPosition];
}

- (void)changeSpeakerStatus:(BOOL)isSpeaker {
    [[FrtcCall frtcSharedCallClient] frtcChangeSpeakerStatus:isSpeaker];
}

- (void)dropCall {
    dispatch_async(dispatch_get_main_queue(), ^{
        EndMeetingController *vcEndDlg = [EndMeetingController new];
        vcEndDlg.delegate = self;
        vcEndDlg.meetingOperator = self.meetingOperator;
        vcEndDlg.modalPresentationStyle = UIModalPresentationCustom;
        vcEndDlg.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [[self presentedViewController] presentViewController:vcEndDlg animated:YES completion:nil];
    });
}

- (void)showDropdownView {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *meetingPassword = [[FrtcUserDefault sharedUserDefault] objectForKey:MEETING_PASSWORD];
        if (!kStringIsEmpty(meetingPassword)) {
            self.meetingInfo.password = YES;
            self.meetingInfo.meetingPassword = meetingPassword;
        }
        @WeakObj(self)
        FrtcMeetingInfoViewController *infoVC = [[FrtcMeetingInfoViewController alloc]init];
        infoVC.modalPresentationStyle = UIModalPresentationCustom;
        infoVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [[self presentedViewController] presentViewController:infoVC animated:YES completion:^{
            @StrongObj(self)
            infoVC.meetingInfo = self.meetingInfo;
        }];
    });
}

#pragma mark -- RostListViewControllerDelegate

- (void)rostListMuteMicroPhone:(BOOL)mute {
    [self muteMicroPhone:!mute];
}

- (void)rostShareInvitationInfo {
    [FrtcInvitationInfoManage shareInvitationInfo:self.meetingInfo];
}

- (void)updateParticipantInfo:(ParticipantListModel *)info {
    self->callParam.clientName = info.name;
    self.userName = info.name;
}

- (void)hiddenRedDotView {
    self.toolBarView.redDotView.hidden = YES;
}

#pragma mark -- EndMeetingControllerDelegate
- (void)endMeetingClicked:(BOOL)stop {
    [kFrtcCallShared f_InfoLog:@"[stop] end meeting"];
    [[FrtcMediaStaticsInstance share] stopGetMediaStatics];
    self.meetingInfo.meetingTime   = self.topLayoutBarView.meetingTimeLable.text;
    NSString *meetingPassword = [[FrtcUserDefault sharedUserDefault] objectForKey:MEETING_PASSWORD];
    self.joinMeetingSuccess = NO;
    if (!kStringIsEmpty(meetingPassword)) {
        self.meetingInfo.password = YES;
        self.meetingInfo.meetingPassword = meetingPassword;
        [[FrtcUserDefault sharedUserDefault] setObject:@"" forKey:MEETING_PASSWORD];
    }
    if (isLoginSuccess && self.isServerUrlSame) {
        [FrtcHomeMeetingListPresenter saveMeeting:self.meetingInfo];
    }
    
    if (stop) {
        [FrtcLocalInforDefault saveYourSelf:YES];
        [[FrtcManagement sharedManagement] stopMeeting:[FrtcUserModel fetchUserInfo].user_token
                                         meetingNumber:self.meetingInfo.meetingNumber
                                       participantList:@[]
                                 stopCompletionHandler:^{
        } stopFailure:^(NSError * _Nonnull error) {
        }];
    }
    [self cleanUp];
    [[FrtcCall frtcSharedCallClient] frtcCloseMeetingView];
}

- (void)cleanUp {
    [kFrtcCallShared f_InfoLog:@"[stop] start meeting cleanUp"];
    [self shareContent:NO];
    self.reconnect = NO;
    FrtcManager.inMeeting = NO;
    FrtcManager.guestUser = NO;
    [self.participantList removeAllObjects];
    [self.lecturesList removeAllObjects];
    [self.pinList removeAllObjects];
    [self removeLiveAndRecordStatusView];
    [FrtcAlertView disMissView];
    [MuteView disMissView];
    [[FrtcCall frtcSharedCallClient] frtcHangupCall];
    self.serverMute = NO;
    self.allowUserUnMute = NO;
    self.meetingOperator = NO;
    self.joinMeetingSuccess = NO;
    self.showUnMuteView = NO;
    self.sharing = NO;
    self.serverUrlSame = NO;
    self.reconnect = NO;
    self.portrait = NO;
    self.unmuteRequesting = NO;
    self.showRequestUnMuteView = NO;
    [self stopAudioSession];
    NSString *audioPlaying = [NSString stringWithFormat:@"[stop]  Is other audio playing: %d", [AVAudioSession sharedInstance].isOtherAudioPlaying];
    [kFrtcCallShared f_InfoLog:audioPlaying];
    [kFrtcCallShared f_InfoLog:@"[stop] end meeting cleanUp"];
}

- (void)stopAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    BOOL success = [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (!success) {
        ISMLog(@"Error deactivating audio session: %@", error);
    }
}

#pragma mark -- TopOverLayMessageViewDelegate
- (void)repeateUpdateView {
    [self.messageView removeFromSuperview];
    self.messageOverLayModel.enabledMessageOverlay = NO;
}

#pragma mark -- TalkingToolBarViewDelegate

- (void)participent {
    
    if(self.participantList.count == 0) {
        [self.participantList removeAllObjects];
        [self.participantList addObject:[self getParticipantMeMode]];
    }
    
    ((ParticipantListModel *)self.participantList[0]).muteAudio = self.toolBarView.btnMuteMicrophone.selected;
    ((ParticipantListModel *)self.participantList[0]).muteVideo = self.toolBarView.btnTurnOffCamera.selected;
    _rosterListViewController = [[RostListViewController alloc] initWithRosterList:self.participantList lecturesList:self.lecturesList pinList:self.pinList];
    _rosterListViewController.meetingOperator = self.isMeetingOperator;
    _rosterListViewController.delegate = self;
    _rosterListViewController.meetingNumber = self.meetingInfo.meetingNumber;
    _rosterListViewController.requestUnmuteList = self.requestUnmuteList;
    _rosterListViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    //_rosterListViewController.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
    [[self presentedViewController] presentViewController:_rosterListViewController animated:YES completion:nil];
}

- (void)hiddenLocalView:(BOOL)hidden {
    [[FrtcCall frtcSharedCallClient] frtcHiddenLocalPreView:hidden];
}

- (void)muteCamera:(BOOL)mute {
    self.topLayoutBarView.btnChangeCamera.enabled = !mute;
    
    [[FrtcCall frtcSharedCallClient] frtcMuteLocalCamera:mute];
    if(self.participantsNum > 1) {
        [self hiddenLocalView:mute];
    }
}

- (void)muteMicroPhone:(BOOL)mute {
    if (!self.allowUserUnMute && self.toolBarView.btnMuteMicrophone.isSelected == YES && !self.isMeetingOperator) {
        @WeakObj(self)
        FrtcCAlertView *alertView = [[FrtcCAlertView alloc]init];
        if (self.isUnmuteRequesting) {
            [alertView showAlertWithTitle:NSLocalizedString(@"MEETING_ASK_FOR_UNMUTE_OK_TITLE", nil)
                             withSubtitle:NSLocalizedString(@"MEETING_ASK_FOR_UNMUTE_OK_MESSAGE", nil)
                          withCustomImage:nil
                      withDoneButtonTitle:NSLocalizedString(@"string_ok", nil)
                               andButtons:nil];
        }else {
            [alertView showAlertWithTitle:NSLocalizedString(@"MEETING_ASK_FOR_UNMUTE_ALERT_TITLE", nil)
                             withSubtitle:NSLocalizedString(@"MEETING_ASK_FOR_UNMUTE_ALERT_MESSAGE", nil)
                          withCustomImage:nil
                      withDoneButtonTitle:NSLocalizedString(@"MEETING_ASK_FOR_UNMUTE_ALERT_OK", nil)
                               andButtons:nil];
            [alertView addButton:NSLocalizedString(@"dialog_cancel", nil) withActionBlock:^{ }];
            [alertView doneActionBlock:^{
                @StrongObj(self)
                self.unmuteRequesting = YES;
                RosterPresenter *presenter = [[RosterPresenter alloc]init];
                [presenter requestUnmuteWithMeetingNumber:self.meetingInfo.meetingNumber];
                [FrtcTimer timerTask:^{
                    self.unmuteRequesting = NO;
                } start:60 interval:60 repeats:NO async:NO];
            }];
        }
    }else{
        [self frtcMuteMicroPhone:mute];
    }
}

- (void)frtcMuteMicroPhone:(BOOL)mute {
    [[FrtcCall frtcSharedCallClient] frtcMuteLocalMicPhone:mute];
    self.toolBarView.btnMuteMicrophone.selected = mute;
}

- (void)shareContent:(BOOL)isShare {
    if (isShare) {
        NSInteger upRate = [FrtcMediaStaticsInstance share].upRate;
        if (upRate < 512) {
            [MBProgressHUD showMessage:NSLocalizedString(@"CONTENT_UPRATE_ERROR_MESSAGE", nil)];
            return;
        }
        
        if (![FrtcHelpers isNetwork]) {
            [MBProgressHUD showMessage:NSLocalizedString(@"meeting_shareed_nerworkstate", nil)];
            return;
        }
        
    }
    [[FrtcContentShareGadget sharedInstance] startRecordScreenSharing:isShare];
}

- (void)clickMoreBtn:(UIButton *)moreBtn {
    @WeakObj(self)
    if (_settingMoreView) {
        [self->_settingMoreView removeFromSuperview];
        self->_settingMoreView = nil;
    }else {
        _settingMoreView = [[FrtcSettingMoreView alloc]initWithFrame:CGRectZero meetingOperator:self.meetingInfo liveStatusModel:self->liveStatusModel serverUrlSame:self.isServerUrlSame];
        _settingMoreView.moreViewBlock = ^(FMoreViewType type, NSInteger index) {
            @StrongObj(self)
            switch (type) {
                case FMoreViewTypeShare:
                    [FrtcShareMeetingMaskView showShareView:self.meetingInfo
                                          didSelectCallBack:^(NSInteger index) {}];
                    break;
                case FMoreViewTypeOverlay:
                {
                    [FrtcSendOverlayMessageView showSendOverlayMessageView:self.meetingInfo.meetingNumber
                                                       overlayMessageBlock:^{ }];
                }
                    break;
                case FMoreViewTypeStopOverlay:
                {
                    RosterPresenter *rosterPresenter = [[RosterPresenter alloc] init];
                    [rosterPresenter stopTextOverlayWithMeetingNumber:self.meetingInfo.meetingNumber];
                }
                    break;
                case FMoreViewTypeRecord:
                {
                    [self startRecord];
                }
                    break;
                case FMoreViewTypeLive:
                {
                    [self startLive];
                }
                    break;
                case FMoreViewTypeReceivingVideo:
                {
                    [self receivingVideo:index];
                }
                    break;
                case FMoreViewTypeFloating:
                {
                    ISMLog(@"self.isSharing = %d",self.isSharing);
                    [[FrtcCall frtcSharedCallClient] frtcFloatingMeetingWindow:self.isSharing];
                }
                    break;
                default:
                    break;
            }
        };
        _settingMoreView.disMissMoreViewBlock = ^{
            @StrongObj(self)
            [self->_settingMoreView removeFromSuperview];
            self->_settingMoreView = nil;
        };
        [[self presentedViewController].view addSubview:_settingMoreView];
        [_settingMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-KLeftSpacing12);
            make.bottom.mas_equalTo(- kToolBarHeight - 3);
        }];
    }
}

- (void)startRecord {
    
    RosterPresenter *recordPresenter = [[RosterPresenter alloc] init];
    if (self->liveStatusModel.isRecording) {
        [recordPresenter stopRecordingWithMeetingNumber:self.meetingInfo.meetingNumber];
    }else{
        @WeakObj(self)
        [[self presentedViewController] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_START_RECORDING", @"Start Cloud Recording？")
                                                   message:NSLocalizedString(@"FM_VIDEO_START_RECORDING_MESSAGE", @"It will record meeting audio, video and shared screen, and inform all members.")
                                              buttonTitles:@[NSLocalizedString(@"call_cancel", nil),NSLocalizedString(@"FM_VIDEO_START_RECORDING_BUTTON_TITLE", @"Start")]
                                                alerAction:^(NSInteger index) {
            @StrongObj(self)
            if (index == 1) {
                [recordPresenter startRecordingWithMeetingNumber:self.meetingInfo.meetingNumber];
            }
        }];
    }
}

- (void)startLive {
    
    RosterPresenter *recordPresenter = [[RosterPresenter alloc] init];
    if (self->liveStatusModel.isLive) {
        [recordPresenter stopLiveWithMeetingNumber:self.meetingInfo.meetingNumber];
    }else {
        @WeakObj(self)
        [[self presentedViewController] showPasswordAlertViewWithAlerAction:^(NSInteger index, BOOL isSelect) {
            @StrongObj(self)
            if (index == 1) {
                NSString *password = @"";
                if (isSelect) {
                    password = [self getVerificationCode];
                }
                RosterPresenter *recordPresenter = [[RosterPresenter alloc] init];
                [recordPresenter startLiveWithMeetingNumber:self.meetingInfo.meetingNumber livePassword:password];
            }
        }];
    }
}

- (void)receivingVideo:(NSInteger)index {
    [[FrtcCall frtcSharedCallClient] frtcMuteRemotePeopleVideo:index == 1 ? YES : NO];
    if (index) {
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_STOP", nil)];
    }else{
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_REMOTEPEOPLEVIDEO_ALERT_RECEIVING", nil)];
    }
}

- (NSString *)getVerificationCode {
    NSArray *strArr = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil] ;
    NSMutableString *getStr = [[NSMutableString alloc]initWithCapacity:5];
    for(int i = 0; i < 6; i++) {
        int index = arc4random() % ([strArr count]);
        [getStr appendString:[strArr objectAtIndex:index]];
        
    }
    return getStr;
}

#pragma mark -- Config Meeting View
- (void)configTalkBarView {
    self.toolBarView = [[TalkingToolBarView alloc]initWithFrame:CGRectZero
                                                  withAudioCall:self->callParam.audioCall];
    
    [self.toolBarView.btnMuteMicrophone addObserver:self
                                         forKeyPath:@"selected"
                                            options:NSKeyValueObservingOptionNew
                                            context:NULL];
    
    self.toolBarView.delegate = self;
    self.toolBarView.layer.backgroundColor = [UIColor colorWithRed:33/255.0 green:34/255.0 blue:35/255.0 alpha:0.9].CGColor;
    self.toolBarView.btnTurnOffCamera.selected = self->callParam.muteCamera;
    self.toolBarView.btnMuteMicrophone.selected = self->callParam.muteMicrophone;
    
    if(!self.toolBarView.btnMuteMicrophone.isSelected) {
        self.toolBarView.btnMuteMicrophone.selected = self.serverMute;
        self->callParam.muteMicrophone = self.serverMute;
        [self frtcMuteMicroPhone:self.serverMute];
    }else {
        [self frtcMuteMicroPhone:TRUE];
    }
    
    self.toolBarView.btnTurnOffCamera.enabled =
    self.toolBarView.btnShareContent.enabled = !self->callParam.audioCall;
    self.toolBarView.btnFloatingFrame.enabled = self.participantsNum > 1;
    if (self->callParam.audioCall) {
        self.toolBarView.btnFloatingFrame.enabled = NO;
    }
    
    self.toolBarView.badgeView.text = [NSString stringWithFormat:@"%ld",self.participantsNum];
    
    UIView *parentView = [self presentedViewController].view;
    if (parentView) {
        [parentView addSubview:self.toolBarView];
        [self.toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(kToolBarHeight);
            toolBarBottomConstraint = make.bottom.mas_equalTo(0);
        }];
    }
}

- (void)configTopLayoutView {
    self.topLayoutBarView = [[TopLayoutBarView alloc] initWithFrame:CGRectZero
                                                        withMuteMic:self->callParam.muteMicrophone
                                                     withMuteCamera:self->callParam.muteCamera
                                                      withAudioCall:self->callParam.audioCall];
    self.topLayoutBarView.delegate = self;
    self.topLayoutBarView.layer.backgroundColor = [UIColor colorWithRed:33/255.0 green:34/255.0 blue:35/255.0 alpha:0.9].CGColor;
    
    self.topLayoutBarView.btnChangeCamera.enabled  = !self->callParam.muteCamera;
    self.topLayoutBarView.meetingNameLable.text    = self.meetingInfo.meetingName;
    self.topLayoutBarView.btnMuteSpeakder.selected = ![FrtcAudioVideoAuthManager isSpeakerMode];
    if (self.isPortrait) {
        self.topLayoutBarView.timeLabel.hidden = YES;
    }
    [self.topLayoutBarView updateTopLayout:self.isPortrait];
    
    UIView *parentView = [self presentedViewController].view;
    if (parentView) {
        [parentView addSubview:self.topLayoutBarView];
        CGFloat height = (self.isPortrait ? KStatusBarHeight : 0) + KLayoutBarHeight;
        [self.topLayoutBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(height);
            topLayouYConstraint = make.top.mas_equalTo(0);
        }];
    }
}

- (void)configTopOverLayMessageView {
    
    if(self.overlayMessage) {
        UIView *parentView = [self presentedViewController].view;
        if (parentView) {
            if([self.messageOverLayModel.type isEqualToString:@"global"]){
                self.messageView = [[TopOverLayMessageView alloc] init];
                self.messageView.delegate = self;
                self.messageView.backgroundColor = [UIColor colorWithRed:(2/255.0f) green:(111/255.0f) blue:(254/255.0f) alpha:0.25];
                [parentView addSubview:self.messageView];
                [self updateOverlayMessageView];
            }
        }
    }
}

#pragma mark -- OverlayMessageView Function

- (void)updatePortraitMessageView {
    UIView *parentView = [self presentedViewController].view;
    BOOL isStatic = [self.messageOverLayModel.displaySpeed isEqualToString:@"static"];
    if(isStatic && [self.messageView isDescendantOfView:parentView]) {
        NSString *str = self.messageOverLayModel.content;
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [self.messageView registerBecomeActiveNotification];
        self.messageView.messageLabel.text = str;
        self.messageView.repeateTime = [self.messageOverLayModel.displayRepetition intValue];
        CGFloat labelLength = self.messageView.messageLabel.frame.size.width;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
        CGSize textSize = [self.messageView.messageLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 24) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        labelLength = textSize.width;
        [self.messageView staticDisplayMessageView:textSize];
    }
}

- (void)updateOverlayMessageViewFrame {
    
    UIView *parentView = [self presentedViewController].view;
    if(![self.messageView isDescendantOfView:parentView]) {
        return;
    }
    
    NSInteger position = [self.messageOverLayModel.verticalPosition intValue];
    
    CGFloat width    = self.isPortrait ? LAND_SCAPE_HEIGHT : LAND_SCAPE_WIDTH;
    CGFloat height   = self.isPortrait ? LAND_SCAPE_WIDTH  : LAND_SCAPE_HEIGHT;
    CGFloat topSpace = self.isPortrait ? KLayoutBarHeight + KStatusBarHeight : KLayoutBarHeight;
    
    if (position == 0) {
        self.messageView.frame = CGRectMake(0, topSpace, width, 35);
    }else if (position == 50) {
        self.messageView.frame = CGRectMake(0, height/2-35, width, 35);
    }else if (position == 100) {
        self.messageView.frame = CGRectMake(0, height - kToolBarHeight - 35, width, 35);
    }
}

- (void)updateOverlayMessageView {
    [self updateOverlayMessageViewFrame];
    NSString *str = self.messageOverLayModel.content;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    [self.messageView registerBecomeActiveNotification];
    self.messageView.messageLabel.text = str;
    self.messageView.repeateTime = [self.messageOverLayModel.displayRepetition intValue];
    
    CGFloat labelLength = self.messageView.messageLabel.frame.size.width;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    CGSize textSize = [self.messageView.messageLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 24) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    
    labelLength = textSize.width;
    
    if([self.messageOverLayModel.displaySpeed isEqualToString:@"static"]) {
        [self.messageView staticDisplayMessageView:textSize];
        
        return;
    }
    
    [self.messageView configSize:textSize];
    
    NSTimeInterval duration = labelLength / LAND_SCAPE_WIDTH;
    if(duration < 1.0) {
        duration = 1.0;
    }
    
    NSString *displaySpeed = self.messageOverLayModel.displaySpeed;
    if ([displaySpeed isEqualToString:@"fast"]) {
        duration = duration / 2;
    }
    [self overLaymessageDisplay:duration];
}

- (void)overLaymessageDisplay:(NSTimeInterval)duration {
    if(self.overlayMessage) {
        [self.messageView updateView:20 * duration];
    }
}

- (UIViewController *)presentedViewController {
    return self.parentViewController;
}

#pragma mark - lazy

- (FHomeMeetingListModel *)meetingInfo {
    if (!_meetingInfo) {
        _meetingInfo = [FHomeMeetingListModel new];
    }
    return _meetingInfo;
}

- (FrtcCallNetworkErrorView *)networkError {
    if (!_networkError) {
        _networkError = [[FrtcCallNetworkErrorView alloc]init];
    }
    return _networkError;
}

- (NSMutableArray <NSString *> *)lecturesList {
    if (!_lecturesList) {
        _lecturesList = [[NSMutableArray alloc]initWithCapacity:3];
    }
    return _lecturesList;
}

- (NSMutableArray <NSString *> *)pinList {
    if (!_pinList) {
        _pinList = [[NSMutableArray alloc]initWithCapacity:4];
    }
    return _pinList;
}

- (NSMutableArray <ParticipantListModel *> *)participantList {
    if (!_participantList) {
        _participantList = [[NSMutableArray alloc]init];
    }
    return _participantList;
}

- (NSMutableArray <FrtcRequestUnmuteModel *> *)requestUnmuteList {
    if (!_requestUnmuteList) {
        _requestUnmuteList = [[NSMutableArray alloc]init];
    }
    return _requestUnmuteList;
}

- (NSMutableDictionary *)requestUnmuteDict {
    if (!_requestUnmuteDict) {
        _requestUnmuteDict = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _requestUnmuteDict;
}

- (FrtcLiveTipsMaskView *)liveStatusView {
    if (!_liveStatusView) {
        _liveStatusView = [[FrtcLiveTipsMaskView alloc]init];
        _liveStatusView.layer.cornerRadius  = 4;
        _liveStatusView.layer.masksToBounds = YES;
        _liveStatusView.hidden = YES;
    }
    return _liveStatusView;
}

- (FrtcLiveTipsMaskView *)recordingStatusView {
    if (!_recordingStatusView) {
        _recordingStatusView = [[FrtcLiveTipsMaskView alloc]init];
        _recordingStatusView.layer.cornerRadius  = 4;
        _recordingStatusView.layer.masksToBounds = YES;
        _recordingStatusView.hidden = YES;
    }
    return _recordingStatusView;
}

- (UIStackView *)meetingStatusView {
    if (!_meetingStatusView) {
        _meetingStatusView = [[UIStackView alloc]init];
        _meetingStatusView.spacing = 10;
        _meetingStatusView.axis = UILayoutConstraintAxisVertical;
    }
    return _meetingStatusView;
}

- (FrtcLiveManagerView *)liveManagerView {
    if (!_liveManagerView) {
        _liveManagerView = [[FrtcLiveManagerView alloc]init];
        _liveManagerView.meetingNumber = self.meetingInfo.meetingNumber;
        @WeakObj(self)
        _liveManagerView.sharLiveUrlBlock = ^{
            @StrongObj(self)
            [FrtcShareLiveUrlMaskView showShareLiveView:self.meetingInfo
                                         liveStatusInfo:self->liveStatusModel
                                      didSelectCallBack:^{ }];
        };
    }
    return _liveManagerView;
}

- (FrtcRecordingMaskView *)recordingMaskView {
    if (!_recordingMaskView) {
        _recordingMaskView = [[FrtcRecordingMaskView alloc]init];
        _recordingMaskView.backgroundColor = UIColor.whiteColor;
        _recordingMaskView.layer.cornerRadius = 8;
        _recordingMaskView.layer.masksToBounds = YES;
        @WeakObj(self)
        _recordingMaskView.dismissViewBlock = ^{
            @StrongObj(self)
            [UIView animateWithDuration:0.25 animations:^{
                self.recordingMaskView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.recordingMaskView removeFromSuperview];
                self.recordingMaskView = nil;
            }];
        };
    }
    return _recordingMaskView;
}

- (FrtcRequestUnmuteListMaskView *)requestUnmuteListView {
    if (!_requestUnmuteListView) {
        _requestUnmuteListView = [[FrtcRequestUnmuteListMaskView alloc]init];
        @WeakObj(self)
        _requestUnmuteListView.selectedBlock = ^{
            @StrongObj(self)
            self.toolBarView.redDotView.hidden = YES;
            FrtcRequestUnmuteListViewController *unmuteListView = [[FrtcRequestUnmuteListViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:unmuteListView];
            unmuteListView.requestUnmuteList = self.requestUnmuteList;
            unmuteListView.meetingNumber     = self.meetingInfo.meetingNumber;
            [[self presentedViewController] presentViewController:nav animated:YES completion:^{}];
        };
    }
    return _requestUnmuteListView;
}

- (FrtcAudioVideoAuthManager *)audioVideoManager {
    if (!_audioVideoManager) {
        _audioVideoManager = [[FrtcAudioVideoAuthManager alloc]init];
    }
    return _audioVideoManager;
}

@end

