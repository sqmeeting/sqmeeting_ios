#import "FrtcManagement.h"
#import "SDKNetWorking.h"
#import "SDKUserDefault.h"
#import "FrtcUUID.h"
#import "FrtcUIMacro.h"
#import <CommonCrypto/CommonDigest.h>

#pragma mark --SHA1--
NSString * const salt           = @"49d88eb34f77fc9e81cbdc5190c7efdc";
NSString * const uselessToken   = @"uselessToken";

#pragma mark --Rest API URL--
NSString * const userLoginUrl           = @"/api/v1/user/sign_in";
NSString * const userLogoutUrl          = @"/api/v1/user/sign_out";
NSString * const userInfoUrl            = @"/api/v1/user/info";
NSString * const updatePasswordUrl      = @"/api/v1/user/password";
NSString * const scheduleMeetingUrl     = @"/api/v1/meeting_schedule";
NSString * const queryMeetingListUrl    = @"/api/v1/meeting_room";
NSString * const muteAllUrl             = @"/api/v1/meeting/%@/mute_all";
NSString * const muteOneOrAll           = @"/api/v1/meeting/%@/mute";
NSString * const unmuteAllUrl           = @"/api/v1/meeting/%@/unmute_all";
NSString * const unmuteOneOrAll         = @"/api/v1/meeting/%@/unmute";
NSString * const stopMeetingUrl         = @"/api/v1/meeting/%@/stop";
NSString * const updateParticipantInfo  = @"/api/v1/meeting/%@/participant";
NSString * const setLecturer            = @"/api/v1/meeting/%@/lecturer";
NSString * const disConnectParticipants = @"/api/v1/meeting/%@/disconnect";
NSString * const startOverlay           = @"/api/v1/meeting/%@/overlay";
NSString * const getStartRecording      = @"/api/v1/meeting/%@/recording";
NSString * const getStartLive           = @"/api/v1/meeting/%@/live";
NSString * const requestUnmute          = @"/api/v1/meeting/%@/request_unmute";
NSString * const allowUnmute            = @"/api/v1/meeting/%@/allow_unmute";
NSString * const allowUnmuteAll         = @"/api/v1/meeting/%@/allow_unmute_all";
NSString * const meetingPeoplePin       = @"/api/v1/meeting/%@/pin";
NSString * const queryScheduledMeetingUrl   = @"/api/v1/meeting_schedule";
NSString * const deleteNonRecurrentMeeting  = @"/api/v1/meeting_schedule/%@";
NSString * const getAllUserListUrl          = @"/api/v1/user/public/users";
NSString * const createMeetingUrl           = @"/api/v1/meeting_schedule";
NSString * const getDetailMeetingUrl        = @"/api/v1/meeting_schedule/%@";
NSString * const createRecurrentMeetingUrl  = @"/api/v1/meeting_schedule/recurrence";
NSString * const getScheduleMeetingListUrl  = @"/api/v1/meeting_schedule/recurrence/%@";
NSString * const addMeetingToMyList         = @"/api/v1/meeting_list/add/%@";
NSString * const removeMeetingToMyList      = @"/api/v1/meeting_list/remove/%@";

static FrtcManagement *managementClient = nil;

@implementation FrtcManagement

+ (FrtcManagement *)sharedManagement {
    @synchronized(self) {
        if (managementClient == nil) {
            managementClient = [[FrtcManagement alloc] init];
        }
    }
    
    return managementClient;
}

- (instancetype)init {
    if(self = [super init]) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:NO forKey:SKD_LOGIN_VALUE];
    }
    
    return self;
}

#pragma mark --config--
- (void)setFRTCSDKConfig:(FRTCSDKConfigKey)key withSDKConfigValue:(NSString *)value {
    if(key == FRTCSDK_SERVER_ADDRESS) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKObject:value forKey:SKD_SERVER_ADDRESS];
    }else if (key == FRTCSDK_SERVER_LOGOUT) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:NO forKey:SKD_LOGIN_VALUE];
    }
}


