#import "SampleHandler.h"
#import "FrtcMeetingScreenBroadcastSocketClient.h"

NSString * const CFNotificationBroadcastStarted = @"kDarvinNotificationNamePushStart";
NSString * const CFNotificationBroadcastStop    = @"kDarvinNotificationNamePushStop";

@interface SampleHandler ()<FrtcMeetingSampleHandlerDelegate>
@end

@implementation SampleHandler

- (instancetype)init {
    if(self = [super init]) {
        [FrtcMeetingScreenBroadcastSocketClient singleClient].delegate = self;
    }
    return self;
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    [self notificationToHostApp:CFNotificationBroadcastStarted];
    [[FrtcMeetingScreenBroadcastSocketClient singleClient] setUpSocket];
}

- (void)broadcastPaused {
   
}

- (void)broadcastResumed {
    
}

- (void)broadcastFinished {
    [self notificationToHostApp:CFNotificationBroadcastStop];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            [[FrtcMeetingScreenBroadcastSocketClient singleClient] sendVideoBufferToHostApp:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle app audio buffer
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle mic audio buffer
            break;
        default:
            break;
    }
}

#pragma mark - CFNotification to Host App

- (void)notificationToHostApp:(NSString *)notificationName {
    CFStringRef cfNotificationName = (__bridge CFStringRef)notificationName;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), cfNotificationName, NULL, nil, YES);
}

#pragma mark - FrtcMeetingSampleHandlerDelegate

- (void)frtcBroadcastFinished {
    NSString *tip = @"你已停止共享屏幕";
    NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                         code:0
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: tip}];
    [self finishBroadcastWithError:error];
}

@end

