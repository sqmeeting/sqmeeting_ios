#import <UIKit/UIKit.h>
#import "MetalVideoView.h"
#import "SendContentBackGroundView.h"
#import "MeetingLayoutContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingView : UIView

@property (nonatomic, assign, getter = isAudioCall)         BOOL audioCall;
@property (nonatomic, assign, getter = isLocalViewHidden)   BOOL localViewHidden;
@property (nonatomic, strong) UIPageControl             *pageControl;
@property (nonatomic, strong) UIScrollView              *scrollView;
@property (nonatomic, strong) MetalVideoView            *localVideoView;
@property (nonatomic, strong) MetalVideoView            * __nullable  contentVideoView;
@property (nonatomic, strong) SendContentBackGroundView *sendContentBackGroundView;

- (void)updateParticipantsListState:(NSMutableArray *)rosterListArray;

- (void)updateBottomViewLayout:(BOOL)isContent;

- (void)updateLocalVideoViewLayout:(NSArray *)viewArray content:(BOOL)content isPortrait:(BOOL)isPortrait ;

- (void)updateRemotePeopleVideoBottomViewSubViewsHidden:(NSArray *)viewArray;

- (void)updateRemotePeopleVideoViewState:(NSArray *)viewArray
                                   model:(MeetingLayoutNumber)modeType
                         rosterListArray:(NSMutableArray *)rosterListArray
               activeSpeakerMediaID:(NSString *)activeSpeakerMediaID;

- (void)addRemoveSendContentBackGroundView:(BOOL)isSending;

- (void)remoteVideoReceived:(NSString *)mediaID;

- (void)onVideoFrozen:(NSString *)mediaID videoFrozen:(BOOL)bFrozen;

- (MetalVideoView *)getPeopleVideoViewControllerByViewId :(NSString *)mediaID;

- (void)muteAllRemotePeopleVideo:(BOOL)isMute rosterListArray:(NSMutableArray *)rosterListArray;

- (void)stopRender;

- (void)getCurrentContentAudioMuteState:(NSMutableArray *)rosterListArray;

- (void)getLandscapeFrame;

- (void)getPortraitFrame;

- (void)updateVideoLayout;

@end

NS_ASSUME_NONNULL_END
