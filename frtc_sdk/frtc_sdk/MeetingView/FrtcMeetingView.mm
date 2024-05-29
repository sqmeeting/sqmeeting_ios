#import "FrtcMeetingView.h"
#import "FrtcUIMacro.h"
#import "Masonry.h"
#import "MeetingLayoutContext.h"
#import "NSTimer+Enhancement.h"
#import "MeetingUserInformation.h"
#import "ObjectInterface.h"

@interface FrtcMeetingView () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView                    *remotePeopleVideoBackgroundView;
@property (nonatomic, strong) UIView                    *remotePeopleVideoBottomView;
@property (nonatomic, strong) UIView                    *contentVideoBottomView;

@property (nonatomic, strong) UISwipeGestureRecognizer  *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer  *rightSwipeGestureRecognizer;

@property (nonatomic, strong) NSMutableArray             *remotePeopleVideoViewList;
@property (strong, nonatomic) NSTimer                    *hiddenTimer;
@property (strong, nonatomic) NSTimer                    *hiddenNameViewTimer;

@property (nonatomic, assign, getter = isShowToorBarView)   BOOL showToorBarView;
@property (nonatomic, assign, getter = isContent)           BOOL content;

@end

double contentViewWidth, contentViewHeight, contentMarginLeft, contentMarginTop;
double peopleViewWidth, peopleMarginLeft;

@implementation FrtcMeetingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (ISIPAD) { //iPad 默认横屏
            [self getLandscapeFrame];
        }else{ //iPhone 默认竖屏
            [self getPortraitFrame];
        }
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    ISMLog(@"%s",__func__);
    [self cancelTimer];
}

#pragma mark - setup view

- (void)setupViews {
    
    [self addSubview:self.remotePeopleVideoBackgroundView];
    [self.remotePeopleVideoBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.remotePeopleVideoBackgroundView addSubview:self.remotePeopleVideoBottomView];
    [self.remotePeopleVideoBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(peopleMarginLeft);
        make.top.mas_equalTo(contentMarginTop);
        make.size.mas_equalTo(CGSizeMake(peopleViewWidth, contentViewHeight));
    }];
    
    UIImageView *backGroundView = [[UIImageView alloc] init];
    backGroundView.contentMode = UIViewContentModeScaleAspectFill;
    [backGroundView setImage:[UIImage imageBundlePath:@"frtc_meeting_video_off"]];
    [self.remotePeopleVideoBottomView addSubview:backGroundView];
    [backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.remotePeopleVideoBottomView);
    }];
    
    [self addSubview:self.contentVideoBottomView];
    [self.contentVideoBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.remotePeopleVideoBackgroundView.mas_left);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(KScreenWidth);
    }];
    
    [self.contentVideoBottomView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentVideoBottomView);
    }];
    
    [self.scrollView addSubview:self.contentVideoView];
    [self.contentVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentMarginLeft);
        make.top.mas_equalTo(contentMarginTop);
        make.size.mas_equalTo(CGSizeMake(contentViewWidth, contentViewHeight));
    }];
    
    [self addSubview:self.localVideoView];
    [self.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.remotePeopleVideoBottomView);
    }];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:PEOPLE_VIDEO_AND_CONTENT_NUMBER];
    for (int i = 0; i < PEOPLE_VIDEO_AND_CONTENT_NUMBER; i++) {
        MetalVideoView *remoteVideoView;
        CGRect rect = CGRectMake(0, 0, peopleViewWidth , contentViewHeight);
        remoteVideoView = [[MetalVideoView alloc] initWithFrame:rect dataMediaID:@"remote"];
        [remoteVideoView setRenderPixelType:RTC::kI420];
        [self.remotePeopleVideoBottomView addSubview:remoteVideoView];
        [remoteVideoView setHidden:YES];
        [array addObject:remoteVideoView];
    }
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.mas_equalTo(-40);
    }];
    
    _remotePeopleVideoViewList = [[NSMutableArray alloc] initWithArray:array];
    
    [self configTapGesture];
    
    [self startHiddenTimer:5];
    self.showToorBarView = YES;
}

