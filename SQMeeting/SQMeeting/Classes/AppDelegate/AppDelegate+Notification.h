#import "AppDelegate.h"
#import "FrtcMeetingReminderView.h"
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Notification) <UNUserNotificationCenterDelegate>

- (void)setNotificationDelegate;

@end

NS_ASSUME_NONNULL_END
