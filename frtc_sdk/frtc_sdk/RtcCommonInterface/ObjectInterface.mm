#import <Foundation/Foundation.h>
#import "ObjectInterface.h"
#import "NSNotificationCenter+NotificationCenterAdditions.h"
#import "FrtcUUID.h"
#import "SDKUserDefault.h"
#import "FrtcCall.h"
//#include "IRender.h"
#import <UIKit/UIKit.h>

static ObjectInterface *objectInterface = nil;

@interface ObjectInterface() {
    ObjectImpl *_impl;
}

@end

@implementation ObjectInterface

+ (ObjectInterface*)sharedObjectInterface {
    @synchronized(self) {
        if (objectInterface == nil) {
            objectInterface = [[ObjectInterface alloc] init];
        }
    }
    
    return objectInterface;
}

- (id)init {
    if (self = [super init]) {
        _impl = new ObjectImpl();
        
        if (!_impl) {
            self = nil;
        }
        
        if(self != nil) {
            _impl->Init((__bridge void *)self, [[[FrtcUUID sharedUUID] getAplicationUUID] UTF8String]);
        }
    }
    
    return self;
}

- (void)OnObjectLayoutChangeCallBack:(const RTC::LayoutDescription&)layout {
    std::vector<RTC::LayoutCell> layoutCells = layout.layout_cells;
    NSMutableArray<UserBasicInformation *> *layoutItem = [NSMutableArray array];
    
    for(std::vector<RTC::LayoutCell>::iterator iter = layoutCells.begin();iter != layoutCells.end();iter++) {
        UserBasicInformation *infoItem  = [[UserBasicInformation alloc] init];
        infoItem.mediaID                = [self transferToString:iter->msid];
        infoItem.userDisplayName        = [self transferToString:iter->display_name];
        infoItem.userUUID               = [self transferToString:iter->uuid];
        infoItem.resolutionHeight       = (NSInteger)iter->height;
        infoItem.resolutionWidth        = (NSInteger)iter->width;
        
        [layoutItem addObject:infoItem];
    }
    
    SDKLayoutInfo sdkLayoutInfo;
    sdkLayoutInfo.layout = layoutItem;
    sdkLayoutInfo.activeMediaID         = [self transferToString:layout.active_speaker_msid];
    sdkLayoutInfo.activeSpeakerUuId     = [self transferToString:layout.active_speaker_uuid];
    sdkLayoutInfo.pinUUID               = [self transferToString:layout.pin_speaker_uuid];
    sdkLayoutInfo.bContent              = layout.has_content;
    
    self.layoutChangedCallBack(sdkLayoutInfo);
}

- (void)OnObjectAddVideoStreamCallBack:(const std::string&)msid {
    self.videoReceivedCallBack([NSString stringWithFormat:@"%s", msid.c_str()]);
}

- (void)OnObjectRequestVideoStreamCallBack:(const std::string&)msid width:(int)width height:(int)height framerate:(float)frame_rate {
    if(msid.rfind("VCS", 0) == 0) {
        self.contentRequestCallBack([NSString stringWithCString:msid.c_str() encoding:NSUTF8StringEncoding], width, height, frame_rate);
    }
}


- (void)OnObjectMeetingStatusChangeCallBack:(RTC::MeetingStatus)status reason:(int)reason {
    self.statusCallBack(static_cast<CallMeetingStatus>(status), reason);
    
    if(status == RTC::kConnected) {
        NSString *serverAddr = [[SDKUserDefault sharedSDKUserDefault] sdkObjectForKey:SKD_SERVER_ADDRESS];
        if (!serverAddr || serverAddr.length == 0) {
            [[SDKUserDefault sharedSDKUserDefault] setSDKObject:serverAddr forKey:SKD_SERVER_ADDRESS];
        }
    }
    
}

- (void)OnObjectContentStatusChangeCallBack:(BOOL)isSending {
    if([self.delegate respondsToSelector:@selector(contentStateChanged:)] ) {
        [self.delegate contentStateChanged:isSending];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onContentState:)]) {
            [self.callDelegate onContentState:isSending ? 1 : 0];
        }
    });
}

- (void)OnObjectPasscodeRequestCallBack {
    self.passwordCallBack();
}

- (void)onObjectNetworkStatusChangedCallBack {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onNetworkStateChanged:)]) {
            [self.callDelegate onNetworkStateChanged:1];
        }
    });
}