#pragma mark --login interface--
- (void)loginWithUserName:(NSString *)userName withPassword:(NSString *)password loginSuccess:(nullable void (^)(NSDictionary * userInfo))loginSuccess loginFailure:(nullable void (^)(NSError *error))loginFailure {
    NSString *sha1SecretString = [self secretSha1String:password];
    NSDictionary *dict         = @{@"username":userName, @"secret" :sha1SecretString};
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:userLoginUrl userToken:uselessToken parameters:dict requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:YES forKey:SKD_LOGIN_VALUE];
        loginSuccess(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        loginFailure(error);
    }];
}

- (void)logoutWithUserToken:(NSString *)userToken logoutSuccess:(nullable void (^)(NSDictionary * userInfo))logoutSuccess logoutFailure:(nullable void (^)(NSError *error))logoutFailure {
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:userLogoutUrl userToken:userToken parameters:nil
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:NO forKey:SKD_LOGIN_VALUE];
        logoutSuccess(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:NO forKey:SKD_LOGIN_VALUE];
        logoutFailure(error);
    }];
}

- (void)modifyUserPasswordWithUserToken:(NSString *)userToken oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword modifyCompletionHandler:(nullable void (^)(FRTCSDKModifyPasswordResult result))completionHandler {
    NSString *oldSecretString = [self secretSha1String:oldPassword];
    NSString *newSecretString = [self secretSha1String:newPassword];
    NSDictionary *dict = @{@"secret_old":oldSecretString, @"secret_new" :newSecretString};
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPUT:updatePasswordUrl userToken:userToken parameters:dict requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler(FRTCSDK_MODIFY_PASSWORD_SUCCESS);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        completionHandler(FRTCSDK_MODIFY_PASSWORD_FAILED);
    }];
}

- (void)getLoginUserInfomation:(NSString *)userToken getInfoSuccess:(nullable void (^)(NSDictionary * userInfo))getInfoSuccess getInfoFailure:(nullable void (^)(NSError *error))getInfoFailure {
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:userInfoUrl userToken:userToken parameters:nil
                                 requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        [[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:YES forKey:SKD_LOGIN_VALUE];
        getInfoSuccess(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        getInfoFailure(error);
    }];
}

#pragma mark --schedule meeting interface--
- (void)scheduleMeetingWithUsertoken:(NSString *)usertoken meetingName:(NSString *)meetingName scheduleCompletionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler scheduleFailure:(nullable void (^)(NSError *error))scheduleFailure {
    NSDictionary *dict = @{@"meeting_type":@"instant", @"meeting_name" :meetingName};
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:scheduleMeetingUrl userToken:usertoken parameters:dict requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        scheduleFailure(error);
    }];
}

- (void)queryMeetingRoomList:(NSString *)usertoken queryMeetingRoomSuccess:(nullable void (^)(NSDictionary * meetingRoom))querySuccess queryMeetingRoomFailure:(nullable void (^)(NSError *error))queryFailure {
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:queryMeetingListUrl userToken:usertoken parameters:nil requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        querySuccess(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        queryFailure(error);
    }];
}

- (void)getScheduledMeeting:(NSString *)usertoken
                   withPage:(NSInteger)page
        getScheduledHandler:(nullable void (^)(NSDictionary * scheduledMeetingInfo))completionHandler
        getScheduledFailure:(nullable void (^)(NSError *error))getScheduledFailure {
    NSString *serverAddress = [[SDKUserDefault sharedSDKUserDefault] sdkObjectForKey:SKD_SERVER_ADDRESS];
    NSString *uuid = [[FrtcUUID sharedUUID] getAplicationUUID];
    NSString *restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@&token=%@&page_num=%ld&page_size=500", serverAddress, queryScheduledMeetingUrl, uuid, usertoken, page];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:restfulUrl parameters:nil requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        getScheduledFailure(error);
    }];
}

