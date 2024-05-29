#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingModel : NSObject

@property (nonatomic, assign, getter = isMuteCamera)        BOOL muteCamera;
@property (nonatomic, assign, getter = isMuteMicrophone)    BOOL muteMicrophone;
@property (nonatomic, assign, getter = isAudioCall)         BOOL audioCall;
@property (nonatomic, assign, getter = isFloatSharing)      BOOL floatSharing;

@property (nonatomic, copy) NSString *callName;
@property (nonatomic, copy) NSString *conferenceName;
@property (nonatomic, copy) NSString *conferenceAlias;
@property (nonatomic, copy) NSString *messageOverLay;

@property (nonatomic, copy) NSString *meetingRecordingStatus;
@property (nonatomic, copy) NSString *meetingLiveStatus;
@property (nonatomic, copy) NSString *meetingLiveMeetingUrl;
@property (nonatomic, copy) NSString *meetingLiveMeetingPwd;


@end

NS_ASSUME_NONNULL_END