- (void)getLandscapeFrame {
    
    double displayRatio = LAND_SCAPE_WIDTH/LAND_SCAPE_HEIGHT;
    double contentRatio = 16.0/9.0;
    
    if(displayRatio > contentRatio){
        peopleViewWidth   = contentViewWidth  = LAND_SCAPE_HEIGHT * 16.0/9.0;
        contentViewHeight = LAND_SCAPE_HEIGHT;
        peopleMarginLeft  = contentMarginLeft = (LAND_SCAPE_WIDTH - contentViewWidth)/2.0;
        contentMarginTop  = 0;
    } else if (displayRatio < contentRatio){
        peopleViewWidth   = contentViewWidth  = LAND_SCAPE_WIDTH;
        contentViewHeight = LAND_SCAPE_WIDTH * 9.0/16.0;
        peopleMarginLeft  = contentMarginLeft = 0;
        contentMarginTop  = (LAND_SCAPE_HEIGHT - contentViewHeight)/2.0;
    } else if (displayRatio == contentRatio){
        peopleViewWidth   = contentViewWidth  = LAND_SCAPE_WIDTH;
        contentViewHeight = LAND_SCAPE_HEIGHT;
        peopleMarginLeft  = contentMarginLeft = 0;
        contentMarginTop  = 0;
    }
}

- (void)getPortraitFrame {
    contentMarginLeft = peopleMarginLeft = 0;
    contentViewWidth  = peopleViewWidth  = LAND_SCAPE_HEIGHT;
    contentViewHeight = LAND_SCAPE_HEIGHT * 16.0/9.0;
    contentMarginTop  = (LAND_SCAPE_WIDTH - contentViewHeight)/2.0;
}

- (void)setLandscapeLayout {
    [self updateVideoLayout];
}

- (void)setPortraitLayout {
    [self updateVideoLayout];
}

- (void)updateVideoLayout {
    [self.remotePeopleVideoBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(peopleMarginLeft);
        make.top.mas_equalTo(contentMarginTop);
        make.size.mas_equalTo(CGSizeMake(peopleViewWidth, contentViewHeight));
    }];
    
    if ([self.contentVideoView isDescendantOfView:self.contentVideoBottomView]) {
        [self.contentVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(peopleMarginLeft);
            make.top.mas_equalTo(contentMarginTop);
            make.size.mas_equalTo(CGSizeMake(peopleViewWidth, contentViewHeight));
        }];
    }
}

- (void)updateBottomViewLayout:(BOOL)isContent {
    
    if (isContent) {
        self.content = YES;
        [self.contentVideoBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        if (![self.contentVideoView isDescendantOfView:self.scrollView]) {
            [self.scrollView addSubview:self.contentVideoView];
            [self.contentVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(contentMarginLeft);
                make.top.mas_equalTo(contentMarginTop);
                make.size.mas_equalTo(CGSizeMake(contentViewWidth, contentViewHeight));
            }];
        }
        
        [self.remotePeopleVideoBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(self);
            make.left.equalTo(self.contentVideoBottomView.mas_right);
        }];
    }else{
        self.content = NO;
        self.pageControl.hidden = YES;
        
        [self.remotePeopleVideoBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
        
        if ([self.contentVideoView isDescendantOfView:self.scrollView]) {
            [self.contentVideoView removeFromSuperview];
            self.contentVideoView = nil;
        }
        
        [self.contentVideoBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.remotePeopleVideoBackgroundView.mas_left);
            make.top.bottom.width.equalTo(self);
        }];
    }
}

- (void)updateLocalVideoViewLayout:(NSArray *)viewArray content:(BOOL)content isPortrait:(BOOL)isPortrait {
    
    if(viewArray.count > 0 || content) {
        self.localVideoView.hidden = self.localViewHidden;
        if (!isPortrait) {
            CGFloat vwidth = 0.22 * (LAND_SCAPE_WIDTH);
            CGFloat vheight = vwidth * 9.0/16.0;
            [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.remotePeopleVideoBottomView.mas_right);
                make.size.mas_equalTo(CGSizeMake(vwidth,vheight));
            }];
        }else{
            CGFloat vwidth = 0.22 * (LAND_SCAPE_HEIGHT);
            CGFloat vheight = vwidth * 16.0/9.0;
            [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.right.equalTo(self.remotePeopleVideoBottomView);
                make.size.mas_equalTo(CGSizeMake(vwidth,vheight));
            }];
        }
    } else {
        self.localVideoView.hidden = NO;
        [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.remotePeopleVideoBottomView);
        }];
    }
}

