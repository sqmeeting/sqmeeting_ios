#import <UIKit/UIKit.h>
#import "FrtcMeetingModel.h"
#import "ObjectInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnDidChangeOrientation)(void);

@interface FrtcMeetingViewController : UIViewController

@property (nonatomic, assign)       BOOL isPortrait;

@property (nonatomic, strong) FrtcMeetingModel *meetingModel;

@property (nonatomic, weak) id<FrtcCallDelegate> callDelegate;

@property (nonatomic, copy) OnDidChangeOrientation onDidChangeOrientation;

- (void)muteMicroPhone:(BOOL)mute;

- (void)muteVideo:(BOOL)isMute;

- (void)hidePreview:(BOOL)isHide;

- (void)switchVideoFrontOrRear;

- (void)setAudioSessionPortOverride:(BOOL)isSpeaker;

- (void)updateVideoArrangeLayout;

- (void)stopRender;

- (void)waterPrint:(NSString *)waterPrint;

- (void)remoteLayoutChanged:(SDKLayoutInfo)buffer;

- (void)remoteVideoReceived:(NSString *)mediaID;

- (void)onVideoFrozen:(NSString *)mediaID videoFrozen:(BOOL)bFrozen;

- (void)setRecordingStatus:(NSString *)recordingStatus
                liveStatus:(NSString *)liveStatus
            liveMeetingUrl:(NSString *)liveMeetingUrl
            liveMeetingPwd:(NSString *)liveMeetingPwd;

- (void)muteAllRemotePeopleVideo:(BOOL)isMute;

- (void)floatingWindow:(BOOL)isFloat;

- (BOOL)rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

NS_ASSUME_NONNULL_END
