#ifndef SDKContextWrapper_h
#define SDKContextWrapper_h

#import <Foundation/Foundation.h>
#import "UserBasicInformation.h"
#include "object_impl.h"
#import "FrtcCall.h"

typedef enum {
    kIdle = 0,
    kConnected,
    kDisconnected
} CallMeetingStatus;

typedef struct _RENDER_FRAME {
    unsigned int width;
    unsigned int height;
    uint16_t     rotation;
    unsigned int pixelAspectRatioWidth;
    unsigned int pixelAspectRatioHeight;
    RTC::VideoColorFormat frameType;
    char *data;
} WrapperRenderFrame;

typedef struct _SDK_LAYOUT_INFO {
    NSMutableArray<UserBasicInformation *> *layout;
    bool bContent;
    NSString *activeMediaID;
    NSString *activeSpeakerUuId;
    NSString *pinUUID;
} SDKLayoutInfo;

typedef void (^MeetingStatusCallBack)(CallMeetingStatus callMeetingStatus, int reason);

typedef void (^RequestPassWordCallBack)(void);

typedef void (^MeetingParamsCallBack)(NSString *uri, 
                                      NSString *meetingID,
                                      NSString *displayName,
                                      NSString *ownerID,
                                      NSString *ownerName,
                                      NSString *meetingUrl,
                                      NSString * groupMeetingUrl,
                                      const long long scheduleStartTime,
                                      const long long scheduleEndTime);

typedef void (^LayoutChangedCallBack)(SDKLayoutInfo buffer);

typedef void (^WaterPrintCallBack)(NSString *waterPrint, 
                                   NSString *recordingStatus,
                                   NSString *liveStatus,
                                   NSString *liveMeetingUrl,
                                   NSString *liveMeetingPwd);

typedef void (^VideoReceivedCallBack)(NSString *mediaID);

typedef void (^ContentStreamRequestCallBack)(NSString *mediaID, 
                                             int width,
                                             int height, 
                                             int framerate);

@protocol ObjectInterfaceDelegate <NSObject>

@optional

- (void)onContentStreamRequested:(NSString *)mediaID width:(int)width height:(int)height framerate:(float)framerate;

- (void)contentStateChanged:(BOOL)isSending;

@end

@interface ObjectInterface : NSObject

@property (nonatomic, copy) MeetingStatusCallBack statusCallBack;

@property (nonatomic, copy) RequestPassWordCallBack passwordCallBack;

@property (nonatomic, copy) MeetingParamsCallBack paramsCallBack;

@property (nonatomic ,copy) LayoutChangedCallBack layoutChangedCallBack;

@property (nonatomic, copy) WaterPrintCallBack waterPrintCallBack;

@property (nonatomic, copy) VideoReceivedCallBack videoReceivedCallBack;

@property (nonatomic, copy) ContentStreamRequestCallBack contentRequestCallBack;

@property (nonatomic, weak) id<ObjectInterfaceDelegate> delegate;

@property (nonatomic, weak) id<FrtcCallDelegate> callDelegate;

+ (ObjectInterface *)sharedObjectInterface;

#pragma mark --call back block--
- (void)OnObjectLayoutChangeCallBack:(const RTC::LayoutDescription&)layout;

- (void)OnObjectAddVideoStreamCallBack:(const std::string&)msid;

- (void)OnObjectRequestVideoStreamCallBack:(const std::string&)msid width:(int)width height:(int)height framerate:(float)frame_rate;

- (void)OnObjectParticipantStatusChangeCallBack:(std::map<std::string, RTC::ParticipantStatus>)roster_list;
        
- (void)OnObjectUnmuteRequestCallBack:(const std::map<std::string, std::string>&)parti_list;

- (void)OnObjectUnmuteAllowCallBack;

- (void)onRostListCallBlock:(std::string)rostList;

- (void)OnObjectLayoutSettingCallBack:(int)max_cell_count lectures:(const std::vector<std::string>&) lectures;

- (void)OnObjectParticipantCountCallBack:(int)parti_count;

- (void)OnObjectParticipantListCallBack:(const std::set<std::string> &)uuid_list;

- (void)OnObjectMeetingStatusChangeCallBack:(RTC::MeetingStatus)status reason:(int)reason;

- (void)OnObjectPasscodeRequestCallBack;

- (void)onObjectNetworkStatusChangedCallBack;

- (void)OnObjectMuteLockCallBack:(bool)muted allow_self_unmute:(bool)allow_self_unmute;

- (void)OnObjectContentStatusChangeCallBack:(BOOL)isSending;