- (void)updateRemotePeopleVideoBottomViewSubViewsHidden:(NSArray *)viewArray {
    
    for (int i = 0; i < [_remotePeopleVideoViewList count]; i++) {
        BOOL bFind = NO;
        MetalVideoView *view = _remotePeopleVideoViewList[i];
        
        for (int j = 0; j < [viewArray count]; j++) {
            MeetingUserInformation *videoInfo = [viewArray objectAtIndex:j];
            if ([view.mediaID isEqualToString:videoInfo.mediaID]) {
                bFind = YES;
                break;
            }
        }
        
        if (!bFind) {
            [view renderMuteImage:YES];
            [view setHidden:YES];
        } else {
            [view setHidden:NO];
        }
    }
}

extern SDKMeetingLayout sdkMeetingLayoutDescription[MEETING_LAYOUT_NUMBER];

- (void)updateRemotePeopleVideoViewState:(NSArray *)viewArray
                                   model:(MeetingLayoutNumber)modeType
                         rosterListArray:(NSMutableArray *)rosterListArray
                    activeSpeakerMediaID:(NSString *)activeSpeakerMediaID {
    
    for (int i = 0; i < [viewArray count]; i++) {
        
        MeetingUserInformation *videoInfo = [viewArray objectAtIndex:i];
        MetalVideoView* vVC = [self getPeopleVideoViewControllerByViewId:videoInfo.mediaID];
        
        CGFloat vx = sdkMeetingLayoutDescription[modeType].peopleViewDetail[i][0];
        CGFloat vy = sdkMeetingLayoutDescription[modeType].peopleViewDetail[i][1];
        CGFloat vwidth = sdkMeetingLayoutDescription[modeType].peopleViewDetail[i][2];
        CGFloat vheigt = sdkMeetingLayoutDescription[modeType].peopleViewDetail[i][3];
        CGFloat vremoteWidth = CGRectGetWidth(self.remotePeopleVideoBottomView.bounds);
        CGFloat vremoteHeight = CGRectGetHeight(self.remotePeopleVideoBottomView.bounds);
        
        [vVC mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(vremoteWidth * vx).priority(100);
            make.top.mas_equalTo(vremoteHeight * vy);
            make.width.mas_equalTo(vremoteWidth * vwidth);
            make.height.mas_equalTo(vremoteHeight * vheigt);
        }];
        
        [UIView animateWithDuration:0.25 animations:^{
            [vVC.superview layoutIfNeeded];
        }];
        
        vVC.siteNameView.nameStr = videoInfo.display_name;
        vVC.siteNameView.hidden = NO;
        vVC.uuid = videoInfo.uuid;
        
        for(NSDictionary *dic in rosterListArray) {
            if([vVC.uuid isEqualToString:dic[@"UUID"]]) {
                if([dic[@"muteAudio"] isEqualToString:@"true"]) {
                    [vVC updateLayoutSiteNameView:YES];
                } else {
                    [vVC updateLayoutSiteNameView:NO];
                }
            }
        }
        
        [vVC.siteNameView setSiteNameWithUserPinStatus:videoInfo.isPin];
        [vVC.muteNameCardView.siteNameView setSiteNameWithUserPinStatus:videoInfo.isPin];
        vVC.muteNameCardView.nameLabel.text = videoInfo.display_name;
        
        if(videoInfo.resolution_width == -2) {
            [vVC renderMuteImage:YES];
        }
        
        [vVC setHidden:NO];
        
        if([activeSpeakerMediaID isEqualToString:videoInfo.uuid] && viewArray.count > 1) {
            [vVC setAppearanceWithActive:YES];
        } else {
            [vVC setAppearanceWithActive:NO];
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.localVideoView.superview layoutIfNeeded];
    }];
    
    [self startHiddenNameViewTimer:5];
}