- (void)deleteNonCurrentMeeting:(NSString *)userToken
              withReservationId:(NSString *)reservationId
                    deleteGroup:(BOOL)deleteGroup
        deleteCompletionHandler:(nullable void (^)(void))completionHandler
                  deleteFailure:(nullable void (^)(NSError *error))deleteFailure {
    NSString *str = [NSString stringWithFormat:deleteNonRecurrentMeeting, reservationId];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str 
                                                   userToken:userToken
                                                  parameters:(deleteGroup == YES) ? @{@"deleteGroup":[NSNumber numberWithBool:YES]} : nil
                                    requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        deleteFailure(error);
    }];
}

- (void)getUserList:(NSString *)userToken
           withPage:(NSInteger)page
         withFilter:(NSString *)filter
  completionHandler:(nullable void (^)(NSDictionary * allUserListInfo))completionHandler
            failure:(nullable void (^)(NSError *error))getFailure {
    NSString *serverAddress = [[SDKUserDefault sharedSDKUserDefault] sdkObjectForKey:SKD_SERVER_ADDRESS];
    NSString *uuid = [[FrtcUUID sharedUUID] getAplicationUUID];
    
    NSString *restfulUrl;
    if([filter isEqualToString:@""]) {
        restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@&token=%@&page_num=%ld&page_size=50", serverAddress, getAllUserListUrl, uuid, userToken, page];
    } else {
        filter = [filter stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet]];
        restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@&token=%@&page_num=%ld&page_size=50&filter=%@", serverAddress, getAllUserListUrl, uuid, userToken, page, filter];
    }
        
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:restfulUrl parameters:nil requestCompletionHandler:completionHandler requestPOSTFailure:getFailure];
}

- (void)getAllUserList:(NSString *)userToken
              withPage:(NSInteger)page
     completionHandler:(nullable void (^)(NSDictionary * allUserListInfo))completionHandler
               failure:(nullable void (^)(NSError *error))getFailure {
    NSString *serverAddress = [[SDKUserDefault sharedSDKUserDefault] sdkObjectForKey:SKD_SERVER_ADDRESS];
    NSString *uuid = [[FrtcUUID sharedUUID] getAplicationUUID];
    NSString *restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@&token=%@&page_num=%ld&page_size=50", serverAddress, getAllUserListUrl, uuid, userToken, page];
        
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:restfulUrl parameters:nil requestCompletionHandler:completionHandler requestPOSTFailure:getFailure];
}

- (void)createMeeting:(NSString *)userToken
    withMeetingParams:(NSDictionary *)meetingParams
    completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
              failure:(nullable void (^)(NSError *error))createFailure {
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:createMeetingUrl userToken:userToken parameters:meetingParams requestCompletionHandler:completionHandler requestPOSTFailure:createFailure];
}


- (void)getScheduleMeetingDetailInformation:(NSString *)userToken
                          withReservationID:(NSString *)reservationID
                          completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                                    failure:(nullable void (^)(NSError *error))getDetailInfoFailure {
    NSString *str = [NSString stringWithFormat:getDetailMeetingUrl, reservationID];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:str userToken:userToken parameters:nil requestCompletionHandler:completionHandler requestPOSTFailure:getDetailInfoFailure];
}


- (void)updateScheduleMeeting:(NSString *)userToken
            withReservationID:(NSString *)reservationID
            withMeetingParams:(NSDictionary *)meetingParams
            completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                      failure:(nullable void (^)(NSError *error))updateMeetingFailure {
    NSString *str = [NSString stringWithFormat:getDetailMeetingUrl, reservationID];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:userToken parameters:meetingParams requestCompletionHandler:completionHandler requestPOSTFailure:updateMeetingFailure];
    
}


#pragma mark --meeting mute interface--
- (void)muteAllParticipants:(NSString *)usertoken meetingNumber:(NSString *)meetingNumber mute:(BOOL)allowSelfUnmute muteAllCompletionHandler:(nullable void (^)(void))completionHandler muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure {
    NSDictionary *dict = @{@"allow_self_unmute": [NSNumber numberWithBool:allowSelfUnmute]};
    NSString *str      = [NSString stringWithFormat:muteAllUrl, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken parameters:dict requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        muteAllFailure(error);
    }];
}

