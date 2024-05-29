#import "FrtcAuthorizationTool.h"
#import <UserNotifications/UserNotifications.h>

@implementation FrtcAuthorizationTool

+ (void)checkNotificationAuthorizationWithCompletion:(void (^) (BOOL granted))completion {
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
                
            case UNAuthorizationStatusNotDetermined:
                {
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        if (granted) {
                            if (completion) completion(YES);
                        }else {
                            if (completion) completion(NO);
                        }
                    }];
                }
                break;
                
            case UNAuthorizationStatusDenied:
                {
                    if (completion) completion(NO);
                }
                break;
                
            case UNAuthorizationStatusAuthorized:
            default:
                {
                    if (completion) completion(YES);
                }
                break;
        }
    }];
}

@end