- (void)addRemoveSendContentBackGroundView:(BOOL)isSending {
    if (isSending){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self insertSubview:self.sendContentBackGroundView atIndex:4];
            [self.sendContentBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sendContentBackGroundView removeFromSuperview];
        });
    }
}

- (void)remoteVideoReceived:(NSString *)mediaID{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([mediaID containsString:@"VCR"]) {
            [self.contentVideoView setRenderMediaID:mediaID];
            self.pageControl.hidden = NO;
            [self.contentVideoView startRendering];
        } else {
            MetalVideoView * view= [self getPeopleVideoViewControllerByViewId:mediaID];
            [view renderMuteImage:NO];
            [view startRendering];
        }
    });
}

- (void)onVideoFrozen:(NSString *)mediaID videoFrozen:(BOOL)bFrozen {
    MetalVideoView * view = [self getPeopleVideoViewControllerByViewId:mediaID];
    if(bFrozen) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [view renderMuteImage:YES];
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [view renderMuteImage:NO];
        });
    }
}

- (MetalVideoView *)getPeopleVideoViewControllerByViewId:(NSString *)mediaID {
    for (int i = 0; i < [_remotePeopleVideoViewList count]; i++) {
        MetalVideoView *view = _remotePeopleVideoViewList[i];
        if([view.mediaID isEqualToString:mediaID]) {
            return view;
        }
    }
    
    for(int i = 0; i < [_remotePeopleVideoViewList count]; i++) {
        MetalVideoView *view = _remotePeopleVideoViewList[i];
        if(view.hidden) {
            [view setRenderMediaID:mediaID];
            return view;
        }
    }
    
    return NULL;
}

- (void)muteAllRemotePeopleVideo:(BOOL)isMute rosterListArray:(NSMutableArray *)rosterListArray {
    
    if (isMute) {
        for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
            MetalVideoView *view = _remotePeopleVideoViewList[i];
            [view renderMuteImage:YES];
            [view stopRendering];
        }
    }else {
        for(NSDictionary *dic in rosterListArray) {
            for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
                MetalVideoView *view = _remotePeopleVideoViewList[i];
                if(!view.isHidden && [view.uuid isEqualToString:dic[@"UUID"]]) {
                    if([dic[@"muteVideo"] isEqualToString:@"true"]) {
                        [view renderMuteImage:YES];
                    } else {
                        [view renderMuteImage:NO];
                    }
                }
            }
        }
    }
}

- (void)stopRender {
    [self.localVideoView stopRendering];
    for (int i = 0; i < [_remotePeopleVideoViewList count]; i++) {
        MetalVideoView *view = _remotePeopleVideoViewList[i];
        [view stopRendering];
    }
}

- (void)getCurrentContentAudioMuteState:(NSMutableArray *)rosterListArray {
    for(NSDictionary *dic in rosterListArray) {
        if ([self.contentVideoView.uuid isEqualToString:dic[@"UUID"]]) {
            [self.contentVideoView updateLayoutSiteNameView:[dic[@"muteAudio"] isEqualToString:@"true"]];
        }
    }
}

- (void)configTapGesture {
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self addGestureRecognizer:self.rightSwipeGestureRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(handleSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.delegate = self;
    [self addGestureRecognizer:singleTapRecognizer];
}


#pragma mark - timer

- (void)startHiddenTimer:(NSTimeInterval)timeInterval {
    __weak __typeof(self)weakSelf = self;
    self.hiddenTimer = [NSTimer plua_scheduledTimerWithTimeInterval:timeInterval block:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleHiddenEvent];
    } repeats:NO];
}

- (void)startHiddenNameViewTimer:(NSTimeInterval)timeInterval {
    __weak __typeof(self)weakSelf = self;
    self.hiddenNameViewTimer = [NSTimer plua_scheduledTimerWithTimeInterval:timeInterval block:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleNameViewHiddenEvent];
    } repeats:NO];
}