- (void)muteParticipant:(NSString *)usertoken
          meetingNumber:(NSString *)meetingNumber
        allowSelfUnmute:(BOOL)allowSelfUnmute
        participantList:(NSArray<NSString *> *)participantList
  muteCompletionHandler:(nullable void (^)(void))completionHandler
         muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure {
    NSDictionary *dict = @{@"allow_self_unmute": [NSNumber numberWithBool:allowSelfUnmute],
                           @"participants"     : participantList};
    
    NSString *str = [NSString stringWithFormat:muteOneOrAll, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken parameters:dict requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        muteAllFailure(error);
        
    }];
}

- (void)unMuteAllParticipants:(NSString *)usertoken
                meetingNumber:(NSString *)meetingNumber
     muteAllCompletionHandler:(nullable void (^)(void))completionHandler
               muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure {
    NSString *str = [NSString stringWithFormat:unmuteAllUrl, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken parameters:nil requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        muteAllFailure(error);
    }];
}

- (void)unMuteParticipant:(NSString *)usertoken
            meetingNumber:(NSString *)meetingNumber
          participantList:(NSArray<NSString *> *)participantList
    muteCompletionHandler:(nullable void (^)(void))completionHandler
           muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure {
    NSDictionary *dict = @{@"participants":participantList};
    
    NSString *str = [NSString stringWithFormat:unmuteOneOrAll, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken parameters:dict requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        muteAllFailure(error);
    }];
}

- (void)stopMeeting:(NSString *)usertoken
      meetingNumber:(NSString *)meetingNumber
    participantList:(NSArray<NSString *> *)participantList
stopCompletionHandler:(nullable void (^)(void))completionHandler
        stopFailure:(nullable void (^)(NSError *error))stopFailure {
    NSString *str = [NSString stringWithFormat:stopMeetingUrl, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken parameters:nil requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        stopFailure(error);
    }];
}

#pragma mark --internal function--
- (NSString *)secretSha1String:(NSString *)password {
    NSString *shaResult = [password stringByAppendingString:salt];
    const char *cstr = [shaResult cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:[shaResult length]];
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


//2.0

- (void)updateParticipantInfoForGuest:(NSString *)meetingNumber
                          displayName:(NSString *)displayName
                           tempServer:(BOOL)isTempServer
                          tempAddress:(NSString *)tempAddress
                    completionHandler:(nullable void (^)(void))completionHandler
                              failure:(nullable void (^)(NSError *error))failure {
    NSString *str = [NSString stringWithFormat:updateParticipantInfo, meetingNumber];
    NSString *uuid = [[FrtcUUID sharedUUID] getAplicationUUID];
    
    if (isTempServer) {
        [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingCustomServerPOST:str
                                                                 userToken:@""
                                                             serverAddress:tempAddress
                                                                parameters:@{@"display_name":displayName,@"client_id":uuid}
                                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
            completionHandler();
        } requestPOSTFailure:^(NSError * _Nonnull error) {
            failure(error);
        }];
        
    }else {
        [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                     userToken:@""
                                                    parameters:@{@"display_name":displayName,@"client_id":uuid}
                                      requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
            completionHandler();
        }
                                            requestPOSTFailure:^(NSError * _Nonnull error) {
            failure(error);
        }];
    }
}

