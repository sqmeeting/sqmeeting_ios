#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FRTCSDKLoginResult) {
    FRTCSDK_LOGIN_SUCCESS,
    FRTCSDK_LOGIN_ERROR_PASSWORD,
    FRTCSDK_LOGIN_SERVER_NOT_REACHABLE
};

typedef NS_ENUM(NSUInteger, FRTCSDKConfigKey) {
    FRTCSDK_SERVER_ADDRESS,
    FRTCSDK_SERVER_LOGOUT,
};

typedef NS_ENUM(NSInteger, FRTCSDKModifyPasswordResult) {
    FRTCSDK_MODIFY_PASSWORD_SUCCESS,
    FRTCSDK_MODIFY_PASSWORD_FAILED
};

@interface FrtcManagement : NSObject

+ (FrtcManagement *)sharedManagement;

#pragma mark --config--

- (void)setFRTCSDKConfig:(FRTCSDKConfigKey)key withSDKConfigValue:(NSString *)value;

#pragma mark --login--

- (void)loginWithUserName:(NSString *)userName
             withPassword:(NSString *)password
             loginSuccess:(nullable void (^)(NSDictionary * userInfo))loginSuccess
             loginFailure:(nullable void (^)(NSError *error))loginFailure;


- (void)getLoginUserInfomation:(NSString *)userToken
                getInfoSuccess:(nullable void (^)(NSDictionary * userInfo))getInfoSuccess
                getInfoFailure:(nullable void (^)(NSError *error))getInfoFailure;

- (void)logoutWithUserToken:(NSString *)userToken
              logoutSuccess:(nullable void (^)(NSDictionary * userInfo))logoutSuccess
              logoutFailure:(nullable void (^)(NSError *error))logoutFailure;

- (void)modifyUserPasswordWithUserToken:(NSString *)userToken
                            oldPassword:(NSString *)oldPassword
                            newPassword:(NSString *)newPassword
                modifyCompletionHandler:(nullable void (^)(FRTCSDKModifyPasswordResult result))completionHandler;

#pragma mark --Call Meeting--

- (void)scheduleMeetingWithUsertoken:(NSString *)usertoken
                         meetingName:(NSString *)meetingName
           scheduleCompletionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                     scheduleFailure:(nullable void (^)(NSError *error))scheduleFailure;

- (void)queryMeetingRoomList:(NSString *)usertoken
     queryMeetingRoomSuccess:(nullable void (^)(NSDictionary * meetingRoom))querySuccess
     queryMeetingRoomFailure:(nullable void (^)(NSError *error))queryFailure;

- (void)getScheduledMeeting:(NSString *)usertoken
                   withPage:(NSInteger)page
        getScheduledHandler:(nullable void (^)(NSDictionary * scheduledMeetingInfo))completionHandler
        getScheduledFailure:(nullable void (^)(NSError *error))getScheduledFailure;

- (void)deleteNonCurrentMeeting:(NSString *)userToken
              withReservationId:(NSString *)reservationId
                    deleteGroup:(BOOL)deleteGroup
        deleteCompletionHandler:(nullable void (^)(void))completionHandler
                  deleteFailure:(nullable void (^)(NSError *error))deleteFailure;

- (void)getUserList:(NSString *)userToken
           withPage:(NSInteger)page
         withFilter:(NSString *)filter
  completionHandler:(nullable void (^)(NSDictionary * allUserListInfo))completionHandler
            failure:(nullable void (^)(NSError *error))getFailure;

- (void)createMeeting:(NSString *)userToken
    withMeetingParams:(NSDictionary *)meetingParams
    completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
              failure:(nullable void (^)(NSError *error))createFailure;

- (void)getScheduleMeetingDetailInformation:(NSString *)userToken
                          withReservationID:(NSString *)reservationID
                          completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                                    failure:(nullable void (^)(NSError *error))getDetailInfoFailure;

- (void)updateScheduleMeeting:(NSString *)userToken
            withReservationID:(NSString *)reservationID
            withMeetingParams:(NSDictionary *)meetingParams
            completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                      failure:(nullable void (^)(NSError *error))updateMeetingFailure;



#pragma mark --Mute Participants--

- (void)muteAllParticipants:(NSString *)usertoken
              meetingNumber:(NSString *)meetingNumber
                       mute:(BOOL)allowSelfUnmute
   muteAllCompletionHandler:(nullable void (^)(void))completionHandler
             muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure;

- (void)muteParticipant:(NSString *)usertoken
          meetingNumber:(NSString *)meetingNumber
        allowSelfUnmute:(BOOL)allowSelfUnmute
        participantList:(NSArray<NSString *> *)participantList
  muteCompletionHandler:(nullable void (^)(void))completionHandler
         muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure;

- (void)unMuteAllParticipants:(NSString *)usertoken
                meetingNumber:(NSString *)meetingNumber
     muteAllCompletionHandler:(nullable void (^)(void))completionHandler
               muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure;

- (void)unMuteParticipant:(NSString *)usertoken
            meetingNumber:(NSString *)meetingNumber
          participantList:(NSArray<NSString *> *)participantList
    muteCompletionHandler:(nullable void (^)(void))completionHandler
           muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure;

- (void)stopMeeting:(NSString *)usertoken
      meetingNumber:(NSString *)meetingNumber
    participantList:(NSArray<NSString *> *)participantList
stopCompletionHandler:(nullable void (^)(void))completionHandler
        stopFailure:(nullable void (^)(NSError *error))stopFailure;