- (void)OnObjectMuteLockCallBack:(bool)muted allow_self_unmute:(bool)allow_self_unmute {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL mute = muted ? YES : NO;
        BOOL allowSelfUnMute = allow_self_unmute ? YES : NO;
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onMute:allowSelfUnmute:)]) {
            [self.callDelegate onMute:mute allowSelfUnmute:allowSelfUnMute];
        }
    });
}

- (void)OnObjectTextOverlayCallBack:(RTC::TextOverlay *)text_overly {
    NSDictionary *dic = @{
        @"color"                    : [self transferToString:text_overly->color],
        @"content"                  : [self transferToString:text_overly->text],
        @"displaySpeed"             : [self transferToString:text_overly->display_speed],
        @"font"                     : [self transferToString:text_overly->font],
        @"type"                     : [self transferToString:text_overly->text_overlay_type],
        @"backgroundTransparency"   : @(text_overly->background_transparency),
        @"displayRepetition"        : @(text_overly->display_repetition),
        @"fontSize"                 : @(text_overly->font_size),
        @"verticalPosition"         : @(text_overly->vertical_position),
        @"enabledMessageOverlay"    : [NSNumber numberWithBool:text_overly->enabled ? YES : NO]
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:0];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onMeetingMessage:)]) {
            [self.callDelegate onMeetingMessage:jsonString];
        }
    });
}

- (void)OnObjectParticipantStatusChangeCallBack:(std::map<std::string, RTC::ParticipantStatus>)roster_list {
    __block NSMutableArray<NSDictionary *> *rosterListArray = [NSMutableArray array];
    
    for(std::map<std::string, RTC::ParticipantStatus>::iterator item = roster_list.begin(); item != roster_list.end(); item++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        std::string key = item->first;
        NSString *uuid = [NSString stringWithCString:(key).c_str() encoding:NSUTF8StringEncoding];
        dic[@"UUID"] = uuid;
        
        std::string display_name = item->second.display_name;
        NSString *displayName = [NSString stringWithCString:(display_name).c_str() encoding:NSUTF8StringEncoding];
        dic[@"name"] = displayName;
        
        std::string user_Id = item->second.user_id;
        NSString *userID = [NSString stringWithCString:(user_Id).c_str() encoding:NSUTF8StringEncoding];
        dic[@"userId"] = userID;
        
        NSString *muteAudio = item->second.audio_mute? @"true" : @"false";
        NSString *muteVideo = item->second.video_mute? @"true" : @"false";
        dic[@"muteAudio"] = muteAudio;
        dic[@"muteVideo"] = muteVideo;
        
        [rosterListArray addObject:dic];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onParticipantsList:)]) {
            [self.callDelegate onParticipantsList:rosterListArray];
        }
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:rosterListArray forKey:FMeetingParticipantsListKey];
        [nc postNotificationNameOnMainThread:FMeetingParticipantsListKeyNotification object:nil userInfo:dic];
    });
}

- (void)OnObjectUnmuteRequestCallBack:(const std::map<std::string, std::string>&)parti_list {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for(std::map<std::string, std::string>::const_iterator item = parti_list.begin(); item != parti_list.end(); item++) {
        [dictionary setObject:[NSString stringWithCString:(item->second).c_str() encoding:NSUTF8StringEncoding] forKey:[NSString stringWithCString:(item->first).c_str() encoding:NSUTF8StringEncoding]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onReceiveUnmuteRequest:)]) {
            [self.callDelegate onReceiveUnmuteRequest:dictionary];
        }
    });
}

- (void)OnObjectUnmuteAllowCallBack {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onReceiveAllowUnmute)]) {
            [self.callDelegate onReceiveAllowUnmute];
        }
    });
}

- (void)OnObjectLayoutSettingCallBack:(int)max_cell_count lectures:(const std::vector<std::string>&) lectures {
    NSMutableArray<NSString *> *lectureListArray = [NSMutableArray array];
    
    for(std::vector<std::string>::const_iterator iter = lectures.begin();iter < lectures.end(); iter++) {
        [lectureListArray addObject:[NSString stringWithCString:(*iter).c_str() encoding:NSUTF8StringEncoding]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onLectureList:)]) {
            [self.callDelegate onLectureList:lectureListArray];
        }
    });
}

- (void)onRostListCallBlock:(std::string)rostList {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *rostListString = [NSString stringWithCString:rostList.c_str() encoding:NSUTF8StringEncoding];
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onRostList:)]) {
            [self.callDelegate onRostList:rostListString];
        }
    });
}

- (void)OnObjectParticipantCountCallBack:(int)parti_count {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.callDelegate && [self.callDelegate respondsToSelector:@selector(onParticipantsNumber:)]) {
            [self.callDelegate onParticipantsNumber:parti_count];
        }
    });
}