- (void)cancelTimer {
    if(_hiddenTimer != nil) {
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
    }
    
    if(_hiddenNameViewTimer != nil) {
        [_hiddenNameViewTimer invalidate];
        _hiddenNameViewTimer = nil;
    }
}

- (void)handleHiddenEvent {
    if(self.isShowToorBarView) {
        NSString * FRMeetingUIDisappearOrNotNotification1 = @"com.fmeeting.meetingui.disappear";
        NSString * FRMeetingUIDisappearOrNotKey1 = @"com.fmeeting.meetingui.disappear.key";
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        userInfo[FRMeetingUIDisappearOrNotKey1] = [NSNumber numberWithInteger:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [kNotificationCenter postNotificationName:FRMeetingUIDisappearOrNotNotification1 object:nil userInfo:userInfo];
        });
        
        for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
            MetalVideoView *view = _remotePeopleVideoViewList[i];
            
            if(view.hidden == NO) {
                view.siteNameView.hidden = YES;
            }
        }
        self.showToorBarView = NO;
    }
}

- (void)handleNameViewHiddenEvent {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if(self.showToorBarView) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
        MetalVideoView *view = _remotePeopleVideoViewList[i];
        if(view.hidden == NO) {
            view.siteNameView.hidden = YES;
        }
    }
    
    [UIView commitAnimations];
#pragma clang diagnostic pop
}


#pragma mark - public

- (void)updateParticipantsListState:(NSMutableArray *)rosterListArray {
    for(NSDictionary *dic in rosterListArray) {
        for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
            MetalVideoView *view = _remotePeopleVideoViewList[i];
            if(!view.isHidden && [view.uuid isEqualToString:dic[@"UUID"]]) {
                if([dic[@"muteAudio"] isEqualToString:@"true"]) {
                    [view updateLayoutSiteNameView:YES];
                } else {
                    [view updateLayoutSiteNameView:NO];
                }
            }
        }
        
        if ([self.contentVideoView.uuid isEqualToString:dic[@"UUID"]]) {
            if([dic[@"muteAudio"] isEqualToString:@"true"]) {
                [self.contentVideoView updateLayoutSiteNameView:YES];
            } else {
                [self.contentVideoView updateLayoutSiteNameView:NO];
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleSingleTap:(UIGestureRecognizer *)sender {
    if(self.isShowToorBarView) {
        for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
            MetalVideoView *view = _remotePeopleVideoViewList[i];
            
            if(view.hidden == NO) {
                view.siteNameView.hidden = YES;
            }
        }
        self.showToorBarView = NO;
        [self cancelTimer];
        
    } else {
        
        if(_hiddenNameViewTimer != nil) {
            [_hiddenNameViewTimer invalidate];
            _hiddenNameViewTimer = nil;
        }
        
        for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
            MetalVideoView *view = _remotePeopleVideoViewList[i];
            
            if(view.hidden == NO) {
                view.siteNameView.hidden = NO;
            }
        }
        
        self.showToorBarView = YES;
        [self startHiddenTimer:5];
    }
    NSString * FRMeetingUIDisappearOrNotNotification1 = @"com.fmeeting.meetingui.disappear";
    NSString * FRMeetingUIDisappearOrNotKey1 = @"com.fmeeting.meetingui.disappear.key";
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    userInfo[FRMeetingUIDisappearOrNotKey1] = [NSNumber numberWithInteger:self.showToorBarView ? 1 : 0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [kNotificationCenter postNotificationName:FRMeetingUIDisappearOrNotNotification1 object:nil userInfo:userInfo];
    });
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender {
    if(self.audioCall) {
        return;
    }
    
    if(self.content) {
        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            
            self.pageControl.currentPage = 0;
            
            [self.remotePeopleVideoBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [self.contentVideoBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.remotePeopleVideoBackgroundView.mas_left);
                make.top.bottom.width.equalTo(self);
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                [self layoutIfNeeded];
            }];
            
            NSString *deviceType = [UIDevice currentDevice].model;
            if([deviceType isEqualToString:@"iPad"]) {
                [[ObjectInterface sharedObjectInterface] setPeopleOnlyFlagObject:true];
            }
        }
        
        if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
            
            self.pageControl.currentPage = 1;
            
            [self.contentVideoBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [self.remotePeopleVideoBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.width.equalTo(self);
                make.left.equalTo(self.contentVideoBottomView.mas_right);
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                [self layoutIfNeeded];
            }];
            
            NSString *deviceType = [UIDevice currentDevice].model;
            if([deviceType isEqualToString:@"iPad"]) {
                [[ObjectInterface sharedObjectInterface] setPeopleOnlyFlagObject:false];
            }
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        self.pageControl.hidden = NO;
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        self.pageControl.hidden = YES;
        CGPoint tapPoint = [gesture locationInView:self.contentVideoView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScrollView:self.scrollView withScale:newZoomScale center:tapPoint];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(CGFloat)scale center:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.width = scrollView.frame.size.width / scale;
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentVideoView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.contentVideoView.frame;
    frame.origin.y = (self.scrollView.frame.size.height - self.contentVideoView.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.contentVideoView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.contentVideoView.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.contentVideoView.frame.size.width) * 0.5 : 0;
    self.contentVideoView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.contentVideoView.frame.size.width, self.contentVideoView.frame.size.height);
    
    CGFloat currentScale = scrollView.zoomScale;
    if (currentScale <= 1.0) {
        self.pageControl.hidden = NO;
    }else{
        self.pageControl.hidden = YES;
    }
}