- (void)updateParticipantInfoForGuest:(NSString *)meetingNumber
                          displayName:(NSString *)displayName
                           tempServer:(BOOL)isTempServer
                          tempAddress:(NSString *)tempAddress
                    completionHandler:(nullable void (^)(void))completionHandler
                              failure:(nullable void (^)(NSError *error))failure;

- (void)updateParticipantInfoForSignIn:(NSString *)usertoken
                         meetingNumber:(NSString *)meetingNumber
                           participant:(NSString *)participant
                           displayName:(NSString *)displayName
                     completionHandler:(nullable void (^)(void))completionHandler
                               failure:(nullable void (^)(NSError *error))failure;

- (void)setLecturer:(NSString *)usertoken
       lecturerUUID:(NSString *)lecturerUUID
      meetingNumber:(NSString *)meetingNumber
  completionHandler:(nullable void (^)(void))completionHandler
            failure:(nullable void (^)(NSError *error))failure;

- (void)unsetLecturer:(NSString *)userToken
        meetingNumber:(NSString *)meetingNumber
    completionHandler:(nullable void (^)(void))completionHandler
              failure:(nullable void (^)(NSError *error))failure;

- (void)disConnectParticipants:(NSString *)usertoken
                 meetingNumber:(NSString *)meetingNumber
               participantList:(NSArray<NSString *> *)participantList
             completionHandler:(nullable void (^)(void))completionHandler
                       failure:(nullable void (^)(NSError *error))failure;

- (void)startTextOverlay:(NSString *)usertoken
           meetingNumber:(NSString *)meetingNumber
                 content:(NSString *)content
                  repeat:(NSNumber *)repeat
                position:(NSNumber *)position
           enable_scroll:(NSNumber *)enable
       completionHandler:(nullable void (^)(void))completionHandler
                 failure:(nullable void (^)(NSError *error))failure;

- (void)stopTextOverlay:(NSString *)usertoken
          meetingNumber:(NSString *)meetingNumber
      completionHandler:(nullable void (^)(void))completionHandler
                failure:(nullable void (^)(NSError *error))failure;

- (void)startRecording:(NSString *)usertoken
         meetingNumber:(NSString *)meetingNumber
     completionHandler:(nullable void (^)(void))completionHandler
               failure:(nullable void (^)(NSError *error))failure;

- (void)stopRecording:(NSString *)usertoken
        meetingNumber:(NSString *)meetingNumber
    completionHandler:(nullable void (^)(void))completionHandler
              failure:(nullable void (^)(NSError *error))failure;

- (void)startLive:(NSString *)usertoken
    meetingNumber:(NSString *)meetingNumber
     livePassword:(NSString *)live_password
completionHandler:(nullable void (^)(void))completionHandler
          failure:(nullable void (^)(NSError *error))failure;

- (void)stopLive:(NSString *)usertoken
   meetingNumber:(NSString *)meetingNumber
completionHandler:(nullable void (^)(void))completionHandler
         failure:(nullable void (^)(NSError *error))failure;

- (void)requestUnmute:(NSString *)usertoken
        meetingNumber:(NSString *)meetingNumber
    completionHandler:(nullable void (^)(void))completionHandler
              failure:(nullable void (^)(NSError *error))failure;

- (void)requestUnmuteForGuest:(NSString *)usertoken
                meetingNumber:(NSString *)meetingNumber
                  tempAddress:(NSString *)tempAddress
            completionHandler:(nullable void (^)(void))completionHandler
                      failure:(nullable void (^)(NSError *error))failure;

- (void)allowUnmute:(NSString *)usertoken
      meetingNumber:(NSString *)meetingNumber
         parameters:(NSArray<NSString *> *)parameters
  completionHandler:(nullable void (^)(void))completionHandler
            failure:(nullable void (^)(NSError *error))failure;

- (void)peoplePin:(NSString *)usertoken
    meetingNumber:(NSString *)meetingNumber
       parameters:(NSArray<NSString *> *)parameters
completionHandler:(nullable void (^)(void))completionHandler
          failure:(nullable void (^)(NSError *error))failure;

- (void)peopleUnPin:(NSString *)usertoken
      meetingNumber:(NSString *)meetingNumber
  completionHandler:(nullable void (^)(void))completionHandler
            failure:(nullable void (^)(NSError *error))failure;

- (void)queryUrlMeetingInfo:(NSString *)url
               meetingToken:(NSString *)meetingToken
          completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                    failure:(nullable void (^)(NSError *error))meetingFailure;

- (void)createRecurrentMeeting:(NSString *)userToken
             withMeetingParams:(NSDictionary *)meetingParams
             completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                       failure:(nullable void (^)(NSError *error))createFailure;

- (void)updateRecurrenceMeeting:(NSString *)userToken
              withMeetingParams:(NSDictionary *)meetingParams
                  reservationId:(NSString *)reservation_id
              completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                        failure:(nullable void (^)(NSError *error))createFailure;

- (void)getRecurrenceMeetingInGroupByPage:(NSString *)userToken
                                  groupId:(NSString *)groupId
                        withMeetingParams:(NSDictionary *)meetingParams
                        completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                                  failure:(nullable void (^)(NSError *error))createFailure;

- (void)addMeetingIntoMyMeetingList:(NSString *)userToken
                         identifier:(NSString *)identifier
                  completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                            failure:(nullable void (^)(NSError *error))createFailure;

- (void)removeMeetingFromMyMeetingList:(NSString *)userToken
                            identifier:(NSString *)identifier
                     completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                               failure:(nullable void (^)(NSError *error))createFailure;
@end

NS_ASSUME_NONNULL_END