- (void)updateParticipantInfoForSignIn:(NSString *)usertoken
                         meetingNumber:(NSString *)meetingNumber
                           participant:(NSString *)participant
                           displayName:(NSString *)displayName
                     completionHandler:(nullable void (^)(void))completionHandler
                               failure:(nullable void (^)(NSError *error))failure {
    NSString *str = [NSString stringWithFormat:updateParticipantInfo, meetingNumber];
    if (participant == nil || participant.length < 1) {
        participant = [[FrtcUUID sharedUUID] getAplicationUUID];
    }
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken
                                                parameters:@{@"display_name":displayName,@"client_id":participant}
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)setLecturer:(NSString *)usertoken
       lecturerUUID:(NSString *)lecturerUUID
      meetingNumber:(NSString *)meetingNumber
  completionHandler:(nullable void (^)(void))completionHandler
            failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:setLecturer, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:usertoken
                                                parameters:@{@"lecturer":lecturerUUID}
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)unsetLecturer:(NSString *)userToken
        meetingNumber:(NSString *)meetingNumber
    completionHandler:(nullable void (^)(void))completionHandler
              failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:setLecturer, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str userToken:userToken parameters:nil requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)disConnectParticipants:(NSString *)usertoken
                 meetingNumber:(NSString *)meetingNumber
               participantList:(NSArray<NSString *> *)participantList
             completionHandler:(nullable void (^)(void))completionHandler
                       failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:disConnectParticipants, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str userToken:usertoken parameters:@{@"participants":participantList} requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)startTextOverlay:(NSString *)usertoken
           meetingNumber:(NSString *)meetingNumber
                 content:(NSString *)content
                  repeat:(NSNumber *)repeat
                position:(NSNumber *)position
           enable_scroll:(NSNumber *)enable
       completionHandler:(nullable void (^)(void))completionHandler
                 failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:startOverlay, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                 userToken:usertoken
                                                parameters:@{@"content":content,@"repeat":repeat,@"position":position,@"enable_scroll":enable}
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)stopTextOverlay:(NSString *)usertoken
          meetingNumber:(NSString *)meetingNumber
      completionHandler:(nullable void (^)(void))completionHandler
                failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:startOverlay, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str
                                                   userToken:usertoken
                                                  parameters:nil
                                    requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)startRecording:(NSString *)usertoken
         meetingNumber:(NSString *)meetingNumber
     completionHandler:(nullable void (^)(void))completionHandler
               failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:getStartRecording, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                 userToken:usertoken
                                                parameters:@{@"meeting_number":meetingNumber}
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)stopRecording:(NSString *)usertoken
        meetingNumber:(NSString *)meetingNumber
    completionHandler:(nullable void (^)(void))completionHandler
              failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:getStartRecording, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str
                                                   userToken:usertoken
                                                  parameters:@{@"meeting_number":meetingNumber}
                                    requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)startLive:(NSString *)usertoken
    meetingNumber:(NSString *)meetingNumber
     livePassword:(NSString *)live_password
completionHandler:(nullable void (^)(void))completionHandler
          failure:(nullable void (^)(NSError *error))failure {
    NSString *str = [NSString stringWithFormat:getStartLive, meetingNumber];
    NSDictionary *parameter = @{};
    if (kStringIsEmpty(live_password)) {
        parameter = @{@"meeting_number":meetingNumber};
    }else{
        parameter = @{@"meeting_number":meetingNumber,@"live_password":live_password};
    }
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                 userToken:usertoken
                                                parameters:parameter
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)stopLive:(NSString *)usertoken
   meetingNumber:(NSString *)meetingNumber
completionHandler:(nullable void (^)(void))completionHandler
         failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:getStartLive, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str
                                                   userToken:usertoken
                                                  parameters:@{@"meeting_number":meetingNumber}
                                    requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
    
}

- (void)requestUnmute:(NSString *)usertoken
        meetingNumber:(NSString *)meetingNumber
    completionHandler:(nullable void (^)(void))completionHandler
              failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:requestUnmute, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                 userToken:usertoken
                                                parameters:nil
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)requestUnmuteForGuest:(NSString *)usertoken
                meetingNumber:(NSString *)meetingNumber
                  tempAddress:(NSString *)tempAddress
            completionHandler:(nullable void (^)(void))completionHandler
                      failure:(nullable void (^)(NSError *error))failure {
    NSString *str = [NSString stringWithFormat:requestUnmute, meetingNumber];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingCustomServerPOST:str
                                                             userToken:usertoken
                                                         serverAddress:tempAddress
                                                            parameters:nil
                                              requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)allowUnmute:(NSString *)usertoken
      meetingNumber:(NSString *)meetingNumber
         parameters:(NSArray<NSString *> *)parameters
  completionHandler:(nullable void (^)(void))completionHandler
            failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:allowUnmute, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                 userToken:usertoken
                                                parameters:@{@"participants":parameters}
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)peoplePin:(NSString *)usertoken
    meetingNumber:(NSString *)meetingNumber
       parameters:(NSArray<NSString *> *)parameters