- (void)OnObjectParticipantListCallBack:(const std::set<std::string> &)uuid_list {
    
}


- (void)OnObjectMeetingJoinInfoCallBack:(const std::string&)meeting_name
                             meeting_id:(const std::string&)meeting_id
                           display_name:(const std::string&)display_name
                               owner_id:(const std::string&)owner_id
                             owner_name:(const std::string&)owner_name
                            meeting_url:(const std::string&)meeting_url
                      group_meeting_url:(const std::string&)group_meeting_url
                             start_time:(const long long )start_time
                               end_time:(const long long )end_time {
    if(self.paramsCallBack) {
        self.paramsCallBack([self transferToString:meeting_name],
                            [self transferToString:meeting_id],
                            [self transferToString:display_name],
                            [self transferToString:owner_id],
                            [self transferToString:owner_name],
                            [self transferToString:meeting_url],
                            [self transferToString:group_meeting_url],
                            start_time,
                            end_time);
    }
}

- (void)onEncryptStateReportCallBack:(bool)encrypted {
    //BOOL encrypState = encrypted ? YES : NO;
}

- (void)OnObjectMeetingSessionStatusCallBack:(std::string)watermark_msg
                            recording_status:(std::string)recording_status
                            streaming_status:(std::string)streaming_status
                               streaming_url:(std::string)streaming_url
                               streaming_pwd:(std::string)streaming_pwd {
    self.waterPrintCallBack([self transferToString:watermark_msg],
                        [self transferToString:recording_status],
                        [self transferToString:streaming_status],
                        [self transferToString:streaming_url],
                        [self transferToString:streaming_pwd]);
}

- (NSString *)onDeviceName {
    NSString *iPhoneName = [UIDevice currentDevice].name;
    return iPhoneName;
}


- (void)verifyPasscodeObject:(NSString *)passcode {
    _impl->VerifyPasscodeImpl([passcode UTF8String]);
}

- (void)joinMeetingWithServerAddress:(NSString *)serverAddress
                     conferenceAlias:(NSString *)meetingAlias
                          clientName:(NSString *)displayName
                           userToken:(NSString *)userToken
                            callRate:(int)callRate
                     meetingPassword:(NSString *)meetingPassword
                             isLogin:(BOOL)isLogin
               meetingStatusCallBack:(void (^)(CallMeetingStatus callState, int reason))statusCallBack
               meetingParamsCallBack:(void (^)(NSString *conferenceName, 
                                               NSString *meetingID,
                                               NSString *displayName,
                                               NSString *ownerID,
                                               NSString *ownerName,
                                               NSString *meetingUrl,
                                               NSString * groupMeetingUrl,
                                               const long long scheduleStartTime,
                                               const long long scheduleEndTime))paramsCallBack
             requestPasswordCallBack:(void(^)(void))passwordCallBack
          remoteLayoutChangeCallBack:(void (^)(SDKLayoutInfo buffer))layoutChangedCallBack
                  waterPrintCallBack:(void (^)(NSString *waterPrint, 
                                               NSString *recordingStatus,
                                               NSString *liveStatus,
                                               NSString *liveMeetingUrl,
                                               NSString *liveMeetingPwd))waterPrintCallBack
         remoteVideoReceivedCallBack:(void (^)(NSString *mediaID))videoReceivedCallBack
       contentStreamRequestdCallBack:(void (^)(NSString *mediaID, int width, int height, int framerate))contentRequestCallBack {
    self.statusCallBack             = statusCallBack;
    self.paramsCallBack             = paramsCallBack;
    self.passwordCallBack           = passwordCallBack;
    self.layoutChangedCallBack      = layoutChangedCallBack;
    self.waterPrintCallBack         = waterPrintCallBack;
    self.videoReceivedCallBack      = videoReceivedCallBack;
    self.contentRequestCallBack     = contentRequestCallBack;
    
    if (isLogin) {
        _impl->JoinMeetingLoginImpl([serverAddress UTF8String],[meetingAlias UTF8String],[displayName UTF8String], [userToken UTF8String], [meetingPassword UTF8String], callRate);
    } else {
        _impl->JoinMeetingNoLoginImpl([serverAddress UTF8String], [meetingAlias UTF8String], [displayName UTF8String], [meetingPassword UTF8String], callRate);
    }
}

- (void)sendVideoFrameObject:(NSString *)mediaID
                 videoBuffer:(void *)buffer
                      length:(size_t)length
                       width:(size_t)width
                      height:(size_t)height
                    rotation:(size_t)rotation
             videoSampleType:(RTC::VideoColorFormat)type {
    _impl->SendVideoFrameImpl([mediaID UTF8String], buffer, (unsigned int)length, (unsigned int)width, (unsigned int)height, (unsigned int)rotation, type, false);
}

