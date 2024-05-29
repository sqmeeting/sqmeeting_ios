#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define SERVER_ADDRESS @"server_address"
#define DISPLAY_NAME   @"meeting_display_name"
#define CONFERENCE_NUMBER @"conference_number"
#define MICROPHONE_STATUS @"microphone_status"
#define CAMERA_STATUS @"camera_status"
#define NAME_SATTUS @"name_status"
#define ONLY_AUDIO_STATUC @"only_audio_status"

#define CALL_RATE @"call_rate"
#define SIGN_PASSWORD @"sign_pwd"
#define PWD_REMEMBER @"pwd_remembered"

#define ACCOUNT_EMAIL @"account_email"
#define ACCOUNT_FIRSTNAME @"account_firstname"
#define ACCOUNT_LASTNAME @"account_lastname"
#define SIGN_TOKEN @"sign_token"
#define SIGN_STATUS @"sign_status"

#define SIGN_USERINFO @"sign_userinfo"

#define LOGIN_STATUS @"login_status"
#define MEETING_PASSWORD @"meeting_password"
#define LOGIN_NAME @"login_name"
#define LOGIN_PASSWORD @"login_password"
#define SHOW_EULAVIEW @"isShowEulaView"


@interface FrtcUserDefault : NSObject

+ (FrtcUserDefault *)sharedUserDefault;

- (void)setObject:(NSString *)object forKey:(NSString *)objectKey;

- (NSString *)objectForKey:(NSString *)defaultKey;

- (void)setBool:(BOOL)object forKey:(nonnull NSString *)defaultName;

- (BOOL)boolForKey:(nonnull NSString *)defaultName;

@end

NS_ASSUME_NONNULL_END
