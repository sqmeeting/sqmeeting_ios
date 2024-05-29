#import "FrtcRtcsdkExtention.h"
#import "ObjectInterface.h"
#import "ContentCaptureAdaper.h"

static FrtcRtcsdkExtention *clientExtention = nil;

@implementation FrtcRtcsdkExtention

+ (FrtcRtcsdkExtention *)frtcSharedCallClientExtention {
    @synchronized(self) {
        if (clientExtention == nil) {
            clientExtention = [[FrtcRtcsdkExtention alloc] init];
        }
    }
    
    return clientExtention;
}

- (void)muteLocalVideo:(BOOL)mute {
    [[ObjectInterface sharedObjectInterface] muteLocalVideoObject:mute];
}

- (void)muteLocalAudio:(BOOL)mute {
    [[ObjectInterface sharedObjectInterface] muteLocalAudioObject:mute];
}

- (NSString *)staticsInfo {
    return [[ObjectInterface sharedObjectInterface] getMediaStatisticsObject];
}

- (void)sendPasscode:(NSString *)passcode {
    [[ObjectInterface sharedObjectInterface] verifyPasscodeObject:passcode];
}

- (void)setOnlyReqPeopleFlag:(BOOL)flag {
    [[ObjectInterface sharedObjectInterface] setPeopleOnlyFlagObject:flag];
}

-(void)contentSharing:(BOOL)isShare {
    if(isShare) {
        [[ContentCaptureAdaper SingletonInstance] startContentSharing];
    } else {
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(backgroundQueue, ^{
            [[ContentCaptureAdaper SingletonInstance] stopContentSharing];
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        });
    }
}

-(void) contentDataReady: (void*)buffer width:(size_t) width height:(size_t)height pixformat:(OSType)pixformat roration:(size_t )roration {
    [[ContentCaptureAdaper SingletonInstance] onContentBufferReady:buffer width:width height:height pixFormmat:pixformat roration:roration];
}

-(void)setScreenCaptureCallBack:(ScreenCaptureCallBack)callback {
    [ContentCaptureAdaper SingletonInstance].screenCaptureCB = callback;
}

@end