- (void)OnObjectTextOverlayCallBack:(RTC::TextOverlay *)text_overly;

- (void)OnObjectMeetingJoinInfoCallBack:(const std::string&)meeting_name
                             meeting_id:(const std::string&)meeting_id
                           display_name:(const std::string&)display_name
                               owner_id:(const std::string&)owner_id
                             owner_name:(const std::string&)owner_name
                            meeting_url:(const std::string&)meeting_url
                      group_meeting_url:(const std::string&)group_meeting_url
                             start_time:(const long long )start_time
                               end_time:(const long long )end_time;

- (void)OnObjectMeetingSessionStatusCallBack:(std::string)watermark_msg
                            recording_status:(std::string)recording_status
                            streaming_status:(std::string)streaming_status
                               streaming_url:(std::string)streaming_url
                               streaming_pwd:(std::string)streaming_pwd;

- (NSString *)onDeviceName;

#pragma mark --interface--
- (void)joinMeetingWithServerAddress:(NSString *)serverAddress
                     conferenceAlias:(NSString *)meetingAlias
                          clientName:(NSString *)displayName
                           userToken:(NSString *)userToken
                            callRate:(int)callRate
                     meetingPassword:(NSString *)meetingPassword
                             isLogin:(BOOL)isLogin
               meetingStatusCallBack:(void (^)(CallMeetingStatus callState, int reason))statusCallBack
               meetingParamsCallBack:(void (^)(NSString *conferenceName, NSString *meetingID, NSString *displayName, NSString *ownerID, NSString *ownerName, NSString *meetingUrl, NSString * groupMeetingUrl, const long long scheduleStartTime,
                                     const long long scheduleEndTime))paramsCallBack
             requestPasswordCallBack:(void(^)(void))passwordCallBack
             remoteLayoutChangeCallBack:(void (^)(SDKLayoutInfo buffer))layoutChangedCallBack
                      waterPrintCallBack:(void (^)(NSString *waterPrint, NSString *recordingStatus
                                               ,NSString *liveStatus,
                                               NSString *liveMeetingUrl,
                                               NSString *liveMeetingPwd))waterPrintCallBack
            remoteVideoReceivedCallBack:(void (^)(NSString *mediaID))videoReceivedCallBack
           contentStreamRequestdCallBack:(void (^)(NSString *mediaID, int width, int height, int framerate))contentRequestCallBack;

- (void)sendVideoFrameObject:(NSString *)mediaID
                 videoBuffer:(void *)buffer
                      length:(size_t)length
                       width:(size_t)width
                      height:(size_t)height
                    rotation:(size_t)rotation
             videoSampleType:(RTC::VideoColorFormat)type;

- (void)receiveVideoFrameObject:(NSString *)mediaID
                         buffer:(void **)buffer
                         length:(unsigned int*)length
                          width:(unsigned int*)width
                         height:(unsigned int*)height
                       rotation:(unsigned int*)rotation;

- (void)startSendContentStream:(NSString *)mediaID
                   videoBuffer:(void *)buffer
                        length:(size_t)length
                         width:(size_t)width
                        height:(size_t)height
               videoSampleType:(RTC::VideoColorFormat)type
                      rotation:(int)rotation;


- (void)sendAudioFrameObject:(void*)buffer
                      length:(unsigned int )length
                 sampleRatge:(unsigned int)sample_rate;

- (void)receiveAudioFrameObject:(void *)buffer
                     dataLength:(unsigned int)length
                     sampleRate:(unsigned int)sample_rate;

- (void)verifyPasscodeObject:(NSString *)passcode;

- (void)endMeetingWithCallIndex:(int)callIndex;

- (void)muteLocalVideoObject:(bool)muted;

- (void)muteLocalAudioObject:(bool)muted;

- (void)setPeopleOnlyFlagObject:(bool)bOnlyReqPeople;

- (void)muteRemoteVideoObject:(bool)mute;

- (NSString *)getMediaStatisticsObject;

- (void)startSendContentObject;

- (void)stopSendContentObject;

- (void)setCameraCapabilityObject:(std::string)resolution_str;

- (NSString*)getVersion;

- (void)setIntelligentNoiseReductionObject:(bool)enable;

- (NSInteger)startUploadLogs:(NSString *)metaData
                    fileName:(NSString *)fileName
                   fileCount:(int)fileCount;

- (NSString *)getUploadStatus:(int)tractionId fileType:(int)fileType;

- (void)cancelUploadLogs:(int)tractionId;

@end

#endif /* SDKContextWrapper_h */
