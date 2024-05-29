#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcLiveStatusModel : NSObject

@property (nonatomic, strong) NSString *liveMeetingUrl;
@property (nonatomic, strong) NSString *liveStatus;
@property (nonatomic, strong) NSString *recordingStatus;
@property (nonatomic, strong) NSString *liveMeetingPwd;
@property (nonatomic, getter=isLive)      BOOL live;
@property (nonatomic, getter=isRecording) BOOL recording;

@end

NS_ASSUME_NONNULL_END
