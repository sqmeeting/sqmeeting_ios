#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ScreenCaptureCallBack)(BOOL isSharing);

@interface FrtcRtcsdkExtention : NSObject

+ (FrtcRtcsdkExtention *)frtcSharedCallClientExtention;

- (NSString *)staticsInfo;

- (void)muteLocalVideo:(BOOL)mute;

- (void)muteLocalAudio:(BOOL)mute;

- (void)sendPasscode:(NSString *)passcode;

- (void)setOnlyReqPeopleFlag:(BOOL)flag;

-(void) contentSharing: (BOOL)isShare;

-(void) setScreenCaptureCallBack:(ScreenCaptureCallBack) callback;

-(void) contentDataReady: (void*)buffer width:(size_t) width height:(size_t)height pixformat:(OSType)pixformat roration:(size_t )roration;

@end

NS_ASSUME_NONNULL_END