#pragma mark - lazy

- (UIView *)remotePeopleVideoBackgroundView {
    if (!_remotePeopleVideoBackgroundView) {
        _remotePeopleVideoBackgroundView = [[UIView alloc]init];
        _remotePeopleVideoBackgroundView.userInteractionEnabled = YES;
        _remotePeopleVideoBackgroundView.backgroundColor = UIColorHex(0x000000);
    }
    return _remotePeopleVideoBackgroundView;
}

- (UIView*)remotePeopleVideoBottomView {
    if (!_remotePeopleVideoBottomView) {
        _remotePeopleVideoBottomView = [[UIView alloc]init];
        _remotePeopleVideoBottomView.backgroundColor = UIColorHex(0x000000);
    }
    return _remotePeopleVideoBottomView;
}

- (UIView*)contentVideoBottomView {
    if (!_contentVideoBottomView) {
        _contentVideoBottomView = [[UIView alloc]init];
    }
    return _contentVideoBottomView;
}

- (MetalVideoView *)localVideoView {
    if (!_localVideoView) {
        _localVideoView = [[MetalVideoView alloc] initWithFrame:CGRectZero dataMediaID:kLocalVideoMediaID];
        [_localVideoView renderMuteImage:NO];
        [_localVideoView setRenderPixelType:RTC::kI420];
        _localVideoView.siteNameView.hidden = YES;
        _localVideoView.layer.cornerRadius  = 6;
        _localVideoView.layer.masksToBounds = YES;
        [_localVideoView setRenderMediaID:kLocalVideoMediaID];
    }
    return _localVideoView;
}

- (SendContentBackGroundView *)sendContentBackGroundView {
    if(!_sendContentBackGroundView) {
        _sendContentBackGroundView = [[SendContentBackGroundView alloc] init];
    }
    return _sendContentBackGroundView;
}

- (MetalVideoView *)contentVideoView {
    if (!_contentVideoView) {
        _contentVideoView = [[MetalVideoView alloc] initWithFrame:CGRectZero dataMediaID:@"content"];
        _contentVideoView.userInteractionEnabled = YES;
        _contentVideoView.siteNameView.hidden = NO;
        [_contentVideoView renderMuteImage:NO];
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [_contentVideoView addGestureRecognizer:doubleTapGesture];
    }
    return _contentVideoView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = UIColorHex(0x000000);
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 3.0;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage   = 1;
        _pageControl.pageIndicatorTintColor        = UIColor.whiteColor;
        _pageControl.currentPageIndicatorTintColor = UIColor.lightGrayColor;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}


@end