- (void)startSendContentStream:(NSString *)mediaID
                   videoBuffer:(void *)buffer
                        length:(size_t)length
                         width:(size_t)width
                        height:(size_t)height
               videoSampleType:(RTC::VideoColorFormat)type
                      rotation:(int)rotation {
    _impl->SendVideoFrameImpl([mediaID UTF8String], buffer, (unsigned int)length, (unsigned int)width, (unsigned int)height, (unsigned int)rotation, type, true);
}

- (void)receiveVideoFrameObject:(NSString *)mediaID
                         buffer:(void **)buffer
                         length:(unsigned int*)length
                          width:(unsigned int*)width
                         height:(unsigned int*)height
                      rotation :(unsigned int*)rotation {
    std::string temp_media_id = [mediaID UTF8String];
    _impl->ReceiveVideoFrameImpl(temp_media_id, buffer, length, width, height, rotation);
}

- (void)endMeetingWithCallIndex:(int)callIndex {
    _impl->EndMeetingImpl(callIndex);
}

- (void)muteLocalVideoObject:(bool)muted {
    _impl->MuteLocalVideoImpl(muted);
}

- (void)muteLocalAudioObject:(bool)muted {
    _impl->MuteLocalAudioImpl(muted);
}

- (void)sendAudioFrameObject:(void*)buffer
                      length:(unsigned int )length
                 sampleRatge:(unsigned int)sample_rate {
    
//    char pFName[256] = {0};
//    char* sHome = NULL;
//    sHome = getenv("HOME");
//    if (sHome)
//    {
//        sHome = strstr(sHome,"/var");
//        if(sHome != NULL)
//        {
//            sprintf(pFName,"%s/Documents/audio",sHome);
//        }
//    }
//    
//    char destPath[200] = { 0 };
//    sprintf( destPath,"%s.pcm", pFName );
//    
//    FILE *pSentPCM= fopen(destPath,"a+b");
//    if (pSentPCM)
//    {
//        fwrite(buffer, length, 1, pSentPCM);
//        fclose(pSentPCM);
//    }
    _impl->SendAudioFrameImpl(buffer, length, sample_rate);
}

- (void)receiveAudioFrameObject:(void *)buffer
                     dataLength:(unsigned int)length
                     sampleRate:(unsigned int)sample_rate {
    _impl->ReceiveAudioFrameImpl(buffer, length, sample_rate);
}

- (void)setPeopleOnlyFlagObject:(bool)bOnlyReqPeople {
    _impl->SetPeopleOnlyFlagImpl(bOnlyReqPeople);
}

- (void)muteRemoteVideoObject:(bool)mute {
    _impl->MuteRemoteVideoImpl(mute);
}

- (NSString *)getMediaStatisticsObject {
    std::string staticsString = _impl->GetMediaStatisticsImpl();
    return  [NSString stringWithCString:staticsString.c_str() encoding:NSUTF8StringEncoding];
}

- (void)startSendContentObject {
    _impl->StartSendContentImpl();
}

- (void)stopSendContentObject {
    _impl->StopSendContentImpl();
}

- (void)setCameraCapabilityObject:(std::string)resolution_str {
    return _impl->SetCameraCapabilityImpl(resolution_str);
}

- (NSString *)getVersion {
    //   std::string ver = _appObject->getVersion();
    //    return  [NSString stringWithCString:ver.c_str() encoding:NSUTF8StringEncoding];
    
    return @"";
}

- (void)setIntelligentNoiseReductionObject:(bool)enable {
    _impl->SetIntelligentNoiseReductionImpl(enable);
}


- (NSString *)transferToString:(std::string)string {
    return [NSString stringWithCString:string.c_str() encoding:NSUTF8StringEncoding];
}

- (NSInteger)startUploadLogs:(NSString *)metaData
                    fileName:(NSString *)fileName
                   fileCount:(int)fileCount {
    return _impl->StartUploadLogsImpl([metaData UTF8String], [fileName UTF8String], fileCount);}

- (NSString *)getUploadStatus:(int)tractionId fileType:(int)fileType {
    std::string logString = _impl->GetUploadStatusImpl(tractionId);
    
    return [NSString stringWithCString:logString.c_str() encoding:NSUTF8StringEncoding];
}

- (void)cancelUploadLogs:(int)tractionId {
    _impl->CancelUploadLogsImpl(tractionId);
}

@end
