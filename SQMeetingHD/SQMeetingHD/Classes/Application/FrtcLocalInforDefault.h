#import <Foundation/Foundation.h>
@class FrtcUserDefault;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcLocalInforDefault : NSObject

+ (void)saveMeetingName:(NSString *)name;

+ (NSString *)getMeetingDisPlayName;

+ (void)saveLastMeetingNumber:(NSString *)number;

+ (NSString *)getLastMeetingNumber;

+ (void)saveLoginName:(NSString *)name;

+ (NSString *)getLoginName;

+ (void)saveLoginPassword:(NSString *)password;

+ (NSString *)getLoginPassword;

+ (void)savePasswordState:(BOOL)psdState;

+ (BOOL)getPasswordState;

+ (void)saveNoiseSwitch:(BOOL)noise;

+ (BOOL)getNoiseSwitch;

+ (void)saveYourSelf:(BOOL)your;

+ (BOOL)getYourSelf;


@end

NS_ASSUME_NONNULL_END