completionHandler:(nullable void (^)(void))completionHandler
          failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:meetingPeoplePin, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str
                                                 userToken:usertoken
                                                parameters:@{@"participants":parameters}
                                  requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)peopleUnPin:(NSString *)usertoken
      meetingNumber:(NSString *)meetingNumber
  completionHandler:(nullable void (^)(void))completionHandler
            failure:(nullable void (^)(NSError *error))failure {
    
    NSString *str = [NSString stringWithFormat:meetingPeoplePin, meetingNumber];
    
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str
                                                   userToken:usertoken
                                                  parameters:nil
                                    requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler();
    } requestDELETEFailure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)queryUrlMeetingInfo:(NSString *)url
               meetingToken:(NSString *)meetingToken
          completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                    failure:(nullable void (^)(NSError *error))meetingFailure
{
    NSString *stringUrl = [NSString stringWithFormat:@"https://%@/api/v1/mt/%@",url,meetingToken];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:stringUrl
                                               parameters:NULL
                                 requestCompletionHandler:^(NSDictionary * _Nonnull requestInfomation) {
        completionHandler(requestInfomation);
    } requestPOSTFailure:^(NSError * _Nonnull error) {
        meetingFailure(error);
    }];
}

- (void)createRecurrentMeeting:(NSString *)userToken
             withMeetingParams:(NSDictionary *)meetingParams
             completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                       failure:(nullable void (^)(NSError *error))createFailure {
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:createRecurrentMeetingUrl userToken:userToken parameters:meetingParams requestCompletionHandler:completionHandler requestPOSTFailure:createFailure];
}

- (void)updateRecurrenceMeeting:(NSString *)userToken
              withMeetingParams:(NSDictionary *)meetingParams
                  reservationId:(NSString *)reservation_id
              completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                        failure:(nullable void (^)(NSError *error))createFailure {
    NSString *str = [NSString stringWithFormat:getScheduleMeetingListUrl, reservation_id];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:userToken parameters:meetingParams requestCompletionHandler:completionHandler requestPOSTFailure:createFailure];
}


- (void)getRecurrenceMeetingInGroupByPage:(NSString *)userToken
                                  groupId:(NSString *)groupId
                        withMeetingParams:(NSDictionary *)meetingParams
                        completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                                  failure:(nullable void (^)(NSError *error))createFailure {
    NSString *str = [NSString stringWithFormat:getScheduleMeetingListUrl, groupId];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingGET:str userToken:userToken parameters:meetingParams requestCompletionHandler:completionHandler requestPOSTFailure:createFailure];
}

- (void)addMeetingIntoMyMeetingList:(NSString *)userToken
                         identifier:(NSString *)identifier
                  completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                            failure:(nullable void (^)(NSError *error))createFailure {
    NSString *str = [NSString stringWithFormat:addMeetingToMyList, identifier];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingPOST:str userToken:userToken parameters:nil requestCompletionHandler:completionHandler requestPOSTFailure:createFailure];
}

- (void)removeMeetingFromMyMeetingList:(NSString *)userToken
                            identifier:(NSString *)identifier
                     completionHandler:(nullable void (^)(NSDictionary * meetingInfo))completionHandler
                               failure:(nullable void (^)(NSError *error))createFailure {
    NSString *str = [NSString stringWithFormat:removeMeetingToMyList, identifier];
    [[SDKNetWorking sharedSDKNetWorking] sdkNetWorkingDELETE:str
                                                   userToken:userToken
                                                  parameters:nil
                                    requestCompletionHandler:completionHandler requestDELETEFailure:createFailure];
}

@end
